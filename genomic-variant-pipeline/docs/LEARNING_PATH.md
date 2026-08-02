## 1. Concepts, in the order this repo teaches them

1. **File formats** — FASTQ (reads+quality) → BAM (aligned reads) → VCF
   (variant calls). Learn the VCF spec well; you'll read it more than any
   other data structure in this field. (`samtools/hts-specs` on GitHub is
   the canonical reference.)
2. **QC** (`workflow/rules/qc.smk`) — FastQC metrics, adapter trimming
   with fastp. What "bad data" looks like before it wastes compute time.
3. **Alignment** (`workflow/rules/align.smk`) — BWA-MEM seed-and-extend
   mapping, coordinate sorting, duplicate marking. Duplicates matter for
   the same reason they matter in qPCR: they inflate apparent
   signal/depth without adding information.
4. **Variant calling** (`workflow/rules/call.smk`) — pileup-based calling
   (bcftools) vs. local reassembly/haplotype-based calling (GATK
   HaplotypeCaller). Know *why* HaplotypeCaller handles indels better:
   local re-assembly around candidate regions vs. per-site pileup stats.
5. **Filtering** — hard filters (QD, FS, MQ, MQRankSum, ReadPosRankSum,
   SOR) vs. VQSR (machine-learned filter using known-variant resources).
   This is the closest analog to your CAP/CLIA acceptance-criteria
   mindset — you're setting pass/fail thresholds on a diagnostic signal.
6. **Annotation & clinical interpretation** (beyond this repo) — VEP/
   SnpEff for functional consequence, ClinVar/gnomAD for population
   frequency and clinical significance, ACMG/AMP 2015 guidelines for
   classification (Pathogenic/Likely Pathogenic/VUS/Likely
   Benign/Benign). This is where your clinical judgment becomes the
   differentiator over a pure bioinformatician.

## 2. High-yield, stable references (not link-rot-prone blog posts)

- **GATK Best Practices** (Broad Institute) — germline short-variant
  discovery workflow; read this end to end once.
- **Genome in a Bottle (GIAB) / NIST** — the standard truth sets used to
  benchmark variant callers (HG001-HG007). `hap.py` is the standard tool
  for precision/recall benchmarking against them.
- **VCF/SAM specification** (`samtools/hts-specs`) — ground truth for file
  format semantics; skip tutorials that get FILTER/INFO/FORMAT wrong.
- **ACMG/AMP 2015 variant classification guidelines** — the clinical
  interpretation layer; this is squarely in your existing expertise once
  you can generate the annotated VCF.

## 3. Suggested pace (efficiency-first, not exhaustive)

- **Week 1** — Get this repo running locally (`conda env create`,
  `snakemake --cores 2`). Read every rule file. Open the resulting BAM in
  IGV and the VCF in a text editor — correlate what you see against what
  each rule did.
- **Week 2** — Swap the `caller` path: run the GATK target
  (`snakemake results/variants/gatk/demo.filtered.vcf.gz`) and diff its
  output against the bcftools path. Understand *why* they disagree on a
  handful of sites (typically indels/low-complexity regions).
- **Week 3** — Add hap.py-style benchmarking against
  `known_variants.tsv` (the repo's tests already do a lightweight version
  of this — extend it to precision, not just recall).
- **Week 4** — Add annotation (SnpEff rule already scaffolded) and write
  a short ACMG-style interpretation for 2-3 of the recovered variants, as
  if this were a clinical report. This is the piece that makes the
  portfolio project read as "clinical scientist doing bioinformatics,"
  not "generic bioinformatics tutorial."

## 4. Ways to extend this into a stronger portfolio piece

- Multi-sample joint genotyping (GenomicsDBImport + joint GenotypeGVCFs)
- Somatic calling (Mutect2) if you want to signal oncology/precision-medicine relevance
- CNV calling (GATK gCNV or CNVkit) — variant calling alone undersells the field
- Containerize (Dockerfile pinning the conda env) for fully portable execution
- Formal benchmarking report using `hap.py` against a real GIAB truth VCF, published as a notebook in `docs/`

