# Load R packages
lapply(c("foreach", "doParallel", "dplyr", "tidyr", "filesstrings", "GenomicRanges"), 
       require, character.only = TRUE)


# Set the folder containing current R script as working directory
setwd(".")
if (dir.exists("original_files")==FALSE){
  dir.create("original_files")
}
if (dir.exists("cache")==FALSE){
  dir.create("cache")
}


# Set cpu cores for parallel computing
numCores <- detectCores(all.tests = FALSE, logical = TRUE)


# Load data
chrs <- c("1", "4", "6", "9", "11", "12", "17", "19", "20", "X")
all_snp <- read.csv("GDA-8v1-0_A1.csv")
amplicon <- read.csv("Amplicon.csv")


# Trim SNP
snp_loc <- all_snp[c("Name")]
snp_loc <- separate(snp_loc, "Name",
                    into=c("Chromosome","pos"), sep=":")
snp_loc <- separate(snp_loc, "pos",
                    into=c("pos","other1", "other2", "other3"), sep="-")
snp_loc <- separate(snp_loc, "pos",
                    into=c("pos","other4", "other5", "other6"), sep="_")
snp_loc <- snp_loc[c("Chromosome", "pos")]
snp_loc <- separate(snp_loc, "pos",
                    into=c("start","other7"), sep="del")

snp_loc$start <- as.numeric(as.character(snp_loc$start))
snp_loc$other7 <- as.numeric(as.character(snp_loc$other7))
snp_loc <- tidyr::replace_na(snp_loc, list(other7=0))
snp_loc$end <- snp_loc$start + snp_loc$other7
snp_loc <- snp_loc[c("Chromosome", "start", "end")]


# Split SNP by Chr
registerDoParallel(numCores)
foreach (chr = chrs) %dopar% {
  csv1 <- filter(snp_loc, Chromosome == chr)
  if(nrow(csv1)>1){
    filename <- paste0("chr", chr, ".snp.csv")
    write.table(csv1, file=filename, sep=",", row.names = FALSE)
  }
}
rm("snp_loc")
file.move("GDA-8v1-0_A1.csv", "./original_files", overwrite=TRUE)


# Split Amplicon by Chr
registerDoParallel(numCores)
foreach (chr = chrs) %dopar% {
  csv1 <- filter(amplicon, Chromosome == chr)
  if(nrow(csv1)>1){
    filename <- paste0("chr", chr, ".amplicon.csv")
    write.table(csv1, file=filename, sep=",", row.names = FALSE)
  }
}
rm("amplicon")
file.move("Amplicon.csv", "./original_files", overwrite=TRUE)


# Make genomic range
registerDoParallel(numCores)
foreach (chr = chrs) %dopar% {
  filename1 <- paste0("chr", chr, ".amplicon.csv")
  filename2 <- paste0("chr", chr, ".snp.csv")
  filename3 <- paste0("chr", chr, ".overlap.csv")
  chr_amp <- read.csv(filename1)
  gr1 <- makeGRangesFromDataFrame(chr_amp)
  chr_snp<- read.csv(filename2)
  gr2 <- makeGRangesFromDataFrame(chr_snp)
  overlaps <- subsetByOverlaps(gr2, gr1)
  write.table(overlaps, file=filename3, sep=",", row.names = FALSE)
  file.move(filename1, "./cache", overwrite=TRUE)
  file.move(filename2, "./cache", overwrite=TRUE)
}


# Label SNP
registerDoParallel(numCores)
foreach (chr = chrs) %dopar% {
  filename1 <- paste0("chr", chr, ".overlap.csv")
  filename2 <- paste0("chr", chr, ".ref.csv")
  filename3 <- paste0("chr", chr, ".labeled.csv")
  overlap <- read.csv(filename1)[, "start"]
  overlap <- as.data.frame(overlap)
  colnames(overlap) <- c("pos") 
  ref <- read.csv(filename2)
  ref$pos <- ref$Variant
  ref <- separate(ref, "pos",
                      into=c("A","pos", "C", "D"), sep="-")
  ref <- ref[c("pos", "Gene")]
  ref <- distinct(ref, pos, .keep_all= TRUE)
  csv1 <- add_columns(overlap, ref, by=c("pos"))
  
  csv1$chr <- rep(chr,nrow(csv1))
  csv1 <- csv1[c("chr", "pos", "Gene")]
  write.table(csv1, file=filename3, sep=",", row.names = FALSE)
  file.move(filename1, "./cache", overwrite=TRUE)
  file.move(filename2, "./cache", overwrite=TRUE)
}


# Merge all overlapped SNP
labeled <- list.files(pattern='.labeled.csv')
labeled_snp <- lapply(labeled, read.csv)
labeled_snp <- do.call(rbind.data.frame, labeled_snp)
write.table(labeled_snp, file="overlapped_SNP.csv", sep=",", row.names = FALSE)
file.move(labeled, "./cache", overwrite=TRUE)

SNP_ref <- all_snp
SNP_ref$Name2 <- SNP_ref$Name
SNP_ref <- separate(SNP_ref, "Name2",
                    into=c("Name2","other1", "other2", "other3"), sep="-")
SNP_ref <- distinct(SNP_ref, Name2, .keep_all= TRUE)
csv1 <- read.csv("overlapped_SNP2.csv")
csv2 <- add_columns(csv1, SNP_ref, by=c("Name2"))
write.table(csv2, file="overlapped_SNP_with_annotation.csv", sep=",", row.names = FALSE)