# Session Notes – T. equiperdum kDNA Project

## Session 2026-05-05: Conda environment creation fails

**Q:** Why does `conda env create -f environment.yml` fail with dependency conflicts?

**A:** The version pins (e.g., `busco=5.5.0`, `r-base=4.3`) caused unsatisfiable constraints. Relax them to `>=` ranges and add the defaults channel:
```yaml
channels:
  - conda-forge
  - bioconda
  - defaults
dependencies:
  - python>=3.9,<4.0
  - busco>=5.0
  - r-base>=4.0
  - mamba
```

**Used:** Yes

**Notes:** Also added mamba for faster dependency solving. The environment built successfully after this change.

---

## Session 2026-05-05: BUSCO download broken pipe

**Q:** BUSCO fails with `BrokenPipeError: [Errno 32] Broken pipe` while downloading lineage. Log shows the download starts but crashes after ~5 minutes.

**A:** Network interruption during download. Workaround: download the lineage manually via browser, move it to `busco_downloads/lineages/`, and use the `--offline` flag:
```bash
# After manual download:
tar -xzvf busco_downloads/lineages/trypanosoma_odb12.2025-07-01.tar.gz -C busco_downloads/lineages/
busco -i data/genomes/T_equiperdum_OVI.fasta -l trypanosoma_odb12 --offline
```

**Used:** Yes

**Notes:** Verify integrity before extraction using `gzip -t trypanosoma_odb12.2025-07-01.tar.gz`. File size should be ~200 MB.

---

## Session 2026-05-05: tar extraction "unexpected end of file"

**Q:** When extracting the BUSCO lineage, I get `gzip: stdin: unexpected end of file` and `tar: Unexpected EOF in archive`.

**A:** The archive is incomplete or corrupted. Check file size—if it's ~11 MB instead of ~200 MB, delete and re-download completely using a browser or `wget -c` with resumption:
```bash
rm busco_downloads/lineages/trypanosoma_odb12.2025-07-01.tar.gz
# Download via browser or:
wget -c https://busco-data.ezlab.org/v5/data/lineages/trypanosoma_odb12.2025-07-01.tar.gz
# Verify size and integrity before extraction
```

**Used:** Yes

**Notes:** The small file was from an interrupted `wget` or `busco --download`. Manual browser download completed fully (200 MB) without interruption.

---

## Session 2026-05-05: Git tracking thousands of BUSCO files

**Q:** After extracting the BUSCO lineage, `git status` shows thousands of untracked files (HMMs, profiles, etc.). How to prevent tracking these?

**A:** Add `busco_downloads/` and intermediate results to `.gitignore`, then clean up:
```bash
# Add to .gitignore:
busco_downloads/
00_preflight/results/
*.log
*.tar.gz

# Remove untracked files:
git add .gitignore
git commit -m "Add .gitignore for BUSCO files"
git clean -fd
```

**Used:** Yes

**Notes:** The `-fd` flags remove untracked files and directories. Use with caution only after committing important changes.

---

## Session 2026-05-05: wget produces corrupted / partial BUSCO lineage

**Q:** Running `wget -c https://busco-data.ezlab.org/v5/data/lineages/trypanosoma_odb12.2025-07-01.tar.gz` produces only an 11 MB file. Attempting extraction gives `gzip: stdin: unexpected end of file`.

**A:** The download was interrupted, resulting in a truncated archive. Delete the partial file and re-download using a browser (more reliable) or verify connection stability:
```bash
rm -f trypanosoma_odb12.2025-07-01.tar.gz
# Download via browser or with a more stable connection
# Always verify: ls -lh (should be ~200 MB) and gzip -t before extraction
```

**Used:** Yes

**Notes:** The `wget -c` flag allows resuming, but if the server doesn't support resume or the connection breaks early, the file remains incomplete. Browser downloads handle interruptions better.

---

## Session 2026-05-06: wget for RefSeq genome gives "URL not found"

