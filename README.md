# Gene Expression Plotter
This Shiny application can plot gene expression data for breast cancer subtypes. 

# Introduction
In the DDS, we collected data on breast cancer cell line mRNA expression and on protein abundance (transcriptomics and proteomics) for cells grown in a two-dimensional environment. Also, we collected mRNA expression data on a subset of breast cancer cell lines grown in a 3D environment. This Shiny combines this information, together with mRNA expression data from patients from The Cancer Genome Atlas.

## Options
You can choose between the datasets, between various types of subtype classifications and four plot types, depending on your need. 

## A word of caution:
For TCGA data, I classified patients as "non TNBC" if they were tested positive for the ER, PR or HER2 receptor. They were negative if all three receptors were negative. This leaves some patients with two negative and one undetermined receptor, which are removed from this Shiny.  

Also, the TCGA plot shows a box for "normal tissue". This is NOT data from healthy people!!! This is healthy tissue from a subset of 100 patients, and it is therefore not independent from the other box plots.  

This Shiny can only be used for data exploration. For definite conclusions, please go back to the raw data and perform the analysis of interest yourself. 

## Previous work:
The layout is partially based on the PlotsOfData Shiny by Joachim Goedhart and the gene expression plot is partially based on R plots by Esmée Koedoot.

## References:
Postma M, Goedhart J (2019) PlotsOfData—A web app for visualizing data together with their summaries. PLOS Biology 17(3): e3000202. https://doi.org/10.1371/journal.pbio.3000202
https://github.com/JoachimGoedhart/PlotsOfData
