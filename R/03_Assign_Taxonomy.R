# SETUP ####

## packages ####
library(tidyverse)
library(dada2)

## functions ####
source("./R/functions.R")

# set taxonomy database path
SSU_DB <- "./taxonomy/Eukaryome_General_SSU_v1.8_reformatted_VTX.fasta.gz"

# get possible asv table files
# add more as necessary, if doing multiple runs
run_1_ssu <- "./data/ASV_Tables/Run_1_SSU_ASV_Table.RDS"

if(file.exists(SSU_DB)){
  for(run in ls(pattern="run_._")){ #written as a loop in case you have multiple ASV tables above
    x <- get(run)
    if(file.exists(x)){
      asv <- readRDS(x)
      outfile <- str_replace(x,"_ASV","_Taxonomy")
      
      tax <- assign_taxonomy_to_asv_table(asv.table=asv,
                                          tax.database=ifelse(grepl("_SSU_ASV_Table",x),SSU_DB,ITS_DB), # deciding which db to use based on filename
                                          multithread=parallel::detectCores(), # not tested on windows
                                          random.seed=666,
                                          try.rc = TRUE, # also try reverse complement?
                                          min.boot=50)
      # export as RDS
      saveRDS(tax,outfile)
      
    } else {next}
  }
} else {
  stop("Taxonomy files are missing or not specified correctly.")
}


