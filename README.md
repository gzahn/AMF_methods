# AMF_methods

Code to process AMF SSU/LSU metabarcoding data


Full pipeline can be run in bash via:

```./pipeline.sh```

...once you have your metadata and sequence data in place, of course.

Tested on Ubuntu 22.04 and Red Hat 8.10 Linux systems using R v 4.4.0


# Pipeline Steps:

  **0. Submit your raw metabarcode data to the Sequence Read Archive.**
  
Don't be lazy. Do it now. Embargo it if you like, but get it done. Only then is it time to play with your data!

  **1. Install required R packages**
  
  - Open the R Project file in RStudio or Positron (This will force all file paths to be relative to this directory)
  - Install/Update any packages you don't have yet
  - Install the ```cutadapt``` command-line software
    - For Debian-based Linux distributions, this is as easy as: ```sudo apt install cutadapt```

    ```
    cran_packages <- c("tidyverse","dada2","decontam","phyloseq")
    github_packages <- c("gzahn/mycobank")

    install.packages(cran_packages,dependencies = TRUE)

    if (!requireNamespace("devtools", quietly = TRUE))
      install.packages("devtools")

    devtools::install_github(github_packages)

    ```

  **2. Build the SSU & ITS taxonomy databases**

  This will download the Eukaryome databases, format them for DADA2 classification, and append the Marjaam VTX taxa to the SSU database. Fungal names are automatically checked against the latest synonym database from MycoBank and updated to current names.
  
  - Run the following terminal commands within your main project directory:
  
     ```
     cd ./taxonomy/
     ./build_taxonomy_database.sh
     cd -
     ```
  - This shell script will also call ```./taxonomy/format_maarjAM.R``` to combine the maarjAM VTX database with the Eukaryome SSU and ITS databases.
  - When working with SSU, the database you most likely want to use is: ```Eukaryome_General_SSU_v1.9.4_reformatted_VTX.fasta.gz```
  - This is the current version as of this writing. Script can be easily updated to point to newer Eukaryome versions if needed.   
  **3. Prepare your project data and metadata in reasonable file paths within the project**
  
  - Copy your raw sequence data into the ```./data/seq``` directory
  - Add your cleaned metadata into the ```./data``` directory (example included)
  
  **4. ```R/01_Trim_Adaptors_and_Flanking.R```**

  This script trims Illumina adaptors/primers from all reads. Your metadata sheet should have columns called "fwd_filepath" and "rev_filepath" containing the files names for forward and reverse Illumina reads, respectively. Your metadata should also have a column named "run" denoting which sequencing run you are processing (if you only have one seq run for this project, add that column anyway and fill it with the same content, like "1". This script enables multiple sequencing runs to be processed simultenously for larger projects, but that is not necessary.)

  **5. ```R/02_Build_ASV_Tables.R```**

  This script builds ASV tables using DADA2 from trimmed reads. Possible contaminant sequences are detected from negative controls and removed from samples.
  Separate ASV tables are computed for each sequencing run in the project; SSU and ITS amplicons are handled separately.

  **6. ```R/03_Assign_Taxonomy.R```**

  This script assigns taxonomy to all ASV tables using our constructed SSU taxonomic database (from Step 1).
  It can also handle assignments based on ITS sequences, and can be run on multiple sequencing runs at once if needed.

  **7. ```R/05_Build_Physeq_Objects.R```**

  This script combines cleaned sample metadata, ASV tables, & taxonomic assignments into phyloseq objects. Separate phyloseq objects are constructed for each ASV table, and can be combined downstream if desired.
  


___

