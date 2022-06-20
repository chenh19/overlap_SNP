# OverlapSNP
**An automated extracting tool for Illumina SNP arrary/AmpliSeq panel overlapped SNPs**    
*Current version: v0.1.0*

### Resources
- [Illumina SNP array file](https://support.illumina.com/array/array_kits/infinium-global-diversity-array/product-files.html)
- [AmpliSeq](https://www.illumina.com/products/by-brand/ampliseq.html) target panel file (an example [here](https://github.com/chenh19/overlap_SNP/blob/master/Amplicon.csv))

### Package installing (in terminal)
```
sudo -i R
install.packages(c("foreach", "doParallel", "dplyr", "tidyr", "filesstrings", "GenomicRanges"))
BiocManager::install("GenomicRanges")
q()
```
