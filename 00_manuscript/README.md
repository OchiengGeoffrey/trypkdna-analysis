## Project Overview

This repository contains the genomic and transcriptomic analyses investigating kinetoplast DNA (kDNA) retention in dyskinetoplastic *Trypanosoma equiperdum* strains.

The project is organized into four phases:

- Phase 0: Genome validation (BUSCO, BLAST, SRA verification)
- Phase 1: Comparative genomics
- Phase 2: Transcriptomic analysis
- Phase 3: Integrated interpretation and manuscript preparation

# Manuscript: TeXstudio + RStudio Workflow

This manuscript uses two tools:
- **TeXstudio** (Windows) for LaTeX editing
- **RStudio** (Windows) for R analysis

## Quick Start

### 1. Clone to F: Drive (if not already done)

```bash
cd /mnt/f/PROJECTS
git clone https://github.com/OchiengGeoffrey/trypkdna-analysis.git
cd trypkdna-analysis
```

### 2. Open in RStudio

- File → Open Project
- Navigate to: `F:\PROJECTS\trypkdna-analysis`
- Select the `.Rproj` file
- Click Open

### 3. Open in TeXstudio

- File → Open
- Navigate to: `F:\PROJECTS\trypkdna-analysis\00_manuscript\latex\main.tex`
- Opens in editor

## Directory Structure
00_manuscript/
├── latex/
│   ├── main.tex
│   ├── chapters/
│   │   ├── 01_introduction.tex
│   │   ├── 02_methods.tex
│   │   ├── 03_results.tex
│   │   ├── 04_discussion.tex
│   │   └── 05_conclusion.tex
│   ├── figures/
│   ├── tables/
│   └── references.bib
│
└── analysis/
    ├── Phase0_Validation.Rmd
    ├── Phase1_Analysis.Rmd
    ├── Phase2_Analysis.Rmd
    └── Phase3_Analysis.Rmd

## Workflow: Phase 0 Example

### In RStudio:

1. Open `00_manuscript/analysis/Phase0_Validation.Rmd`
2. Click "Run All" (Ctrl+Alt+R) to execute all code chunks
3. This generates: `00_manuscript/latex/figures/busco_completeness.png`

### In TeXstudio:

1. Open `00_manuscript/latex/chapters/03_results.tex`
2. Add figure reference:
```latex
\begin{figure}[H]
\centering
\includegraphics[width=0.8\textwidth]{figures/busco_completeness.png}
\caption{BUSCO genome completeness}
\label{fig:busco}
\end{figure}
```
3. TeXstudio shows live PDF preview on the right

### In WSL Bash (for Git):

```bash
cd /mnt/f/PROJECTS/trypkdna-analysis

git status
git add 00_manuscript/
git commit -m "Phase 0: Added BUSCO visualization to manuscript"
git push origin main
```

## Saving Figures from RStudio

In your R Markdown code chunks:

```r
# After creating a plot:
ggsave("../latex/figures/plot_name.png", width=6, height=4, dpi=300)
```

This saves to the correct LaTeX figures folder.

## Git Integration

All git operations happen in **WSL bash terminal**:

```bash
cd /mnt/f/PROJECTS/trypkdna-analysis

# Check status
git status

# Stage changes
git add 00_manuscript/analysis/Phase0_Validation.Rmd
git add 00_manuscript/latex/figures/

# Commit
git commit -m "Phase 0 complete: BUSCO analysis and visualization"

# Push to GitHub
git push origin main
```

RStudio has a Git panel, but since you're working across Windows apps, bash is simpler.

## RStudio Tips

- **Terminal tab:** Tools → Terminal → New Terminal (gives you WSL bash inside RStudio)
- **Run chunks:** Ctrl+Enter (single chunk) or Ctrl+Alt+R (all chunks)
- **Knit to HTML:** Click "Knit" button (useful for checking formatting)

## TeXstudio Tips

- **Compile PDF:** F5 or Build → Build & View
- **Search:** Ctrl+F
- **Bibliography:** Tools → Rebuild Bibliography (if citations change)
- **Live preview:** Enable View → Sidebar (shows PDF on right)

## File Workflow Summary
RStudio (F:)

↓ (save .Rmd)

↓ (ggsave figures)

→ WSL bash (git add/commit)
TeXstudio (F:)

↓ (edit .tex, reference figures)

↓ (compile to PDF)

→ WSL bash (git add/commit)
GitHub

↑ (git push from WSL)

## Phase 1-3 Expansion

As you complete each phase:

1. **Write R analysis** in `analysis/Phase#_Analysis.Rmd`
2. **Generate figures** (saved to `latex/figures/`)
3. **Update LaTeX chapters** to include figures and results
4. **Commit to git** from WSL bash

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Can't find figures | Check path: `../latex/figures/filename.png` |
| PDF not updating in TeXstudio | File → Reload External Changed Files |
| Git command not found | Make sure you're in WSL bash, not Windows cmd |
| RStudio won't open project | Check that `.Rproj` file exists in root folder |

## Requirements

- **RStudio** (Windows) - v2024+ recommended
- **TeXstudio** (Windows)
- **TeX Live** (installed with TeXstudio, or separately)
- **WSL2 with Ubuntu** (for git commands)
- **Git** (installed in WSL)

## Next Steps

After Phase 0:
- [ ] Run Phase 1 analysis in RStudio
- [ ] Generate figures
- [ ] Add to LaTeX manuscript
- [ ] Update bibliography
- [ ] Commit and push