**Q:** Attempting to download the RefSeq genome with `wget` gives `HTTP request sent, awaiting response... 404 Not Found`.

**A:** The RefSeq directory structure may have changed. Use the GenBank accession (GCA) instead of the RefSeq (GCF) path, or use the UCSC mirror:
```bash
wget https://hgdownload.soe.ucsc.edu/hubs/GCA/001/457/755/GCA_001457755.2/GCA_001457755.2.fa.gz -O data/genomes/T_equiperdum_OVI.fasta.gz
```

**Used:** Yes

**Notes:** Genome assemblies are frequently updated. Always check the current NCBI FTP directory before using a static URL. The `datasets` tool is more robust but requires installation.

---

## Session 2026-05-06: wget stalls / slow download of BUSCO lineage

**Q:** Running `wget -c https://busco-data.ezlab.org/v5/data/lineages/trypanosoma_odb12.2025-07-01.tar.gz` is extremely slow or stalls after a few minutes.

**A:** Single-threaded `wget` can be slow from the BUSCO server. Alternatives:
- Use multi-threaded `axel` if available: `axel -n 4 <url>`
- Download via browser (often faster)
- Use `busco --download` which may use a different mechanism

**Used:** Yes (browser chosen)

**Notes:** For future large files, consider `aria2` or `curl --limit-rate` to avoid stalling.

---

## Session 2026-05-07: BUSCO plot – R picks wrong summary file

**Q:** The R script (`parse_busco.R`) produces an empty plot because it reads a file inside `run_trypanosoma_odb12/` that has no `C:` line. How to select the correct summary?

**A:** Exclude any file path containing `"/run_"`:
```r
all_files <- list.files(busco_dir, pattern = "short_summary.*\\.txt", 
                        recursive = TRUE, full.names = TRUE)
files <- all_files[!grepl("/run_", all_files)]
summary_file <- files[1]
```

**Used:** Yes

**Notes:** The correct file is `short_summary.specific.trypanosoma_odb12.ovi_busco.txt` (at the top level, not in a run subdirectory).

---

## Session 2026-05-07: R regex ^C: doesn't match line

**Q:** The summary line contains `C:97.8%...` but `grepl("^C:", text)` returns `character(0)`. Why?

**A:** The line starts with whitespace (spaces or tabs), not `C:`. Use a flexible pattern:
```r
# Instead of:
grepl("^C:", line)

# Use:
grepl("C:", line)
# Or trim first:
grepl("^C:", trimws(line))
# Or match leading whitespace explicitly:
grepl("^\\s*C:", line)
```

**Used:** Yes

**Notes:** Whitespace is invisible in the terminal but breaks regex anchors. Always test with `cat()` or `print()` to reveal hidden characters.

---

## Session 2026-05-07: R parsing error due to parentheses in subtitle

**Q:** Running `Rscript parse_busco.R` gives `Error: unexpected symbol in "Trypanosoma equiperdum (OVI strain)"`. What's wrong?

**A:** Parentheses inside the string cause R to misinterpret the quotation. Remove them:
```r
# Instead of:
subtitle = "Trypanosoma equiperdum (OVI strain)"

# Use:
subtitle = "Trypanosoma equiperdum OVI strain"
```

**Used:** Yes

**Notes:** Avoid other special characters (%, &, etc.) in string literals unless properly escaped with backslashes.

---

## Session 2026-05-07: Legend cut off / overlapping in BUSCO plot

**Q:** The legend labels are long and get cut off. The legend title appears to the side of the keys, causing confusion. How to fix?

