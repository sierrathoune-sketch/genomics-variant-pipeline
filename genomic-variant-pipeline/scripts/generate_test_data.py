"""
Deterministic synthetic reference + paired-end read simulator.

Runnable two ways:
  1. As a Snakemake `script:` directive (the `snakemake` object is injected
     automatically — see workflow/rules/simulate.smk).
  2. Standalone for debugging: `python scripts/generate_test_data.py`

Design goal: zero external downloads, zero non-stdlib dependencies, fully
deterministic given a seed — so CI never depends on network flakiness and
results are byte-identical across runs/machines.

Approach:
  - Generate a random reference sequence (seeded).
  - Build a mutated "sample genome" by injecting known SNPs + small indels
    at fixed positions -> written to known_variants.tsv (the truth set).
  - Simulate paired-end reads *from the mutated genome*, then align/call
    against the *original* reference — the pipeline should recover the
    injected variants. tests/test_pipeline.py checks this.
"""

import gzip
import random
from pathlib import Path

BASES = "ACGT"


def revcomp(seq: str) -> str:
    comp = str.maketrans("ACGTN", "TGCAN")
    return seq.translate(comp)[::-1]


def random_seq(rng: random.Random, length: int) -> str:
    return "".join(rng.choice(BASES) for _ in range(length))


def build_mutated_genome(rng: random.Random, ref: str):
    """Inject fixed-spacing SNPs + a couple of small indels. Returns
    (mutated_genome, truth_records) where truth_records is a list of
    (pos_1based_on_ref, ref_allele, alt_allele, type)."""
    length = len(ref)
    positions = list(range(150, length - 150, 300))  # ~1 variant per 300bp

    mutated = list(ref)
    truth = []
    offset = 0  # cumulative length shift from indels, applied left-to-right

    for i, pos in enumerate(positions):
        idx = pos - 1 + offset  # 0-based index of 1-based position `pos`
        if i % 5 == 4:  # every 5th variant is a small indel
            if i % 10 == 4:  # deletion of 2bp
                ref_allele = ref[pos - 1:pos + 1]
                alt_allele = ref[pos - 1]
                del mutated[idx:idx + 2]
                mutated.insert(idx, alt_allele)
                offset -= 1
                vtype = "DEL"
            else:  # insertion of 2bp
                ins = random_seq(rng, 2)
                ref_allele = ref[pos - 1]
                alt_allele = ref_allele + ins
                mutated[idx + 1:idx + 1] = list(ins)  # insert *after* the anchor base
                offset += 2
                vtype = "INS"
        else:  # SNP
            ref_allele = ref[pos - 1]
            alt_allele = rng.choice([b for b in BASES if b != ref_allele])
            mutated[idx] = alt_allele
            vtype = "SNP"

        truth.append((pos, ref_allele, alt_allele, vtype))

    return "".join(mutated), truth


def simulate_reads(rng, genome, n_pairs, read_len, error_rate):
    frag_len = read_len * 2
    reads_r1, reads_r2 = [], []
    max_start = len(genome) - frag_len - 1
    for i in range(n_pairs):
        start = rng.randint(0, max_start)
        frag = genome[start:start + frag_len]
        r1 = mutate_bases(rng, frag[:read_len], error_rate)
        r2 = mutate_bases(rng, revcomp(frag[-read_len:]), error_rate)
        reads_r1.append(r1)
        reads_r2.append(r2)
    return reads_r1, reads_r2


def mutate_bases(rng, seq, error_rate):
    out = list(seq)
    for i, b in enumerate(out):
        if rng.random() < error_rate:
            out[i] = rng.choice([x for x in BASES if x != b])
    return "".join(out)


def write_fastq_gz(path: Path, reads, read_prefix: str, mate: str):
    with gzip.open(path, "wt") as fh:
        for i, seq in enumerate(reads):
            qual = "I" * len(seq)  # Phred 40, flat — synthetic data
            fh.write(f"@{read_prefix}:{i} {mate}\n{seq}\n+\n{qual}\n")


def write_fasta(path: Path, name: str, seq: str, wrap: int = 70):
    with open(path, "w") as fh:
        fh.write(f">{name}\n")
        for i in range(0, len(seq), wrap):
            fh.write(seq[i:i + wrap] + "\n")


def write_truth(path: Path, truth):
    with open(path, "w") as fh:
        fh.write("chrom\tpos\tref\talt\ttype\n")
        for pos, ref_allele, alt_allele, vtype in truth:
            fh.write(f"sim_ref\t{pos}\t{ref_allele}\t{alt_allele}\t{vtype}\n")


def run(ref_out, r1_out, r2_out, truth_out, seed, ref_length, coverage,
        read_length, error_rate):
    rng = random.Random(seed)

    reference = random_seq(rng, ref_length)
    mutated_genome, truth = build_mutated_genome(rng, reference)

    n_pairs = (ref_length * coverage) // (2 * read_length)
    reads_r1, reads_r2 = simulate_reads(
        rng, mutated_genome, n_pairs, read_length, error_rate
    )

    for p in (ref_out, r1_out, r2_out, truth_out):
        Path(p).parent.mkdir(parents=True, exist_ok=True)

    write_fasta(ref_out, "sim_ref", reference)
    write_fastq_gz(r1_out, reads_r1, "sim", "1")
    write_fastq_gz(r2_out, reads_r2, "sim", "2")
    write_truth(truth_out, truth)


if "snakemake" in globals():
    run(
        ref_out=snakemake.output.ref,
        r1_out=snakemake.output.r1,
        r2_out=snakemake.output.r2,
        truth_out=snakemake.output.truth,
        seed=snakemake.params.seed,
        ref_length=snakemake.params.ref_length,
        coverage=snakemake.params.coverage,
        read_length=snakemake.params.read_length,
        error_rate=snakemake.params.error_rate,
    )
elif __name__ == "__main__":
    run(
        ref_out="data/reference/ref.fasta",
        r1_out="data/reads/demo_R1.fastq.gz",
        r2_out="data/reads/demo_R2.fastq.gz",
        truth_out="data/reference/known_variants.tsv",
        seed=42,
        ref_length=5000,
        coverage=30,
        read_length=150,
        error_rate=0.001,
    )
