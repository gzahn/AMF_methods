#!/bin/bash


# Tested on Ubuntu 22.04 and RedHat 8.1.8 Linux systems


# Build taxonomic databases via bash script and supplemental R script found in ./taxonomy
cd ./taxonomy
./build_taxonomy_database.sh
cd -

# Run R pipeline
Rscript R/01_Trim_Adaptors_and_Flanking.R
Rscript R/02_Build_ASV_Tables.R
Rscript R/03_Assign_Taxonomy.R
Rscript R/04_Build_Physeq_Objects.R