**A:** Use two-line labels with `\n`, position the legend title on top, use horizontal direction, increase plot height and margins:
```r
scale_fill_manual(
  breaks = c("Complete & Single-copy", "Complete & Duplicated", 
             "Fragmented", "Missing"),
  values = c("Complete & Single-copy" = "#5ec962",
             "Complete & Duplicated" = "#440154",
             "Fragmented" = "#31688e",
             "Missing" = "#fde724")
)
theme(
  legend.position = "bottom",
  legend.direction = "horizontal",
  legend.title.position = "top",
  legend.title = element_text(hjust = 0.5, face = "bold", size = 11),
  legend.box.spacing = unit(0.5, "cm"),
  legend.background = element_rect(fill = "white", color = "black", linewidth = 0.5),
  plot.margin = margin(t = 10, r = 10, b = 70, l = 10, unit = "pt")
)
ggsave("busco_plot.png", height = 5.5, width = 8, dpi = 300)
```

**Used:** Yes

**Notes:** The final plot is publication-ready with proper legend formatting and spacing.

---

## Session 2026-05-09: BLAST database creation and organization

**Q:** How to create a BLAST database from the genome and where to store it?

**A:** Run `makeblastdb` and store the index files in a separate subdirectory:

```bash
mkdir -p data/genomes/blastdb
makeblastdb -in data/genomes/T_equiperdum_OVI.fasta \
            -dbtype nucl \
            -out data/genomes/blastdb/T_equiperdum_OVI_blastdb
```

**Used:** Yes

**Notes:** This generated all required BLAST index files (`.nhr`, `.nin`, `.nsq`, `.ndb`, `.not`, `.ntf`, `.nto`). Storing them in a dedicated subdirectory keeps the project organized and prevents accidental commits.

---

## Session 2026-05-09: BLAST files accidentally committed

**Q:** I accidentally created files named after BLAST flags (`-db`, `-outfmt`, etc.) during terminal execution. What should I do?

**A:** Identify and remove the unintended files, then ensure they are not tracked:

```bash
# Check for odd filenames
ls -la

# Remove if present
rm -f -db -outfmt

# Verify with git status
git status
```

**Used:** Yes

**Notes:** These files were created because the command was entered without proper formatting. Always use quotes or escape special characters when needed. No data loss occurred.

---

## Session 2026-06-16: BLAST ATPase γ validation

**Q:** Does *T. equiperdum* OVI contain a full-length F1-ATPase γ ortholog?

**A:** Yes. The `tblastn` search produced a strong hit:

| Metric | Value |
|--------|-------|
| Subject contig | CZPT02001112.1 |
| Percent identity | **97.806%** |
| Alignment length | 319 aa |
| E-value | **2.79 × 10⁻¹⁴¹** |
| Bitscore | 440 |
| Query coordinates | 1–318 (full-length) |
| Subject coordinates | 60,117–61,073 |

**Command used:**

```bash
tblastn -query data/genomes/Tbrucei_ATPase_gamma.fasta \
        -db data/genomes/blastdb/T_equiperdum_OVI_blastdb \
        -out 00_preflight/results/blast/ATPase_gamma_tblastn.tsv \
        -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore"
```

**Used:** Yes

**Notes:** The alignment covers essentially the full protein (319 aa). Extremely low E-value and high sequence identity confirm a highly conserved ortholog. This validates the genome for downstream comparative analyses.

---

## Session 2026-06-17: SRA Toolkit validation – download test

**Q:** Is the SRA Toolkit functioning correctly for downloading public sequencing data?

**A:** Yes. Using `prefetch` and `fasterq-dump`:

```bash
# Download
prefetch SRR390436 -O data/

# Verify
prefetch --verify yes SRR390436

# Convert to FASTQ
fasterq-dump SRR390436 -e 4
```

**Results:**

- Spots read: 94,034,194
- Reads read: 188,068,388
- Reads written: 188,068,388

**Used:** Yes

**Notes:** Tested with SRR390436 (public human WGS, 94M spots). Both `prefetch` and `fasterq-dump` completed without errors. Large FASTQ files were generated and then deleted to save space.

---

## Session 2026-06-17: SRA Toolkit cache location

**Q:** Where does `prefetch` store downloaded SRA files? The download appears to go to the project directory, not `~/ncbi`.

