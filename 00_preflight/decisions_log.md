# Decisions Log – T. equiperdum kDNA Project

## 2026-05-05

### Use flat directory structure (no nested workflow/)
- **Context:** Initializing project structure for *T. equiperdum* kDNA retention analysis.
- **Decision:** Created flat directories (`00_preflight/`, `01_…`, `data/genomes/`, `scripts/`, etc.) instead of nested Snakemake workflow structure.
- **Rationale:** Simpler to navigate, easier to debug individual steps, reduces cognitive overhead during early validation phases.
- **Alternatives considered:** Snakemake-based DAG workflow structure (kept as future option).

### Relax version pins in environment.yml and add defaults channel
- **Context:** Initial `conda env create -f environment.yml` with strict pins (`busco=5.5.0`, `r-base=4.3`) failed with unsatisfiable dependency constraints.
- **Decision:** Relaxed pins to `>=` ranges (e.g., `busco>=5.0`, `r-base>=4.0`) and added `defaults` channel alongside `conda-forge` and `bioconda`.
- **Rationale:** Allows conda to find compatible versions across channels; avoids long solve times and conflicting constraints.
- **Alternatives considered:** Strict pins (causes conflicts), using only conda-forge (slower solving).

### Add mamba to environment
- **Context:** Standard conda environment solving was slow with multiple channels.
- **Decision:** Added `mamba` as a dependency to accelerate future environment creation and package management.
- **Rationale:** mamba is faster at dependency resolution and is compatible with conda workflows.
- **Alternatives considered:** Skip (slower future operations).

---

## 2026-05-05 (afternoon)

### Download BUSCO lineage manually via browser instead of busco --download
- **Context:** `busco --download trypanosoma_odb12` failed with BrokenPipeError after 5 minutes; subsequent `wget -c` attempts produced incomplete 11 MB files.
- **Decision:** Manually downloaded the trypanosoma_odb12 lineage via browser (~200 MB file) and moved it to `busco_downloads/lineages/`, then used `--offline` flag in BUSCO.
- **Rationale:** Browser handles interruptions better; verified file integrity (200 MB vs. corrupted 11 MB); `--offline` avoids network timeouts.
- **Alternatives considered:** Retry `wget` with different flags (failed), use `busco --download` again (timeout risk), use `datasets` tool (not installed).

### Add busco_downloads/ and 00_preflight/results/ to .gitignore
- **Context:** After extracting the BUSCO lineage, Git tracked thousands of untracked HMM files, making status checks slow and repository bloated.
- **Decision:** Added `busco_downloads/`, `00_preflight/results/`, and pattern exclusions (`*.log`, `*.tar.gz`, etc.) to `.gitignore`.
- **Rationale:** Prevents accidental tracking of large intermediate files; keeps Git history clean.
- **Alternatives considered:** Commit the HMM files (repository bloat), manually clean after each run (tedious and error-prone).

---

## 2026-05-07

### Use R + ggplot2 for BUSCO plotting instead of BUSCO's generate_plot.py
- **Context:** `generate_plot.py` (BUSCO built-in) was not found; decided to create a custom plot in R for finer control.
- **Decision:** Wrote `parse_busco.R` using ggplot2 to generate a bar chart from BUSCO summary statistics.
- **Rationale:** ggplot2 allows full control over aesthetics (colors, labels, legend), reproducibility, and alignment with project's R-based analyses.
- **Alternatives considered:** Python matplotlib (less familiar to team), BUSCO's default script (not available), external plotting tools (adds dependencies).

### Exclude run_ subdirectories when selecting BUSCO summary files
- **Context:** R script initially selected a summary file inside `run_trypanosoma_odb12/` subdirectory, which lacked completeness data, resulting in empty plots.
- **Decision:** Modified file selection regex to exclude paths containing `"/run_"`: `files <- all_files[!grepl("/run_", all_files)]`.
- **Rationale:** The correct summary is at the top level of the BUSCO results directory; run subdirectories contain intermediate files.
- **Alternatives considered:** Hardcode the exact file path (fragile), parse multiple files (unnecessary complexity).

### Use flexible regex for BUSCO summary line matching
- **Context:** The regex `^C:` failed to match the completeness line despite its presence in the file, due to leading whitespace.
- **Decision:** Switched to `grepl("C:", line)` and added `trimws()` for robustness.
- **Rationale:** Handles variations in whitespace (spaces, tabs) without breaking; more maintainable than escaped anchors (`^\\s*C:`).
- **Alternatives considered:** Strict regex with escape sequences (harder to read), manual whitespace trimming (less elegant).

### Implement two-line legend labels with \n for readability
- **Context:** Default BUSCO category labels ("Complete & Single-copy", etc.) were long and overlapped with other plot elements.
- **Decision:** Split labels across two lines using `\n` escape sequences (e.g., "Complete &\nSingle-copy").
- **Rationale:** Reduces horizontal space requirement; improves legend readability without shrinking text.
- **Alternatives considered:** Shorten category names (loses precision), rotate labels (harder to read), increase plot width (space-inefficient).

### Place legend title above keys with legend.title.position = "top"
- **Context:** Default legend positioning placed the title to the left of the legend keys, causing confusion and visual imbalance.
- **Decision:** Set `legend.title.position = "top"` and `legend.direction = "horizontal"` to center the title above the legend box.
- **Rationale:** Clearer visual hierarchy; follows publication conventions for horizontal legends.
- **Alternatives considered:** Vertical legend (takes up vertical space), no legend title (loses context).

### Increase plot dimensions and bottom margin to accommodate legend
- **Context:** Legend was cut off at the bottom of the default plot size (4×5 inches, 10pt bottom margin).
- **Decision:** Increased height to 5.5 inches and bottom margin to 70pt; width 8 inches.
- **Rationale:** Ensures legend is fully visible without overlapping data; maintains aspect ratio for readability.
- **Alternatives considered:** Smaller legend (loses readability), legend to the right (increases overall width), legend inside plot area (obscures data).

