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