# Germline Variant Calling Pipeline

[![pipeline-ci](https://github.com/<your-username>/genomic-variant-pipeline/actions/workflows/ci.yml/badge.svg)](https://github.com/<your-username>/genomic-variant-pipeline/actions/workflows/ci.yml)
![Snakemake](https://img.shields.io/badge/snakemake-%E2%89%A58.0-039475)
![License](https://img.shields.io/badge/license-MIT-blue)

A reproducible, CI-tested Snakemake pipeline for germline short-variant
(SNV/indel) discovery from paired-end FASTQ: QC → alignment → variant
calling → filtering, following GATK Best Practices, with a fully
self-contained synthetic test dataset so it runs identically on a laptop
or in GitHub Actions with zero external downloads.

Built as a portfolio project bridging clinical molecular diagnostics
(qPCR, Sanger, CAP/CLIA-validated assays) into NGS/bioinformatics — see
[`docs/LEARNING_PATH.md`](docs/LEARNING_PATH.md) for the concept map and
study plan this repo was built around.

## Pipeline architecture

```
FASTQ (R1/R2)
   |
   v
FastQC  ---->  fastp (adapter/quality trim)
                   |
                   v
            BWA-MEM alignment
                   |
                   v
       samtools fixmate + sort + markdup
                   |
                   v
        -----------------------
        |                     |
   bcftools mpileup      GATK HaplotypeCaller
   + call  (default)     + GenotypeGVCFs   (opt-in)
        |                     |
   bcftools filter       GATK VariantFiltration
        |                     |
        -----------------------
                   |
                   v
         filtered VCF (+ optional SnpEff annotation)
                   |
                   v
              MultiQC report
```

## Two calling paths

| | `bcftools` (default) | `gatk` (opt-in) |
|---|---|---|
| Speed | Fast, no JVM | Slower (JVM startup, local reassembly) |
| Indel handling | Pileup-based — weaker | Local re-assembly — stronger |
| Used in CI | Yes | No (kept out of `rule all` to keep CI fast) |
| Run it | `snakemake --cores 2` | `snakemake --cores 2 results/variants/gatk/demo.filtered.vcf.gz` |

Both exist deliberately — the trade-off itself (pileup speed vs.
haplotype-based accuracy) is worth being able to explain, not just pick
one and hide the other.

## Quickstart

```bash
git clone https://github.com/<your-username>/genomic-variant-pipeline.git
cd genomic-variant-pipeline

conda env create -f envs/environment.yml
conda activate variant-pipeline

# Generates synthetic reference + reads + truth set, then runs
# QC -> align -> call -> filter -> MultiQC
snakemake --cores 2

# Validate output against the known-variant truth set
pytest tests/ -v
```

No real data or internet access required — `data/` and `results/` are
generated on first run (see `.gitignore`; nothing under them is
committed).

## Repository layout

```
config/config.yaml          # sample sheet, reference path, thresholds
envs/environment.yml        # conda/bioconda pinned dependencies
Snakefile                   # entry point, includes rule modules
workflow/rules/
  simulate.smk              # synthetic reference/reads + truth set (self-contained test data)
  qc.smk                    # FastQC + fastp
  align.smk                 # BWA-MEM + dedup
  call.smk                  # bcftools path (default) + GATK path (opt-in)
  annotate.smk              # SnpEff + MultiQC (opt-in annotation)
scripts/generate_test_data.py  # deterministic read/variant simulator
tests/test_pipeline.py      # truth-set recall/precision regression test
.github/workflows/ci.yml    # runs the pipeline + tests on every push
docs/LEARNING_PATH.md       # background -> NGS concept map + study plan
```

## Why synthetic test data instead of real GIAB FASTQs

Real WGS/WES FASTQs are gigabytes and pull the CI (and anyone cloning
this repo) into network-dependent, slow test runs. `scripts/generate_test_data.py`
deterministically simulates a small reference, injects known SNPs/indels
into a "sample genome," and simulates paired-end reads from it — so the
pipeline can be graded against a ground truth (`data/reference/known_variants.tsv`)
every single run, offline, in seconds. Swapping in real data only means
pointing `config["reference"]` / `config["samples"]` at real paths — no
rule changes required.

## Extending this project

- Multi-sample joint genotyping (`GenomicsDBImport` + joint `GenotypeGVCFs`)
- Somatic variant calling (Mutect2) for oncology/precision-medicine relevance
- CNV calling (GATK gCNV / CNVkit)
- Formal benchmarking against a real GIAB truth VCF with `hap.py`
- Dockerfile pinning `envs/environment.yml` for fully portable execution
- ACMG-style variant interpretation notebook on top of the annotated VCF

See [`docs/LEARNING_PATH.md`](docs/LEARNING_PATH.md) for the reasoning
behind each of these as a next step.

## License

MIT — see [`LICENSE`](LICENSE).
