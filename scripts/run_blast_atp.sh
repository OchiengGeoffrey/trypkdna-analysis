#!/usr/bin/env bash

set -euo pipefail

mkdir -p 00_preflight/results/blast

tblastn \
    -query data/genomes/Tbrucei_ATPase_gamma.fasta \
    -db data/genomes/blastdb/T_equiperdum_OVI_blastdb \
    -evalue 1e-5 \
    -outfmt "6 qseqid sseqid pident length evalue bitscore qstart qend sstart send" \
    -max_target_seqs 5 \
    -num_threads 4 \
    > 00_preflight/results/blast/ATPase_gamma_tblastn.tsv
