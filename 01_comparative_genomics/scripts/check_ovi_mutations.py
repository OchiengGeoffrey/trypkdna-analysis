#!/usr/bin/env python3
"""
Determine T. equiperdum OVI ATPase gamma mutation status.
Extracts CDS from BLAST hit region, reverse complements, translates,
and checks key positions from Dean et al. (2013) and Ridgway et al. (2026).

Phase 1.0A Diagnostic Tool
For one-off validation of a known full-length BLAST hit.

Mutation framework:
- Position 262: L262P (laboratory-derived escape route)
- Position 273: A273P (natural escape mutation, homozygous in BoTat 1.1)
- Position 281: A281del (natural escape mutation, heterozygous in T. evansi Type A)
- Position 282: M282F/W/Y (novel aromatic escape routes, Ridgway et al. 2026)
           or M282L (natural Type B variant, may be insufficient alone)

Position numbering verified against T. brucei TREU927 reference (UniProt A0A161CFW5).
"""
import sys
import os

CODON_TABLE = {
    'TTT':'F','TTC':'F','TTA':'L','TTG':'L',
    'CTT':'L','CTC':'L','CTA':'L','CTG':'L',
    'ATT':'I','ATC':'I','ATA':'I','ATG':'M',
    'GTT':'V','GTC':'V','GTA':'V','GTG':'V',
    'TCT':'S','TCC':'S','TCA':'S','TCG':'S',
    'CCT':'P','CCC':'P','CCA':'P','CCG':'P',
    'ACT':'T','ACC':'T','ACA':'T','ACG':'T',
    'GCT':'A','GCC':'A','GCA':'A','GCG':'A',
    'TAT':'Y','TAC':'Y','TAA':'*','TAG':'*',
    'CAT':'H','CAC':'H','CAA':'Q','CAG':'Q',
    'AAT':'N','AAC':'N','AAA':'K','AAG':'K',
    'GAT':'D','GAC':'D','GAA':'E','GAG':'E',
    'TGT':'C','TGC':'C','TGA':'*','TGG':'W',
    'CGT':'R','CGC':'R','CGA':'R','CGG':'R',
    'AGT':'S','AGC':'S','AGA':'R','AGG':'R',
    'GGT':'G','GGC':'G','GGA':'G','GGG':'G',
}
COMP = str.maketrans('ATGCatgcNn','TACGtacgNn')

def revcomp(seq):
    """Reverse complement a DNA sequence."""
    return seq.translate(COMP)[::-1]

def translate(seq):
    """Translate DNA sequence to protein using standard codon table."""
    prot = []
    for i in range(0, len(seq)-2, 3):
        codon = seq[i:i+3].upper()
        aa = CODON_TABLE.get(codon, 'X')
        prot.append(aa)
        if aa == '*':
            break
    return ''.join(prot)

