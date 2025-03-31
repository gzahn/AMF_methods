# SETUP ####

## Packages ####
library(tidyverse); packageVersion('tidyverse')
library(dada2); packageVersion("dada2")
library(purrr); packageVersion("purrr")
library(Biostrings); packageVersion("Biostrings")
library(ShortRead); packageVersion("ShortRead")
library(parallel); packageVersion("parallel")

## Functions ####
source("./R/functions.R")

## Data ####
metadata <- readRDS("./data/full_clean_metadata.RDS")

# clean up file paths to match project structure
metadata$fwd_filepath <- paste0("./data/raw/",basename(metadata$fwd_filepath))
metadata$rev_filepath <- paste0("./data/raw/",basename(metadata$rev_filepath))


## primer sequences ####

# SSU
WANDAf <- "CAGCCGCGGTAATTCCAGCT"  
AML2r <- "GAACCCAAACACTTTGGTTTCC"  
# ITS1
ITS1f <- "CTTGGTCATTTAGAGGAAGTAA" 
ITS2r <- "GCTGCGTTCTTCATCGATGC" 

# get sample names from filenames
# you may have to alter, based on the structure of your file names
fwd_names <- basename(metadata$fwd_filepath) %>% str_split("_S") %>% map_chr(1)
# create new file names, based on sample names, for filtered files
fwd_filtn_names <- file.path("./data/raw/filtN",paste(fwd_names,metadata$amplicon,"filtN_fwd.fastq.gz",sep="_"))
rev_filtn_names <- file.path("./data/raw/filtN",paste(fwd_names,metadata$amplicon,"filtN_rev.fastq.gz",sep="_"))

# RUN CUTADAPT ####

## On SSU Samples ####
remove_primers(metadata=metadata, # metadata object for multi-seq-run samples; must contain "run" column and fwd/rev filepath columns
               # if you only have one sequencing run for this project, this function still expects a "run" column
               # so add that column to your metadata and mark everything as "1"
               amplicon.colname = "amplicon", # column name that contains the amplicon info for each sample
               amplicon = "SSU", # which amplicon from the run are you processing (ITS, SSU, or LSU)?
               sampleid.colname = "library_id", # column name in metadata containing unique sample identifier (sample name)
               fwd.fp.colname = "fwd_filepath", # name of column in metadata indicating fwd filepath to raw data
               rev.fp.colname = "rev_filepath", # name of column in metadata indicating rev filepath to raw data
               fwd_pattern="_R1_", # the pattern in your filenames that denotes a forward read
               rev_pattern="_R2_", # the pattern in your filenames that denotes a reverse read
               fwd_primer=WANDAf, # the forward primer to find and remove
               rev_primer=AML2r, # the reverse primer to find and remove
               multithread=parallel::detectCores()-1) # not tested on Windows

