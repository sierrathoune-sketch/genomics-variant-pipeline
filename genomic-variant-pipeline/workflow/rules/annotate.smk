# ---------------------------------------------------------------------------
# Optional annotation + reporting.
#
# SnpEff is opt-in (not part of `rule all`): its databases are hundreds of MB
# and not worth the download time for a toy CI run. Request it explicitly:
#   snakemake --cores 2 results/annotated/demo.ann.vcf.gz
# ---------------------------------------------------------------------------

rule snpeff_annotate:
    input:
        vcf="results/variants/{sample}.filtered.vcf.gz",
    output:
        vcf="results/annotated/{sample}.ann.vcf.gz",
        html="results/annotated/{sample}.snpEff_summary.html",
    params:
        genome=config.get("snpeff_genome", "GRCh38.99"),
    shell:
        "snpEff -v {params.genome} {input.vcf} -stats {output.html} "
        "| bgzip > {output.vcf}"


rule multiqc:
    input:
        expand("results/qc/{sample}_fastp.json", sample=SAMPLES),
    output:
        "results/multiqc/multiqc_report.html",
    shell:
        "multiqc results/qc results/aligned -o results/multiqc -f"