---

## 2026-05-08

### Hardcode subtitle with species name (avoid dynamic paste())
- **Context:** Initial attempts to dynamically construct the subtitle using `paste()` led to R parsing errors.
- **Decision:** Hardcoded subtitle as `"Trypanosoma equiperdum OVI strain"`.
- **Rationale:** Eliminates parsing ambiguities; simpler and more transparent than dynamic string construction.
- **Alternatives considered:** Dynamic `paste()` with proper escaping (complex, error-prone), parameterized function (over-engineered for single parameter).

### Remove parentheses from subtitle to avoid R parsing errors
- **Context:** Subtitle "Trypanosoma equiperdum (OVI strain)" caused `Error: unexpected symbol` during R parsing.
- **Decision:** Changed to "Trypanosoma equiperdum OVI strain" (removed parentheses).
- **Rationale:** Parentheses inside string literals can interfere with R's parser; alternative spacing is clear and readable.
- **Alternatives considered:** Escape parentheses with backslashes (verbose), use single quotes (doesn't resolve the issue in this context), use Unicode equivalents (unnecessary).

### Commit Phase 0a snapshot to Git (intermediate checkpoint)
- **Context:** BUSCO and environment setup tasks completed; preparing to run BLAST and SRA tests (remaining Phase 0 tasks).
- **Decision:** Committed Phase 0a artifacts (environment.yml, parse_busco.R, BUSCO results, README.md, .gitignore) to Git with message "Phase 0a: Pre-flight validation (BUSCO complete; BLAST/SRA pending)".
- **Rationale:** Creates a stable checkpoint before Phase 0b (BLAST & SRA tests); enables rollback if needed; documents intermediate progress.
- **Alternatives considered:** Delay commit until Phase 0 fully complete (loses early history), commit more frequently (granular but noisier history).

---

## 2026-05-09

### Create and organize BLAST database in a dedicated subdirectory
- **Context:** `makeblastdb` generated multiple index files (`.nhr`, `.nin`, `.nsq`, etc.) that cluttered the `data/genomes/` directory.
- **Decision:** Created `data/genomes/blastdb/` and stored all BLAST index files there.
- **Rationale:** Keeps the project root and data folders clean; separates source FASTA from derived BLAST files; easier to manage and ignore.
- **Alternatives considered:** Keep BLAST files in `data/genomes/` (less organized), store in a separate top-level `blastdb/` directory (adds extra level).

---

## 2026-06-16

### Use tblastn for protein vs genome search (not BLASTn, BLASTp, etc.)
- **Context:** We needed to confirm the presence of ATPase γ (a known protein) in the unannotated T. equiperdum genome.
- **Decision:** Used `tblastn` (protein query vs translated nucleotide database) to find the ortholog.
- **Rationale:** tblastn translates the genome in all six reading frames and aligns the protein query; works even if annotation is incomplete. BLASTn would miss due to codon degeneracy; BLASTp requires a protein database.
- **Alternatives considered:** BLASTn (too insensitive), BLASTx (would require nucleotide query, we had protein), tBLASTx (slower, overkill).

---

## 2026-06-17

### Use SRR390436 as SRA test accession
- **Context:** We needed a small, public, paired-end dataset to test SRA Toolkit functionality.
- **Decision:** Used SRR390436 (human WGS, 94M spots, ~7 GB) for validation.
- **Rationale:** Widely used in tutorials; small enough to download quickly; paired-end format tests `--split-files`; publicly accessible without restrictions.
- **Alternatives considered:** Trypanosome-specific runs (larger, not commonly used for testing), tiny runs (may not stress the pipeline), unavailable runs (risk).

### Use fasterq-dump instead of fastq-dump for FASTQ conversion
- **Context:** Older `fastq-dump` is slower and less efficient for large runs; `fasterq-dump` is the modern replacement.
- **Decision:** Used `fasterq-dump -e 4` to convert the test SRA run.
- **Rationale:** fasterq-dump is faster, supports multi-threading, and is the recommended tool for SRA Toolkit versions ≥3.0.
- **Alternatives considered:** fastq-dump (slower, deprecated), `sam-dump` (not directly FASTQ).

### Delete test SRA and FASTQ files after validation
- **Context:** Test files were large (~7 GB SRA, ~10 GB FASTQ) and not needed after confirmation.
- **Decision:** Removed all `SRR390436*` files from `data/` after successful verification.
- **Rationale:** Saves disk space; prevents accidental inclusion in Git or backup; keeps project clean.
- **Alternatives considered:** Keep the SRA file (waste space), compress (still takes space), move to a separate storage location (extra effort).

### Use vdb-config -o n instead of deprecated --list
- **Context:** SRA Toolkit 3.4.1 deprecated `vdb-config --list`; needed to inspect download cache location.
- **Decision:** Used `vdb-config -o n` to view current repository configuration.
- **Rationale:** Works with newer SRA Toolkit versions; provides clear output of cache paths.
- **Alternatives considered:** Manually check logs (harder), use `prefetch --verify` (confirms existence but not location).

---

## 2026-06-17

### Phase 0 completion: All validation components passed
- **Context:** BUSCO, BLAST, and SRA tests all successful; project infrastructure ready.
- **Decision:** Declared Phase 0 complete; moved project focus to Phase 1 (comparative genomics).
- **Rationale:** All planned validation objectives met; no blockers remain; environment and tools confirmed functional.
- **Alternatives considered:** Delay Phase 1 until all possible tests done (overkill), proceed with partial validation (risk).

---

**End of Decisions Log**