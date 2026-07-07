#!/usr/bin/env python3
"""Extract specific amino acid positions from a FASTA protein sequence."""
import sys

def read_fasta_protein(path):
    """Read protein FASTA and return sequence (no header)."""
    with open(path) as f:
        seq = ''.join(l.strip() for l in f if not l.startswith('>'))
    return seq

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 extract_positions.py <protein_fasta>")
        sys.exit(1)
    
    fasta_file = sys.argv[1]
    protein = read_fasta_protein(fasta_file)
    
    positions_of_interest = [262, 273, 281, 282]
    
    print(f"File: {fasta_file}")
    print(f"Total length: {len(protein)} aa\n")
    print("Position Residues:")
    print("-" * 40)
    
    for pos in positions_of_interest:
        if pos <= len(protein):
            residue = protein[pos - 1]  # Convert to 0-indexed
            context_start = max(0, pos - 4)
            context_end = min(len(protein), pos + 3)
            context = protein[context_start:context_end]
            print(f"Pos {pos}: {residue} (context: {context})")
        else:
            print(f"Pos {pos}: OUT OF RANGE (protein only {len(protein)} aa)")
    
    print("\n" + "=" * 40)
    print("Expected (T. brucei TREU927 wild-type):")
    print("  262: L (Leucine)")
    print("  273: A (Alanine)")
    print("  281: A (Alanine)")
    print("  282: M (Methionine)")

if __name__ == '__main__':
    main()
