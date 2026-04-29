# T. equiperdum kDNA Project – AI Context Card

**Project Phase:** 0 – Pre-flight Validation  
**Current Task:** Environment validated; ready to run BUSCO, BLAST, and SRA checks  
**Time Spent:** Setup complete 
**Date reported:** [29-04-2026] 

## What I'm Trying to Do
Validate the computational environment and confirm that all required bioinformatics tools run correctly before starting analysis.

## What I Expected
A working conda environment with all tools installed and executable.

## What Actually Happened
Initial environment creation failed due to incompatibility between conda and Python 3.13. After downgrading base Python and switching to mamba, the environment was successfully created.

The solver selected Python 3.11.9 (after removing strict version pinning), and all required tools installed and executed correctly.

## What I Already Tried
- Installed Miniconda and configured channels (conda-forge, bioconda)
- Installed mamba for faster dependency resolution
- Attempted environment creation with Python 3.13 → failed
- Downgraded base Python to 3.10
- Removed strict Python pinning from environment.yml
- Recreated environment using mamba
- Verified tool availability and execution:
  - python 3.11.9
  - snakemake 9.19.0
  - R 4.3.0
  - mafft v7.526
  - busco 6.0.0

## What Kind of Help I Need
- Engineer: troubleshooting if BUSCO/BLAST/SRA fail
- PI: interpreting biological results from validation

## Relevant Files
- environment.yml
- environment.lock.yml (to be generated)
