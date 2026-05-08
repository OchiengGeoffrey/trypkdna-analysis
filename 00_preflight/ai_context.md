**Project Phase:** Phase 0 – Pre-flight Validation (Completed)
**Current Focus:** Finalization of Phase 0 validation and transition into ortholog analysis workflows
**Timeline:** Week 1 (May 5–8, 2026)

---

## Project Objective

The purpose of this project is to validate and establish a reproducible computational pipeline for investigating kinetoplast DNA (kDNA) retention and associated evolutionary patterns in *Trypanosoma equiperdum*. Phase 0 focused on confirming that the bioinformatics environment, genome resources, BUSCO validation workflow, plotting pipeline, and project organization were functioning correctly before beginning downstream biological analyses.

---

## Expected Outcomes

The initial goals for the pre-flight validation phase were:

* Successful BUSCO lineage download and execution
* Generation of a publication-quality BUSCO visualization
* Validation of the Conda-based computational environment
* Verification of genome download and integrity
* Completion of foundational BLAST and SRA workflow tests
* Establishment of reproducible project structure and version control

---

## Actual Outcomes

### Successfully Completed

* BUSCO analysis completed successfully on the *T. equiperdum* OVI genome

  * **Completeness:** 97.8%
  * **Fragmented:** 0.5%
  * **Missing:** 1.8%
* BUSCO plot refined to publication-ready quality using R and ggplot2
* Conda environment successfully configured with reproducible dependency management
* Genome download and preprocessing workflow validated
* Git repository initialized with appropriate tracking exclusions
* AI-assisted documentation and tracking framework established
* R plotting script iteratively debugged and finalized (v1 → v3)

### Pending Before Phase 1

* BLAST test for ATPase gamma ortholog detection
* SRA download workflow validation

---

## Major Challenges Encountered

### BUSCO Download and Extraction Issues

* `BrokenPipeError` interrupted lineage download
* Partial archive downloads caused extraction corruption (`Unexpected EOF in archive`)
* Offline mode required manual lineage extraction and integrity verification

### Plotting and Parsing Issues

* R script initially selected incorrect BUSCO summary files from temporary `run_` directories
* Leading whitespace prevented regex anchors (`^C:`) from matching summary lines
* Subtitle strings containing parentheses triggered R parsing errors
* Legend labels overlapped and were truncated in the initial plot versions

### Repository Management Issues

* Thousands of extracted BUSCO HMM files were unintentionally tracked by Git
* Large intermediate outputs required improved `.gitignore` management

---

## Solutions Implemented

1. Manual BUSCO lineage download via browser with offline execution
2. Archive integrity verification using `gzip -t`
3. Filtering out `/run_` directories during BUSCO summary parsing
4. Flexible regex matching using `grep("C:", ...)`
5. Removal of problematic subtitle parentheses in R plotting
6. Multi-line legend formatting and margin adjustments in ggplot2
7. Addition of `busco_downloads/`, results folders, logs, and archives to `.gitignore`
8. Use of UCSC genome mirrors instead of unstable RefSeq FTP paths

---

## Types of Assistance Required Going Forward

### Engineering / Workflow Support

* BLAST command optimization
* SRA download and preprocessing workflows
* Snakemake workflow organization
* Pipeline reproducibility testing

### Scientific / Analytical Support

* Interpretation of BUSCO completeness metrics
* Ortholog extraction strategy
* Selection pressure analysis setup (CodeML / dN/dS)
* Evolutionary interpretation of ATPase-associated loci

---

## Key Project Files

### Scripts

* `scripts/parse_busco.R`
* `environment.yml`
* `.gitignore`

### Outputs

* `00_preflight/results/busco/ovi_busco/busco_plot.png`
* `00_preflight/results/busco/ovi_busco/short_summary.specific.trypanosoma_odb12.ovi_busco.txt`

### Documentation

* `00_preflight/ai_context.md`
* `00_preflight/weekly_log.md`
* `00_preflight/session_notes.md`
* `00_preflight/decisions.md`

---

## Lessons Learned

* BUSCO offline mode is significantly more reliable when lineage archives are manually verified.
* Loose dependency pinning with major version constraints provides a practical balance between reproducibility and solvability.
* Hidden whitespace can silently break regex parsing and should always be considered during debugging.
* ggplot2 publication-quality figures require explicit legend sizing, spacing, and margin management.
* Large bioinformatics datasets should never be version-controlled directly.
* Browser downloads are often more stable than command-line tools for large archives from slow servers.