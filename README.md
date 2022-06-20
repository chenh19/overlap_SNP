# OverlapSNP
**An automated panel-overlapped SNP extracting tool**    
*Current version: v0.1.0*

### Resources
- [Illumina SNP array file](https://support.illumina.com/array/array_kits/infinium-global-diversity-array/product-files.html)
- [AmpliSeq](https://www.illumina.com/products/by-brand/ampliseq.html) target panel (an example [here](https://github.com/chenh19/overlap_SNP/blob/master/Amplicon.csv))

### GenomicRanges package installing
```
sudo -i R
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
BiocManager::install("GenomicRanges")
```