def read_fasta(path):
    """Read FASTA file and return sequence (no header)."""
    with open(path) as f:
        seq = ''.join(l.strip() for l in f if not l.startswith('>'))
    return seq

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 check_ovi_mutations.py <input_fasta>")
        sys.exit(1)
    
    infile = sys.argv[1]
    outdir = os.path.dirname(infile)
    if not outdir:
        outdir = "."
    
    # Extract and process sequence
    seq = read_fasta(infile)
    cds = revcomp(seq)

    print(f"Extracted nt length:    {len(seq)}")
    print(f"CDS length (rc):        {len(cds)}  (expected: 915)")
    print(f"CDS divisible by 3:     {len(cds) % 3 == 0}")

    protein = translate(cds)
    print(f"Protein length:         {len(protein)}/305 aa  (expected: 305)")

    # LENGTH GUARD: Validate protein length before mutation checking
    if len(protein) < 282:
        print(f"\n{'='*70}")
        print(f"ERROR: Protein too short for mutation checking")
        print(f"{'='*70}")
        print(f"Expected minimum: 282 aa (to check position 282)")
        print(f"Observed: {len(protein)} aa")
        print(f"\nThis may indicate:")
        print(f"  - Truncation in assembly")
        print(f"  - Incorrect reading frame")
        print(f"  - Partial gene model")
        print(f"\nAction: Review the extracted sequence and BLAST alignment.")
        print(f"{'='*70}\n")
        sys.exit(1)

    # CHECK FOR INTERNAL STOP CODONS: Defensive programming
    if "*" in protein[:-1]:
        print(f"\nWARNING: Internal stop codon detected at position {protein.index('*') + 1}")
        print(f"This is biologically important and suggests potential sequencing error or pseudogenization.")

    # Reference: T. brucei TREU927 ATPase gamma (UniProt A0A161CFW5, Tb927.10.180)
    # 305 aa, Swiss-Prot reviewed, PDB 6F5D
    ref_first = "MSYQILRALS"
    ref_last  = "KQFETLKQLL"
    print(f"\nFirst 10 aa:  {protein[:10]}")
    print(f"Last 10 aa:   {protein[-10:]}")
    print(f"Ref first 10: {ref_first}")
    print(f"Ref last 10:  {ref_last}")

    # Key positions (Dean et al. 2013, Table S1; Ridgway et al. 2026)
    # Position numbering verified against T. brucei TREU927 reference (UniProt A0A161CFW5)
    positions = {
        262: ("L262P escape site", "L"),       # Lab-derived escape route
        273: ("A273P escape site", "A"),       # Natural escape mutation
        281: ("A281del escape site", "A"),     # Natural escape mutation
        282: ("M282 escape hotspot", "M"),     # Check for F/W/Y aromatic and L variants
    }

    print(f"\n{'='*70}")
    print(f"  KEY MUTATION POSITIONS")
    print(f"  (Dean et al. 2013, Table S1; Ridgway et al. 2026)")
    print(f"{'='*70}")
    for pos, (desc, expected_aa) in positions.items():
        aa = protein[pos - 1]
        match = "✓ MATCH" if aa == expected_aa else f"✗ DIFFERS (observed {aa}, expected {expected_aa})"
        print(f"  Pos {pos}: {aa}  — {desc}")
        print(f"           {match}")

    # Determine mutation status
    p262 = protein[261]  # Position 262 (0-indexed: 261)
    p273 = protein[272]  # Position 273 (0-indexed: 272)
    p281 = protein[280]  # Position 281 (0-indexed: 280)
    p282 = protein[281]  # Position 282 (0-indexed: 281)

    print(f"\n{'='*70}")
    print(f"  MUTATION STATUS VERDICT")
    print(f"{'='*70}")

    # Comprehensive mutation interpretation
    if p262 == 'L' and p273 == 'A' and p281 == 'A' and p282 == 'M':
        status = "WILD-TYPE"
        implication = "OVI lacks all currently recognized ATPase γ escape mutations examined here (L262P, A273P, A281del, M282F/W/Y/L)"
        prediction = "Consistent with genetic constraint — OVI trapped below kDNA-independence threshold"
        model_support = "Consistent with Model 1 (genetic constraint hypothesis)"
    elif p262 == 'P':
        status = "L262P MUTANT"
        implication = "OVI carries laboratory-validated escape mutation"
        prediction = "Suggests independent adaptation route to kDNA independence"
        model_support = "Contradicts genetic constraint hypothesis"
    elif p273 == 'P':
        status = "A273P MUTANT"
        implication = "OVI carries same compensatory mutation as T. evansi/BoTat"
        prediction = "Suggests capacity for kDNA independence, but phenotype is dyskinetoplastic"
        model_support = "Requires investigation of other genes (e.g., UMSBP, other ATPase subunits)"
    elif p281 != 'A':
        status = f"POSITION_281_VARIANT ({p281})"
        implication = f"Residue 281 differs from reference (observed {p281}, expected A). Alignment required to determine whether this represents A281del or another variant."
        prediction = "Intermediate evolutionary state or sequencing error"
        model_support = "Requires Phase 1.0B MAFFT alignment for confirmation"
    elif p282 in ['F', 'W', 'Y']:
        status = f"M282{p282} AROMATIC ESCAPE MUTATION"
        implication = f"OVI carries novel aromatic substitution at M282 (Ridgway et al. 2026)"
        prediction = f"Aromatic residue at position 282 may enable kDNA independence"
        model_support = "Unexpected — OVI not previously reported to carry aromatic M282 variant"
    elif p282 == 'L':
        status = "M282L TYPE-B VARIANT"
        implication = "OVI carries Type B compensatory mutation (natural in T. evansi Type B)"
        prediction = "Type B variant may be insufficient alone for full kDNA independence"
        model_support = "Suggests intermediate compensation; requires validation"
    else:
        status = f"UNEXPECTED ({p262}{262}/{p273}{273}/{p281}{281}/{p282}{282})"
        implication = "Unknown mutation combination not in literature"
        prediction = "Cannot predict a priori"
        model_support = "Investigate further — verify frame, sequence quality, and alignment"

    print(f"  Status:       {status}")
    print(f"  Implication:  {implication}")
    print(f"  Prediction:   {prediction}")
    print(f"  Model:        {model_support}")
    print(f"\n  Note: This is a diagnostic call based on direct residue inspection.")
    print(f"  A281del cannot be definitively confirmed without alignment (see Phase 1.0B).")
    print(f"{'='*70}\n")

    # Write output files
    cds_path = os.path.join(outdir, "ovi_atpase_gamma_cds.fasta")
    prot_path = os.path.join(outdir, "ovi_atpase_gamma_protein.fasta")

    with open(cds_path, 'w') as f:
        f.write(f">T_equiperdum_OVI|ATPase_gamma|CDS|mutation_{status.replace(' ','_').replace('/','_')}\n{cds}\n")
    with open(prot_path, 'w') as f:
        f.write(f">T_equiperdum_OVI|ATPase_gamma|protein|mutation_{status.replace(' ','_').replace('/','_')}\n{protein}\n")

    print(f"  Output files:")
    print(f"    {cds_path}")
    print(f"    {prot_path}\n")

if __name__ == '__main__':
    main()
