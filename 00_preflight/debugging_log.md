
## CRITICAL CORRECTION: ATPase γ Reference Sequence (June 23, 2026)

**Issue:** Reference FASTA file contained Q57XH6 (RNA-binding protein), not ATP synthase γ subunit

**Discovery process:**
1. Downloaded Tbrucei_ATPase_gamma.fasta from unknown source
2. Used Q57XH6 as BLAST query without verifying UniProt annotations
3. Retrieved BLAST hit TcCLB.503733.50 (T. cruzi pseudogene) — red flag
4. Checked Q57XH6 GO annotations → mRNA binding, RNA binding, RNA processing
5. Realized: Wrong protein entirely

**Root cause:** Q57XH6 entry was retrieved from UniProt search for "ATPase gamma" 
but actually codes RNA-binding protein. Annotation mismatch: gene name vs. actual function.

**Resolution:**
- Deleted incorrect file completely
- Downloaded correct reference: A0A161CFW5 (Swiss-Prot reviewed)
- Verified: 305 aa length, ATP synthase subunit gamma mitochondrial, PDB 6F5D
- Timing: BEFORE Phase 1 BLAST execution — no downstream work invalidated

**Lesson learned:** 
Always independently verify protein function via:
1. GO annotations (molecular function, biological process)
2. UniProtKB status (Swiss-Prot reviewed vs. TrEMBL unreviewed)
3. Keywords and function section
4. PubMed citations for functional studies

Never assume gene name == correct protein identity.

