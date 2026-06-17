#!/usr/bin/env bash

set -euo pipefail

mkdir -p data/genomes/blastdb

makeblastdb \
    -in data/genomes/T_equiperdum_OVI.fasta \
    -dbtype nucl \
    -out data/genomes/blastdb/T_equiperdum_OVI_blastdb \
    -title "T. equiperdum OVI BLAST database"
