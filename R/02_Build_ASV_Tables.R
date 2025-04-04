# SETUP ####

############################################
# JUST DO THIS FOR RUN 7 THIS TIME
# Make sure it's finding all the files
# probably need some code to update metadata?



# packages
library(tidyverse)
library(phyloseq)
library(dada2)
library(decontam)

# functions
source("./R/functions.R")

# metadata
meta <- readRDS("./data/full_clean_metadata.RDS")
# meta <- readRDS("./data/cutadapt_metadata.RDS")
# writeLines(c(meta$fwd_filepath,meta$rev_filepath),"./data/dartfs_paths.txt")
# writeLines(meta$rev_filepath,"./data/dartfs_rev_paths.txt")
if(any(meta$fwd_filepath == meta$rev_filepath)){
  meta$fwd_filepath[which(meta$fwd_filepath == meta$rev_filepath)]
  stop("Some filepaths are duplicated!")
}

# add cutadapt file paths to metadata
cutadapt_dir <- list.dirs(full.names = TRUE)[grep("cutadapt$",list.dirs(full.names = TRUE))]
filtN_dir <- list.dirs(full.names = TRUE)[grep("filtN$",list.dirs(full.names = TRUE))]
meta$cutadapt_fwd_paths <- paste0(cutadapt_dir,"/",meta$library_id,"_cutadapt_fwd.fastq.gz")
meta$cutadapt_rev_paths <- paste0(cutadapt_dir,"/",meta$library_id,"_cutadapt_rev.fastq.gz")

# subset metadata to samples clearly present in cutadapt (those that survived)
meta <- meta[file.exists(meta$cutadapt_fwd_paths),]


# list of sequencing runs
all_runs <- meta$run_id %>% as.character() %>% unique
all_runs <- all_runs[!is.na(all_runs)]


# RUN ON ALL SSU DATA ####
for(seqrun in all_runs){
  
  # make sure these seq runs actually have samples from that amplicon present
  # for each iteration, only run dada2 on a single sequencing run
  # metadata should have a column named "amplicon" that is filled with "SSU"
  # This can be altered for ITS as well on mixed sequencing runs, etc.
  n.samples.in.run <- sum(meta[['run_id']] == seqrun & meta[['amplicon']] == "SSU")
  if(n.samples.in.run > 0){
    build_asv_table(metadata=meta, # metadata object for multi-seq-run samples; must contain "run" column and fwd/rev filepath columns
                    run.id.colname = "run_id", # name of column in metadata indicating which sequencing run a sample comes from
                    run.id = seqrun, # the run ID to perform function on, from the run.id.colname column. Enter as a character, e.g., "1"
                    amplicon.colname = "amplicon", # column name that contains the amplicon info for each sample
                    amplicon = "SSU", # which amplicon from the run are you processing (ITS, SSU, LSU, etc)?
                    sampleid.colname = "library_id", # column name in metadata containing unique sample identifier
                    fwd.fp.colname = "cutadapt_fwd_paths", # name of column in metadata indicating fwd filepath to trimmed data (e.g., cutadapt)
                    rev.fp.colname = "cutadapt_rev_paths", # name of column in metadata indicating rev filepath to trimmed data (e.g., cutadapt)
                    fwd.pattern = "_R1_", # pattern in filepath column indicating fwd reads (to be safe)
                    rev.pattern = "_R2_", # pattern in filepath column indicating rev reads (to be safe),
                    maxEE = c(3,5), # max expected errors for filtration step of dada2 (for single-end cases like ITS, will default to maxEE=2)
                    trim.right=c(20,20), # amount to trim off of 3' end after quality truncation
                    truncQ = 2, # special value denoting "end of good quality sequence"
                    rm.phix = TRUE, # remove phiX sequences?
                    compress = TRUE, # gzip compression of output?
                    multithread = (parallel::detectCores() -1), # how many cores to use? Set to FALSE on windows
                    single.end = FALSE, # use only forward reads and skip rev reads and merging?
                    filtered.dir = "filtered", # name of output directory for all QC filtered reads. will be created if not extant. subdirectory of trimmed filepath
                    asv.table.dir = "./data/ASV_Tables", # path to directory where final ASV table(s) will be saved
                    random.seed = 666 # to make this reproducible
    )
  } else {break}
}
