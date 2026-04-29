## [29-04-2026] – Python Version Strategy

**Decision:** Removed strict Python version pinning from environment.yml and allowed the solver to determine a compatible version (resolved to Python 3.11.9).

**Reasoning:** Initial attempts with Python 3.13 failed due to conda incompatibility. Python 3.10 introduced dependency conflicts. Allowing flexibility enabled mamba to resolve a fully compatible environment including Bioconductor and bioinformatics tools.

**Outcome:** Stable environment created; all tools installed and executed successfully.