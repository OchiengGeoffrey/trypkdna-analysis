**Project Phase:** Phase 0 – Pre-flight Validation (Completed) ✅
**Current Focus:** Phase 1 – Comparative Evolutionary Analysis
**Timeline:** Week 1–2 (May 5 – June 17, 2026)

---

## Project Objective

The purpose of this project is to validate and establish a reproducible computational pipeline for investigating kinetoplast DNA (kDNA) retention and associated evolutionary patterns in *Trypanosoma equiperdum*. Phase 0 focused on confirming that the bioinformatics environment, genome resources, BUSCO validation workflow, plotting pipeline, and project organization were functioning correctly before beginning downstream biological analyses.

---

## Expected Outcomes

The initial goals for the pre-flight validation phase were:

- Successful BUSCO lineage download and execution
- Generation of a publication-quality BUSCO visualization
- Validation of the Conda-based computational environment
- Verification of genome download and integrity
- Completion of foundational BLAST and SRA workflow tests
- Establishment of reproducible project structure and version control

---

## Actual Outcomes

### Successfully Completed

| Component | Result |
|-----------|--------|
| **BUSCO completeness** | **97.8%** (S:97.7%, D:0.0%, F:0.5%, M:1.8%) |
| **BUSCO plot** | Publication-ready (R + ggplot2) |
| **Conda environment** | `tryp-kdna` with all dependencies |
| **Genome download** | *T. equiperdum* OVI (`GCA_001457755.2`) |
| **BLAST database** | Created and organized in `data/genomes/blastdb/` |
| **ATPase γ ortholog** | Confirmed – **97.8% identity**, **e-value 2.79e-141**, full-length (319 aa) |
| **SRA Toolkit** | Functional – `prefetch` and `fasterq-dump` validated |
| **SRA test download** | SRR390436 – **94M spots**, **188M reads** converted |
| **Git repository** | Initialized, `.gitignore` configured |
| **AI tracking files** | `ai_context.md`, `weekly_log.md`, `session_notes.md`, `decisions.md` |

---

## Major Challenges Encountered

### BUSCO Download and Extraction Issues

- `BrokenPipeError` interrupted lineage download
- Partial archive downloads caused extraction corruption (`Unexpected EOF in archive`)
- Offline mode required manual lineage extraction and integrity verification

### Plotting and Parsing Issues

- R script initially selected incorrect BUSCO summary files from temporary `run_` directories
- Leading whitespace prevented regex anchors (`^C:`) from matching summary lines
- Subtitle strings containing parentheses triggered R parsing errors
- Legend labels overlapped and were truncated in the initial plot versions

### Repository Management Issues

- Thousands of extracted BUSCO HMM files were unintentionally tracked by Git
- Large intermediate outputs required improved `.gitignore` management

### BLAST and SRA Workflow Issues

- BLAST database files originally placed in `data/genomes/`; moved to `data/genomes/blastdb/` for cleaner organization
- SRA cache location unclear; investigated with `vdb-config` to confirm expected behavior
- Deprecated tutorial commands (`vdb-config --list`) required adaptation to SRA Toolkit v3.4.1

---

## Solutions Implemented

1. Manual BUSCO lineage download via browser with offline execution
2. Archive integrity verification using `gzip -t` and `tar -tzf`
3. Filtering out `/run_` directories during BUSCO summary parsing
4. Flexible regex matching using `grepl("C:", text)` (handles leading whitespace)
5. Removal of problematic subtitle parentheses in R plotting
6. Multi-line legend formatting and margin adjustments in ggplot2
7. Addition of `busco_downloads/`, results folders, logs, and archives to `.gitignore`
8. Use of UCSC genome mirrors instead of unstable RefSeq FTP paths
9. Organized BLAST databases into `data/genomes/blastdb/` subdirectory
10. Investigated SRA cache with `vdb-config -o n` to confirm download location

---

## BLAST Validation Result

**Query:** *T. brucei* F1-ATPase γ (UniProt Q57XH6)  
**Target:** *T. equiperdum* OVI genome (translated)

| Metric | Value |
|--------|-------|
| Subject contig | CZPT02001112.1 |
| Percent identity | **97.806%** |
| Alignment length | **319 aa** |
| E-value | **2.79 × 10⁻¹⁴¹** |
| Bitscore | 440 |
| Query coverage | 1–318 (full-length) |
| Genomic coordinates | 60,117–61,073 |

**Interpretation:** Full-length, highly conserved ortholog confirmed. The gene is present and intact, suitable for downstream dN/dS analysis.

---

## SRA Validation Result

**Test accession:** SRR390436 (public human WGS)

| Metric | Value |
|--------|-------|
| Spots read | 94,034,194 |
| Reads read | 188,068,388 |
| Reads written | 188,068,388 |
| Tool | `fasterq-dump -e 4` |
| Cache | Verified with `vdb-config` |

**Interpretation:** SRA Toolkit fully functional. Download and FASTQ conversion workflows operational.

---

## Types of Assistance Required Going Forward

### Engineering / Workflow Support

- Proteome downloads from TriTrypDB
- OrthoFinder or BLAST-based ortholog extraction
- Protein and codon alignment workflows
- CodeML (PAML) control file setup and execution
- Pipeline reproducibility testing

### Scientific / Analytical Support

- Candidate gene selection (kDNA-associated proteins)
- Interpretation of dN/dS (ω) values under competing models
- Model comparison (Genetic Constraint vs Relaxed Selection vs Functional Threshold)
- Evolutionary interpretation of ATPase γ and other mitochondrial loci

---

## Key Project Files

### Scripts

- `scripts/parse_busco.R` – BUSCO bar plot generation
- `environment.yml` – Conda environment specification
- `.gitignore` – Excludes large data, logs, and outputs

### Outputs

- `00_preflight/results/busco/ovi_busco/busco_plot.png`
- `00_preflight/results/busco/ovi_busco/short_summary.specific.trypanosoma_odb12.ovi_busco.txt`
- `00_preflight/results/blast/ATPase_gamma_tblastn.tsv`

### Documentation

- `00_preflight/ai_context.md`
- `00_preflight/weekly_log.md`
- `00_preflight/session_notes.md`
- `00_preflight/decisions.md`

---

## Lessons Learned

- BUSCO offline mode is significantly more reliable when lineage archives are manually verified.
- Loose dependency pinning with major version constraints provides a practical balance between reproducibility and solvability.
- Hidden whitespace can silently break regex parsing and should always be considered during debugging.
- ggplot2 publication-quality figures require explicit legend sizing, spacing, and margin management.
- Large bioinformatics datasets should never be version-controlled directly.
- Browser downloads are often more stable than command-line tools for large archives from slow servers.
- `tblastn` is the correct BLAST strategy for querying a known protein against a nucleotide genome.
- SRA Toolkit cache locations depend on repository configuration; always verify with `vdb-config`.
- Public test accessions (e.g., SRR390436) are suitable for infrastructure validation even when biologically unrelated to the project.

---

## Phase 0 Status

**COMPLETE ✅**

All validation components passed. The project infrastructure is now fully validated and ready for Phase 1: Comparative Evolutionary Analysis.

| Validation Component | Status |
|----------------------|--------|
| Project structure | ✅ |
| Conda environment | ✅ |
| Genome download | ✅ |
| BUSCO assessment | ✅ (97.8%) |
| BUSCO visualization | ✅ |
| BLAST database | ✅ |
| ATPase γ ortholog | ✅ |
| SRA download | ✅ |
| FASTQ conversion | ✅ |

**Next Phase:** Phase 1 – Comparative Genomics (dN/dS analysis on kDNA-associated genes)