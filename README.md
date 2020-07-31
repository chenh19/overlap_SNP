# Overlap_SNP
**An automated overlapped SNP extraction tool**    
*Current version: v0.1.0*

### Resources
- [Illumina SNP array file](https://support.illumina.com/array/array_kits/infinium-global-diversity-array/product-files.html)
- Variant ref library made with [BRStudio](https://github.com/chenh19/BRStudio)

### GenomicRanges package installing
```
sudo -i R
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
BiocManager::install("GenomicRanges")
```
