
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


---

## Phase 0 BLAST Re-validation COMPLETE: A0A161CFW5 Confirms Correct Ortholog (June 23, 2026)

**Result:**
Query:    sp|A0A161CFW5|ATPG_TRYBB (ATP synthase gamma, mitochondrial)

Subject:  CZPT02001535.1 (T. equiperdum OVI genome contig)

Identity: 99.344% (305/305 aa)

Gaps:     0

E-value:  0.0 (extremely significant)

Bit score: 625 (excellent)

**Comparison: Original (Q57XH6, wrong) vs. Corrected (A0A161CFW5, correct):**
- Wrong gene: CZPT02001112.1, 97.806% identity, 319 aa
- Correct gene: CZPT02001535.1, 99.344% identity, 305 aa ← CORRECT LENGTH
- Improvement: Higher identity, correct length (319→305 explains misalignment with wrong gene)

**Conclusion:**
Phase 0 BLAST validation now PASSED with correct reference. 
ATP synthase γ subunit (A0A161CFW5) ortholog is CONFIRMED present in T. equiperdum OVI.
Ready to proceed to Phase 1 Comparative Genomics.

