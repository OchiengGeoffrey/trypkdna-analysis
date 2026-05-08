## Week 1 (May 5–11, 2026)
**Phase:** 0 – Pre-flight Validation  
**Status:** In Progress (BUSCO & environment validation complete; BLAST & SRA tests pending)  

**Objectives for the Week**
- [x]Establish reproducible project structure
- [x]Configure Conda environment and dependencies
- [x]Validate genome download workflow
- [x]Execute BUSCO quality assessment
- [x]Produce publication-ready BUSCO visualization
- [x]Create project tracking and documentation framework
- [ ]Prepare for BLAST and SRA workflow testing

**Completed:**
- Created flat directory structure (`00_preflight/`, `01_…`, `data/genomes/`)
- Initialized Git repository and created remote GitHub repo (`trypkdna-analysis`)
- Created `environment.yml` with relaxed version pins and added defaults channel
- Created tracking files (`ai_context.md`, `weekly_log.md`, `session_notes.md`)
- Conda environment successfully created with all dependencies (BUSCO, snakemake, etc.)
- Downloaded *Trypanosoma equiperdum* OVI genome (GCA_001457755.2) via wget
- Extracted and validated BUSCO *Trypanosoma* lineage (trypanosoma_odb12, 302 MB)
- BUSCO run completed: **C:97.8%, F:0.5%, M:1.8%** (complete)
- Generated and refined BUSCO bar plot in R (publication-ready with proper legend, labels, and centering)
- Created `.gitignore` to exclude `busco_downloads/`, intermediate results, and large files
- Phase 0a snapshot committed to Git (environment, scripts, BUSCO results)

**Pending (Phase 0 conclusion):**
- BLAST test for ATPase gamma homolog
- SRA test download

## Blockers Encountered

| Blocker | Cause | Solution | Status |
|---|---|---|---|
| BUSCO lineage download failed (`BrokenPipeError`, network timeout) | Interrupted network connection during lineage retrieval | Manual browser download of lineage archive | ✅ Resolved |
| tar extraction error (`unexpected end of file`) | Corrupted 11 MB partial archive download | Re-downloaded full 200 MB archive | ✅ Resolved |
| R script selected wrong summary file | BUSCO temporary `run_` subdirectory contained incorrect summary file | Excluded paths containing `/run_` | ✅ Resolved |
| BUSCO summary line failed to match regex `^C:` | Leading whitespace prevented regex anchor matching | Used `grepl("C:", text)` and `trimws()` | ✅ Resolved |
| Legend formatting issues (cut off labels, misaligned title) | Long legend labels and insufficient spacing in ggplot2 | Added two-line labels, `legend.title.position="top"`, horizontal layout, and custom margins | ✅ Resolved |
| R parsing error from subtitle parentheses (`Trypanosoma equiperdum (OVI strain)`) | Parentheses caused parsing instability in R string handling | Removed parentheses from subtitle | ✅ Resolved |

**AI Help Used:**
- Claude: R script debugging (regex patterns, file selection, ggplot2 legend customization), error diagnosis, environment troubleshooting
- ChatGPT: occasional syntax checks

**Key Lessons:**
- BUSCO offline mode requires fully extracted, non-corrupted lineage; always verify file integrity with `gzip -t` before extraction.
- ggplot2 legend positioning requires explicit `legend.title.position="top"` and proper margin settings; default settings cut off long labels.
- Whitespace in text parsing is invisible but breaks regex anchors (`^C:`); use flexible patterns (`grepl()`) or trim strings explicitly.
- Git will track thousands of extracted HMM files without explicit `.gitignore` entries; prevent this early.
- Special characters (parentheses, %) in R string literals can cause unexpected parsing errors; hardcoding is safer than dynamic `paste()`.
- Manual browser downloads are more reliable than wget or automated tools for large, slow-serving files.