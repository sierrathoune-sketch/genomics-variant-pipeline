# ---------------------------------------------------------------------------
# Two calling paths (see README "Two calling paths" for the trade-off):
#
#   bcftools  (default, CI target) — fast, minimal deps, good enough to
#             validate the pipeline mechanics and recover the truth set.
#   gatk      (opt-in target)      — HaplotypeCaller/GenotypeGVCFs + hard
#             filters, matching GATK Best Practices germline discovery.
#             Not part of `rule all` by default (JVM startup + larger deps
#             make it noticeably slower for a toy CI run) — request it
#             explicitly: `snakemake --cores 2 results/variants/gatk/demo.filtered.vcf.gz`
# ---------------------------------------------------------------------------

rule call_variants_bcftools:
    input:
        bam="results/aligned/{sample}.dedup.bam",
        bai="results/aligned/{sample}.dedup.bam.bai",
        ref=config["reference"],
        fai=config["reference"] + ".fai",
    output:
        vcf="results/variants/{sample}.raw.vcf.gz",
    threads: config["threads"]
    shell:
        "bcftools mpileup -f {input.ref} --threads {threads} -a AD,DP {input.bam} "
        "| bcftools call -mv --threads {threads} -Oz -o {output.vcf}"


rule filter_variants_bcftools:
    input:
        vcf="results/variants/{sample}.raw.vcf.gz",
    output:
        vcf="results/variants/{sample}.filtered.vcf.gz",
    params:
        minq=config["bcftools_min_qual"],
        mind=config["bcftools_min_depth"],
    shell:
        "bcftools filter -e 'QUAL<{params.minq} || INFO/DP<{params.mind}' "
        "-s LOWQUAL -Oz -o {output.vcf} {input.vcf} "
        "&& bcftools index -t {output.vcf}"


# --- GATK best-practices path -----------------------------------------------

rule haplotype_caller_gvcf:
    input:
        bam="results/aligned/{sample}.dedup.bam",
        bai="results/aligned/{sample}.dedup.bam.bai",
        ref=config["reference"],
        dict=config["reference"].rsplit(".", 1)[0] + ".dict",
    output:
        gvcf="results/variants/gatk/{sample}.g.vcf.gz",
    shell:
        "gatk HaplotypeCaller -R {input.ref} -I {input.bam} -O {output.gvcf} -ERC GVCF"


rule genotype_gvcfs:
    input:
        gvcf="results/variants/gatk/{sample}.g.vcf.gz",
        ref=config["reference"],
    output:
        vcf="results/variants/gatk/{sample}.raw.vcf.gz",
    shell:
        "gatk GenotypeGVCFs -R {input.ref} -V {input.gvcf} -O {output.vcf}"


rule hard_filter_gatk:
    input:
        vcf="results/variants/gatk/{sample}.raw.vcf.gz",
        ref=config["reference"],
    output:
        vcf="results/variants/gatk/{sample}.filtered.vcf.gz",
    params:
        f=config["gatk_snp_filters"],
    shell:
        "gatk VariantFiltration -R {input.ref} -V {input.vcf} "
        "--filter-expression 'QD < {params.f[QD]}' --filter-name QD2 "
        "--filter-expression 'FS > {params.f[FS]}' --filter-name FS60 "
        "--filter-expression 'MQ < {params.f[MQ]}' --filter-name MQ40 "
        "--filter-expression 'MQRankSum < {params.f[MQRankSum]}' --filter-name MQRankSum-12.5 "
        "--filter-expression 'ReadPosRankSum < {params.f[ReadPosRankSum]}' --filter-name ReadPosRankSum-8 "
        "--filter-expression 'SOR > {params.f[SOR]}' --filter-name SOR3 "
        "-O {output.vcf}"
