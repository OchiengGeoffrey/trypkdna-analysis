#!/bin/bash
# Extracts ATPase gamma CDS from an assembled genome using tBLASTn
# Usage: ./extract_atpase_gamma.sh <blastdb_path> <species_name> <output_dir>

set -euo pipefail

DB_PATH=$1
SPECIES=$2
OUTDIR=$3
QUERY="data/genomes/Tbrucei_ATPase_gamma.fasta"

echo "=== Extracting ATPase gamma from ${SPECIES} ==="

# Run tBLASTn
tblastn \
  -query "${QUERY}" \
  -db "${DB_PATH}" \
  -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore" \
  -evalue 1e-10 \
  -max_target_seqs 3 \
  -num_threads 4 \
  -out "${OUTDIR}/${SPECIES}_tblastn.tsv"

# Parse best hit
BEST=$(head -1 "${OUTDIR}/${SPECIES}_tblastn.tsv")

SEQID=$(echo "${BEST}" | awk '{print $2}')
PIDENT=$(echo "${BEST}" | awk '{print $3}')
ALEN=$(echo "${BEST}" | awk '{print $4}')
SSTART=$(echo "${BEST}" | awk '{print $9}')
SEND=$(echo "${BEST}" | awk '{print $10}')
EVALUE=$(echo "${BEST}" | awk '{print $11}')
BITSCORE=$(echo "${BEST}" | awk '{print $12}')

echo "  Contig: ${SEQID}"
echo "  Identity: ${PIDENT}%"
echo "  Alignment length: ${ALEN} aa"

# DEFENSIVE CHECK: Ensure hit is actually ATPase gamma (long enough, high enough identity)
if (( $(echo "$ALEN < 250" | bc -l) )); then
    echo "[ERROR] Hit too short (${ALEN} aa). Likely wrong gene or pseudogene."
    exit 1
fi
if (( $(echo "$PIDENT < 90.0" | bc -l) )); then
    echo "[ERROR] Identity too low (${PIDENT}%). Likely wrong gene."
    exit 1
fi

# Extract region
if [ "$SSTART" -gt "$SEND" ]; then
    TEMP_START=$SEND
    TEMP_END=$SSTART
    STRAND="minus"
else
    TEMP_START=$SSTART
    TEMP_END=$SEND
    STRAND="plus"
fi

blastdbcmd -db "${DB_PATH}" -entry "${SEQID}" -range "${TEMP_START}-${TEMP_END}" \
  -out "${OUTDIR}/${SPECIES}_region_temp.fasta"

# Reverse complement if minus strand
if [ "$STRAND" = "minus" ]; then
    python3 -c "
comp = str.maketrans('ATGCatgcNn','TACGtacgNn')
with open('${OUTDIR}/${SPECIES}_region_temp.fasta') as f:
    lines = f.readlines()
seq = ''.join(l.strip() for l in lines if not l.startswith('>'))
rc = seq.translate(comp)[::-1]
# DEFENSIVE CHECK: Ensure CDS is divisible by 3
if len(rc) % 3 != 0:
    print(f'[ERROR] CDS length {len(rc)} is not divisible by 3.')
    exit(1)
with open('${OUTDIR}/${SPECIES}_atpase_gamma_cds.fasta','w') as f:
    f.write(f'>${SPECIES}|ATPase_gamma|CDS|from_${SEQID}\n{rc}\n')
print(f'CDS length: {len(rc)} nt ({len(rc)//3} aa)')
"
else
    python3 -c "
with open('${OUTDIR}/${SPECIES}_region_temp.fasta') as f:
    lines = f.readlines()
seq = ''.join(l.strip() for l in lines if not l.startswith('>'))
if len(seq) % 3 != 0:
    print(f'[ERROR] CDS length {len(seq)} is not divisible by 3.')
    exit(1)
with open('${OUTDIR}/${SPECIES}_atpase_gamma_cds.fasta','w') as f:
    f.write(f'>${SPECIES}|ATPase_gamma|CDS|from_${SEQID}\n{seq}\n')
print(f'CDS length: {len(seq)} nt ({len(seq)//3} aa)')
"
fi

# Clean up temp
rm -f "${OUTDIR}/${SPECIES}_region_temp.fasta"

echo "=== Done: ${OUTDIR}/${SPECIES}_atpase_gamma_cds.fasta ==="
