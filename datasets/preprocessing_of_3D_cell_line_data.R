# This file describes how the datasets used in this Shiny were generated
# Most of this code is adapted from "RNA expression levels in human breast cancer cell line panel.Rmd", 
# by Esmee Koedoot, written on 22 November 2016 and "HL200730 RNA expression for multiple genes.Rmd",
# by Hanneke Leegwater
# Hanneke Leegwater. 10-09-2020 and 21-01-2021


# R libraries & preparation
library(tidyverse)
library(vroom)

# Files to analyze
input_file <- "20161208_NormalizedCountTable_AllBCCellLineSamples.txt"
tnbc_subtyping_file <- "TNBC_subtypes_cell_lines.tsv"
metadata_file <- "MetaDataFile.txt"
gene_symbol_file <- "ENSEMBL identifiers to gene names.csv"

# 3D cell line data preprocessing
NormalizedCounts <- read_tsv(input_file, col_types = cols()) %>%
  select('ensembl',contains("3D_A"))
colnames(NormalizedCounts) <- gsub("_3D_A","",colnames(NormalizedCounts))
NormalizedCounts <- column_to_rownames(NormalizedCounts, "ensembl")
LogNormalizedCounts <- log2(NormalizedCounts + 1)
LogNormalizedCounts <- as.data.frame(t(LogNormalizedCounts))
LogNormalizedCounts$CellLine <- gsub("\\_.*","",rownames(LogNormalizedCounts))

# 3D cell line metadata
MetaDataDF <- read.table(metadata_file, sep = "\t", header = TRUE)
MetaDataDF <- subset(MetaDataDF, select = c("CellLine", "Subtype"))
MetaDataDF$Subtype <- gsub(" ", "", MetaDataDF$Subtype)
MetaDataDF$CellLine <- gsub("-", "", MetaDataDF$CellLine)
MetaDataDF <- MetaDataDF[!duplicated(MetaDataDF[,c("CellLine")]), ]
TNBC_subtyping <- read_tsv(tnbc_subtyping_file, col_types = cols(classification = col_factor())) %>%
  select(-cell_line)
MetaDataDF <- left_join(MetaDataDF, TNBC_subtyping, by="CellLine") 

# Add metadata to dataset
LogNormalizedCounts <- merge(LogNormalizedCounts, MetaDataDF, by = "CellLine") %>%
  relocate(Subtype, classification, .after = CellLine)
LogNormalizedCounts <- subset(LogNormalizedCounts, CellLine != "SKBR7") # remove SKBR7 since we don't know the subtype
LogNormalizedCounts <- subset(LogNormalizedCounts, CellLine != "MDAMB435s") # remove MDAMB435s since it is a questionable cell line

# Transpose to make reading file faster
df_new <- LogNormalizedCounts %>% 
  rownames_to_column %>%
  gather(variable, value, -rowname) %>% 
  spread(rowname, value)
# Write to file
write_csv(df_new, "HL200910_Log2NormalizedCounts_3DCellLines.csv")