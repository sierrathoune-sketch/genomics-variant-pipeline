"""
Regression test: does the pipeline recover the known variants injected into
the synthetic sample genome (data/reference/known_variants.tsv)?

This mirrors how a clinical lab validates an assay against a truth set
(e.g., a GIAB/NIST reference material) rather than just checking "did it
run without crashing." Run after `snakemake --cores 2`:

    pytest tests/ -v
"""

import gzip
from pathlib import Path

import pysam
import pytest

RESULTS_VCF = Path("results/variants/demo.filtered.vcf.gz")
TRUTH_TSV = Path("data/reference/known_variants.tsv")


def _load_truth():
    records = []
    with open(TRUTH_TSV) as fh:
        next(fh)  # header
        for line in fh:
            chrom, pos, ref, alt, vtype = line.strip().split("\t")
            records.append((chrom, int(pos), ref, alt, vtype))
    return records


@pytest.fixture(scope="module")
def truth():
    if not TRUTH_TSV.exists():
        pytest.skip("Truth set not found — run `snakemake --cores 2` first")
    return _load_truth()


@pytest.fixture(scope="module")
def called_positions():
    if not RESULTS_VCF.exists():
        pytest.skip("Pipeline output not found — run `snakemake --cores 2` first")
    vcf = pysam.VariantFile(str(RESULTS_VCF))
    positions = set()
    for rec in vcf.fetch():
        if list(rec.filter) in ([], ["PASS"]):
            positions.add(rec.pos)
    return positions


def test_vcf_is_valid(called_positions):
    # Fixture already parses the VCF via pysam; getting here means htslib
    # accepted the header/index without error.
    assert isinstance(called_positions, set)


def test_recovers_majority_of_truth_set(truth, called_positions):
    """Sanity/regression gate: with 30x synthetic coverage we expect to
    recover the large majority of injected SNPs (indels are harder for a
    pileup-based caller and are allowed to be missed)."""
    snps = [t for t in truth if t[4] == "SNP"]
    recovered = [t for t in snps if t[1] in called_positions]

    recall = len(recovered) / len(snps)
    assert recall >= 0.8, (
        f"Only recovered {len(recovered)}/{len(snps)} known SNPs "
        f"(recall={recall:.2f}); expected >= 0.80"
    )


def test_no_excessive_false_positives(truth, called_positions):
    """Loose upper bound — flags a badly miscalibrated filter, not meant to
    be a tight precision benchmark on 5kb of synthetic sequence."""
    truth_positions = {t[1] for t in truth}
    unexpected = called_positions - truth_positions
    assert len(unexpected) <= 3, (
        f"{len(unexpected)} PASS variants with no matching truth-set entry: "
        f"{sorted(unexpected)}"
    )
