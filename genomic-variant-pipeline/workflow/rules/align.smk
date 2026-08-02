# ---------------------------------------------------------------------------
# Alignment: BWA-MEM -> coordinate-sorted, duplicate-marked BAM
#
# Uses samtools fixmate/markdup (not Picard/GATK MarkDuplicates) to keep the
# default path Java-free and fast. GATK MarkDuplicates is a drop-in swap if
# you want to match the Broad Best Practices pipeline exactly.
# ---------------------------------------------------------------------------

rule bwa_index:
    input:
        ref=config["reference"],
    output:
        multiext(config["reference"], ".amb", ".ann", ".bwt", ".pac", ".sa"),
    shell:
        "bwa index {input.ref}"


rule align_bwa:
    input:
        r1="results/trimmed/{sample}_R1.trim.fastq.gz",
        r2="results/trimmed/{sample}_R2.trim.fastq.gz",
        ref=config["reference"],
        idx=multiext(config["reference"], ".amb", ".ann", ".bwt", ".pac", ".sa"),
    output:
        bam=temp("results/aligned/{sample}.sorted.bam"),
    threads: config["threads"]
    params:
        rg=lambda wc: f"@RG\\tID:{wc.sample}\\tSM:{wc.sample}\\tPL:ILLUMINA",
    shell:
        "bwa mem -t {threads} -R '{params.rg}' {input.ref} {input.r1} {input.r2} "
        "| samtools fixmate -m -u - - "
        "| samtools sort -@ {threads} -o {output.bam} -"


rule mark_duplicates:
    input:
        bam="results/aligned/{sample}.sorted.bam",
    output:
        bam="results/aligned/{sample}.dedup.bam",
    threads: config["threads"]
    shell:
        "samtools markdup -@ {threads} {input.bam} {output.bam}"


rule index_bam:
    input:
        bam="results/aligned/{sample}.dedup.bam",
    output:
        bai="results/aligned/{sample}.dedup.bam.bai",
    shell:
        "samtools index {input.bam}"
