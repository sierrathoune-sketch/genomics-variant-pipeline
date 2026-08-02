# From clinical molecular diagnostics to NGS variant pipelines

You're not starting from zero. Map what you already do daily onto the NGS
stack — the concepts transfer more directly than they look.

| What you already do | NGS equivalent |
|---|---|
| qPCR Ct value / quantification | Read depth (DP) at a locus — both are "how much signal do I have here" |
| Sanger confirmation of a call | Orthogonal validation of a variant call (the same QA instinct — never trust a single assay/caller blindly) |
| Assay validation: sensitivity, specificity, LOD | Variant caller benchmarking: precision/recall against a truth set (GIAB), à la `tests/test_pipeline.py` in this repo |
| CAP/CLIA run acceptance criteria | Pipeline QC gates (FastQC/fastp thresholds, VQSR/hard-filter thresholds, MultiQC report) |
| Master mix / primer design | Reference genome + intervals/target regions |
| Interpreting a chromatogram peak | Interpreting a pileup / IGV view of a BAM |

The core shift: in Sanger/qPCR you validate one locus per reaction. In NGS
you're running millions of reactions (reads) in parallel and need
statistical/computational logic — not more chemistry intuition — to sort
signal from noise. That's the actual skill gap to close.

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

## 5. Interview-ready framing

When this comes up in a genomics/precision-medicine interview, the
throughline to state explicitly: *"I validated clinical assays for a
living — I designed this pipeline's QC gates and truth-set regression
test the same way I'd validate a new LDT: sensitivity/specificity against
a reference material, not just 'did it run.'"* That sentence does more
work than listing tool names.
