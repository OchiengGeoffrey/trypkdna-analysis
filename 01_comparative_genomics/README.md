# Phase 1: Comparative Genomics and dN/dS Analysis

## Project Overview

This directory contains all Phase 1 analysis for the T. equiperdum kDNA retention project, investigating why OVI retains partial kinetoplast DNA (kDNA) while T. evansi has lost it completely.

**Central Question:** Does OVI's kDNA retention reflect genetic constraint (lack of compensatory ATPase γ mutations) or other mechanisms?

---

## Directory Structure
01_comparative_genomics/
├── README.md                    # This file
├── scripts/                     # Analysis scripts
│   ├── extract_atpase_gamma.sh  # BLAST-based CDS extraction
│   ├── consolidate_sequences.py # Standardize headers, combine FASTAs
│   └── validate_sequences.py    # QC for length, frame, stops
├── data/
│   └── sequences/               # Extracted ATPase γ sequences
│       ├── *_ATPase_gamma.cds   # Coding sequences (nucleotide)
│       ├── _ATPase_gamma.faa   # Protein sequences (amino acid)
│       └── all_8_ATPase_gamma. # Consolidated multi-species files
├── results/
│   ├── blast/                   # BLAST extraction results
│   ├── alignment/               # MAFFT alignments
│   ├── codeml/                  # CodeML analysis outputs
│   └── figures/                 # Publication-ready figures
└── logs/                        # Execution logs and summaries

---

## Phase 1 Progress

### Completed Extractions (5/8)

| Strain | Method | Status | Size | Identity | Notes |
|--------|--------|--------|------|----------|-------|
| T. brucei TREU927 | RefSeq tblastn | ✅ | 915 bp | 99.344% | Kinetoplastic reference |
| T. equiperdum OVI | RefSeq tblastn | ✅ | 915 bp | 99.344% | Focal strain, wild-type ATPase γ |
| T. equiperdum IVM-t1 | RefSeq tblastn | ✅ | 915 bp | 100.0% | Type B-associated, wild-type-like |
| T. evansi STIB805 | RefSeq tblastn | ✅ | 912 bp | 99.016% | Type A, A281del confirmed |
| T. equiperdum BoTat | SRA read mapping | ✅ | 915 bp | - | Dyskinetoplastic, A273P confirmed |

### In Progress (3/8)

| Strain | Method | Status | Notes |
|--------|--------|--------|-------|
| T. evansi MU09 | SRA read mapping | ⏳ | Type A, expected A281del |
| T. evansi MU10 | SRA read mapping | ⏳ | Type B, expected M282L |
| RoTat 1.2 | SRA read mapping | ⏳ | T. evansi (phylogenetically), classification TBD |

---

## Key Results So Far

### ATPase γ Mutation Pattern
Kinetoplastic:
TREU927 → L262/A273/A281/M282 (wild-type)
Dyskinetoplastic (partial kDNA retention):
OVI     → L262/A273/A281/M282 (wild-type, NO compensatory mutations)
IVM-t1  → L262/A273/A281/M282 (wild-type-like)
BoTat   → L262/P273/A281/M282 (A273P present)
Akinetoplastic (complete kDNA loss):
STIB805 → L262/A273/A281del/M282 (Type A escape mutation)
MU09    → Expected A281del (Type A)
MU10    → Expected M282L (Type B)
RoTat   → Classification pending

### Interpretation

OVI's wild-type ATPase γ status despite dyskinetoplasty directly supports the **Genetic Constraint Model**: OVI lacks the compensatory mutations that enabled escape to akinetoplasty in other lineages.

---

## Phase 1 Steps

### ✅ Steps 1-4: ATPase γ Extraction and Validation
- Extract CDS from RefSeq assemblies (tblastn)
- Extract CDS from SRA reads (BWA read mapping + bcftools consensus)
- Validate: length, frame, start/stop codons
- Consolidate into multi-species FASTA files