**A:** The download location depends on the repository configuration. Investigate with:

```bash
vdb-config -o n
```

**Used:** Yes

**Notes:** The current repository configuration points to `$PWD/data/` within the project directory. Confirmed with `prefetch --verify yes SRR390436`. The old `vdb-config --list` command is deprecated in SRA Toolkit 3.4.1; use `vdb-config -o n` instead.

---

## Session 2026-06-17: FASTQ conversion test

**Q:** Can `fasterq-dump` handle large SRA runs?

**A:** Yes. The test with SRR390436 (94M spots, 188M reads) produced the following output:

- Reads written: 188,068,388 (100% conversion)
- No read count mismatches
- No errors reported

**Command used:**

```bash
fasterq-dump SRR390436 -e 4
```

(The `-e 4` flag uses 4 threads for faster conversion.)

**Used:** Yes

**Notes:** The conversion was successful. The FASTQ files were verified to exist, then removed to avoid using disk space unnecessarily. The success confirms that SRA Toolkit infrastructure is fully operational.

---

## Session 2026-06-17: SRA test file cleanup

**Q:** Should I keep the test SRA and FASTQ files?

**A:** No, they should be removed to avoid filling disk space:

```bash
# Remove SRA cache
rm -f data/SRR390436*
rm -rf data/SRR390436*

# Remove FASTQ files
rm -f data/SRR390436_1.fastq data/SRR390436_2.fastq
```

**Used:** Yes

**Notes:** The test data was only for validation. All test files were deleted after successful verification. The project directory remains clean and ready for real transcriptomics data in Phase 3.

---

## Session 2026-06-17: SRA download location confirmed

**Q:** How can I verify that the SRA download worked correctly and is accessible?

**A:** Run:

```bash
prefetch --verify yes SRR390436
```

**Result:**

- Accession found locally: true
- Cache file found locally: true
- No unresolved dependencies: true

**Used:** Yes

**Notes:** This confirms that the SRA download was successful and the file is intact. The toolkit is ready for real data retrieval.

---

## Session 2026-06-17: tblastn explanation

**Q:** Why use `tblastn` and not the other BLAST options?

**A:** `tblastn` translates the nucleotide target database in all six reading frames and aligns the protein query against it. This is the appropriate strategy when you have a known protein sequence (query) and want to search for its gene in an unannotated nucleotide genome (target).

**Comparison:**

| Tool | Query | Target | Use Case |
|------|-------|--------|----------|
| BLASTn | nucl | nucl | Highly similar DNA sequences |
| BLASTp | protein | protein | Protein-protein comparisons |
| BLASTx | nucl | protein | Find protein-coding genes in a nucleotide query |
| **tblastn** | **protein** | **nucl** | **Find a known protein in a novel genome** |
| tBLASTx | nucl | nucl | Compare two genomes for protein-coding regions (slow) |

**Used:** Yes

**Notes:** The ATPase γ gene was successfully found, confirming that `tblastn` was the correct choice.

---

## Session 2026-06-17: Phase 0 completion validation

**Q:** Are all Phase 0 validation tasks now complete?

**A:** Yes. All components have been successfully validated:

| Component | Status | Result |
|-----------|--------|--------|
| Project structure | ✅ | Flat layout, Git tracked |
| Conda environment | ✅ | All dependencies installed |
| Genome download | ✅ | T. equiperdum OVI |
| BUSCO assessment | ✅ | 97.8% complete |
| BUSCO visualization | ✅ | Publication-ready plot |
| BLAST database | ✅ | Working |
| ATPase γ ortholog | ✅ | 97.8% identity, e-value 2.79e-141 |
| SRA download | ✅ | 94M spots downloaded |
| FASTQ conversion | ✅ | 188M reads converted |

**Used:** Yes

**Notes:** Phase 0 is now complete. The project is ready for Phase 1: Comparative Evolutionary Analysis (dN/dS estimation on kDNA-associated genes).