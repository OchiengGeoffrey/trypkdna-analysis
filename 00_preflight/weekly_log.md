# Weekly Log

## Week 1 (Start: [29-04-2026])

**Completed:**
- [x] Conda environment successfully created using mamba
- [x] Resolved Python compatibility issues (3.13 → 3.11.9)
- [x] Verified execution of core tools:
  - python, snakemake, R, mafft, busco
- [x] Confirmed correct environment activation (`which python` check)

**Blockers:**
- None currently

**Key Lesson Learned:**
- Removing strict version pinning can allow the solver to find a better compatible environment
- Python version is often constrained by package ecosystem, not user preference
- mamba significantly improves dependency resolution for bioinformatics environments