### ⏳ Step 5: Codon-Aware Alignment
- Protein alignment (MAFFT)
- Back-translate to codon alignment (pal2nal or translatorx)
- Output: PHYLIP format for CodeML

### ⏳ Steps 6-12: Evolutionary Analysis
- Build species tree (Newick format)
- Run CodeML models:
  - M0: one-ratio (null)
  - M2: two-ratio (foreground vs. background)
  - M3: free-ratio (per-branch ω)
  - M4: OVI foreground (OVI vs. all others)
- Calculate dN/dS (ω) estimates
- Test competing models via LRT

---

## Tools Used

### Sequence Extraction
- `tblastn` - BLAST protein-to-nucleotide search
- `blastdbcmd` - Extract genomic regions from BLAST hits
- `bwa mem` - Map Illumina reads to reference
- `samtools` - BAM processing and indexing
- `bcftools` - Variant calling and consensus generation

### Sequence Analysis
- `MAFFT` - Multiple sequence alignment
- `pal2nal.pl` - Codon-aware alignment
- `PAML (codeml)` - Codon substitution model analysis

### Validation
- Custom Python scripts (pure Python, no external dependencies)

---

## Reference Sequences

**ATPase γ Subunit (Tb927.10.180):**
- UniProt: A0A161CFW5
- Gene: Tb927.10.180 (T. brucei TREU927)
- Length: 305 aa / 915 bp
- Structure: PDB 6F5D (F1-ATPase complex)

**Known Mutations (Dean et al. 2013, Ridgway et al. 2026):**
- L262P: Lab-derived escape route
- A273P: Natural escape mutation (BoTat, some T. evansi)
- A281del: Type A escape mutation (T. evansi STIB805, MU09)
- M282L/M282F/W/Y: Type B escape mutations (T. evansi MU10, etc.)

---

## SRA Accessions

| Strain | SRR | Reads | Total Size |
|--------|-----|-------|-----------|
| BoTat | SRR5307576 | 19.5M | 4.8 GB |
| MU09 | SRR5307968 | 31.8M | 8.4 GB |
| MU10 | SRR5307967 | 37.2M | 10.0 GB |
| RoTat 1.2 | SRR5307574 | ~20M | 4.8 GB |

---

## RefSeq Accessions

| Strain | Accession | Source |
|--------|-----------|--------|
| T. brucei TREU927 | GCA_000002445.1 | NCBI |
| T. equiperdum OVI | GCA_001457755.2 | NCBI |
| T. equiperdum IVM-t1 | GCA_003543875.1 | NCBI |
| T. evansi STIB805 | GCA_917563935.1 | NCBI |

---

## Hypothesis Framework

### Model 1: Genetic Constraint
OVI retains kDNA because it lacks the compensatory ATPase γ mutations that enable other lineages to escape mitochondrial dependence.

**Prediction:** OVI shows strong purifying selection (low dN/dS) at ATPase γ; no escape mutations present.

**Status:** Supported by Phase 1.0A results (OVI is wild-type).

### Model 2: Relaxed Selection
OVI's kDNA retention reflects evolutionary lag; gene is under relaxed selection.

**Prediction:** OVI shows elevated dN/dS; no specific functional constraint.

**Status:** To be tested in Phase 1 dN/dS analysis.

### Model 3: Functional Threshold
Only a minimal subset of kDNA genes remain essential.

**Prediction:** Mixed ω patterns; some genes highly conserved, others relaxed.

**Status:** To be tested in Phase 1 multi-gene analysis.

---

## Contact & Citation

**Project:** T. equiperdum kDNA Retention Mechanistic Investigation
**GitHub:** github.com/OchiengGeoffrey/trypkdna-analysis
**Author:** Geoffrey Ochieng
**Date:** 2024-2025

---

## Version History

| Version | Date | Status | Notes |
|---------|------|--------|-------|
| 1.0 | 2025-07-06 | In Progress | Phase 1 Steps 1-4 complete, Steps 5-12 pending |

