# ---------------------------------------------------------------------------
# Fully self-contained synthetic test data.
#
# Real GIAB/1000 Genomes FASTQs are gigabytes and require network access that
# CI runners (and this pipeline's reviewers) shouldn't have to depend on.
# Instead we deterministically simulate a small reference + a mutated "sample
# genome" + paired-end reads from it (pure Python, seeded — see
# scripts/generate_test_data.py). Running the pipeline should recover the
# variants recorded in data/reference/known_variants.tsv, which is what
# tests/test_pipeline.py checks.
#
# Swapping in real data only requires pointing config["reference"] and
# config["samples"] at real FASTA/FASTQ paths — no rule changes needed.
# ---------------------------------------------------------------------------

rule generate_test_data:
    output:
        ref=config["reference"],
        r1=config["samples"]["demo"]["r1"],
        r2=config["samples"]["demo"]["r2"],
        truth="data/reference/known_variants.tsv",
    params:
        seed=config["sim"]["seed"],
        ref_length=config["sim"]["ref_length"],
        coverage=config["sim"]["coverage"],
        read_length=config["sim"]["read_length"],
        error_rate=config["sim"]["error_rate"],
    script:
        "../../scripts/generate_test_data.py"


rule index_reference:
    input:
        ref=config["reference"],
    output:
        fai=config["reference"] + ".fai",
    shell:
        "samtools faidx {input.ref}"


rule reference_dict:
    # Only needed by the GATK path (HaplotypeCaller/GenotypeGVCFs).
    input:
        ref=config["reference"],
    output:
        dict=config["reference"].rsplit(".", 1)[0] + ".dict",
    shell:
        "gatk CreateSequenceDictionary -R {input.ref} -O {output.dict}"
