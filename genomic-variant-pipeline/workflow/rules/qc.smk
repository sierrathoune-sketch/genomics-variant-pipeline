# ---------------------------------------------------------------------------
# Raw QC + adapter/quality trimming
# ---------------------------------------------------------------------------

rule fastqc_raw:
    input:
        r1=lambda wc: config["samples"][wc.sample]["r1"],
        r2=lambda wc: config["samples"][wc.sample]["r2"],
    output:
        html1="results/qc/{sample}_R1_fastqc.html",
        html2="results/qc/{sample}_R2_fastqc.html",
    params:
        outdir="results/qc",
    threads: config["threads"]
    shell:
        "mkdir -p {params.outdir} && "
        "fastqc -t {threads} -o {params.outdir} {input.r1} {input.r2}"


rule fastp_trim:
    input:
        r1=lambda wc: config["samples"][wc.sample]["r1"],
        r2=lambda wc: config["samples"][wc.sample]["r2"],
    output:
        r1="results/trimmed/{sample}_R1.trim.fastq.gz",
        r2="results/trimmed/{sample}_R2.trim.fastq.gz",
        html="results/qc/{sample}_fastp.html",
        json="results/qc/{sample}_fastp.json",
    threads: config["threads"]
    shell:
        "fastp -i {input.r1} -I {input.r2} "
        "-o {output.r1} -O {output.r2} "
        "-h {output.html} -j {output.json} "
        "--thread {threads} --detect_adapter_for_pe"
