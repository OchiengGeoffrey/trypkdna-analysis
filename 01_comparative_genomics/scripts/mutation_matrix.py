from Bio import AlignIO
import pandas as pd

alignment = AlignIO.read(
    "01_comparative_genomics/results/alignment/all_8_protein_aligned.faa",
    "fasta"
)

target_positions = [262, 273, 281, 282]

# Find TREU927 reference sequence
treu = None
for rec in alignment:
    if "TREU927" in rec.id:
        treu = rec
        break

if treu is None:
    raise ValueError("TREU927 sequence not found")

# Map biological positions -> alignment columns
mapping = {}

ref_pos = 0
for aln_pos, aa in enumerate(str(treu.seq)):
    if aa != "-":
        ref_pos += 1
        if ref_pos in target_positions:
            mapping[ref_pos] = aln_pos

print("Reference position mapping:")
for k, v in mapping.items():
    print(f"{k} -> alignment column {v+1}")

rows = []

for rec in alignment:

    row = {"Strain": rec.id}

    for pos in target_positions:
        aln_pos = mapping[pos]
        row[str(pos)] = str(rec.seq[aln_pos])

    # MU10 heterozygous M282L variant
    if rec.id == "T_evansi_MU10":
        row["282"] = "M*"

    rows.append(row)

df = pd.DataFrame(rows)

print("\nMutation Matrix:\n")
print(df.to_string(index=False))

outfile = (
    "01_comparative_genomics/results/alignment/"
    "ATPase_gamma_mutation_matrix.csv"
)

df.to_csv(outfile, index=False)

print(f"\nSaved to:\n{outfile}")

print("""
Footnote:
* T. evansi MU10 carries a heterozygous M282L variant
  (GT=0/1; AD=45,32; DP=81) detected in the VCF.
  The consensus sequence used for phylogenetic analysis
  retained the reference methionine residue.
""")