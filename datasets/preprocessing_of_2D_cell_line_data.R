# This file describes how the datasets used in this Shiny were generated
# Most of this code is adapted from "RNA expression levels in human breast cancer cell line panel.Rmd", 
# by Esmee Koedoot, written on 22 November 2016 and "HL200730 RNA expression for multiple genes.Rmd",
# by Hanneke Leegwater
# Hanneke Leegwater. 29-08-2020


# R libraries & preparation
library(tidyverse)
setwd("C:/Users/hanne/Documents/GitHub/gene_expression_plotter/datasets/")

# Files to analyze
input_file <- "20161122_NormalizedCounts_2DCellLines.txt"
tnbc_subtyping_file <- "TNBC_subtypes_cell_lines.tsv"
metadata_file <- "MetaDataFile.txt"
gene_symbol_file <- "ENSEMBL identifiers to gene names.csv"

# 2D cell line data preprocessing
NormalizedCounts <- read.table(input_file, sep = "\t", header = TRUE)
rownames(NormalizedCounts) <- NormalizedCounts$EnsemblID
NormalizedCounts$EnsemblID <- NULL
LogNormalizedCounts <- log2(NormalizedCounts + 1)
LogNormalizedCounts <- as.data.frame(t(LogNormalizedCounts))
LogNormalizedCounts$CellLine <- gsub("\\_.*","",rownames(LogNormalizedCounts))

# 2D cell line metadata
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

# Write to file
write_csv(LogNormalizedCounts, "HL200829_Log2NormalizedCounts_2DCellLines.csv")

# Transpose to make reading file faster
df_new <- LogNormalizedCounts %>% 
  rownames_to_column %>%
  gather(variable, value, -rowname) %>% 
  spread(rowname, value)
write_csv(df_new, "HL200831_Log2NormalizedCounts_2DCellLines.csv")