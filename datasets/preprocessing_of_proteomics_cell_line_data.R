# This file describes how the datasets used in this Shiny were generated
# Most of this code is adapted from "RNA expression levels in human breast cancer cell line panel.Rmd", 
# by Esmee Koedoot, written on 22 November 2016 and "HL200730 RNA expression for multiple genes.Rmd",
# by Hanneke Leegwater
# Hanneke Leegwater. 10-09-2020


# R libraries & preparation
library(tidyverse)
setwd("C:/Users/hanne/Documents/GitHub/gene_expression_plotter/datasets/")

# Files to analyze
input_file <- "20161223_ProteomicsDF.txt"
tnbc_subtyping_file <- "TNBC_subtypes_cell_lines.tsv"
metadata_file <- "MetaDataFile.txt"
gene_symbol_file <- "ENSEMBL identifiers to gene names.csv"

# proteomics cell line data preprocessing
ProteomicsData <- read_tsv(input_file, col_types = cols()) %>%
  select(-NAME) %>%
  column_to_rownames("UNIQID")
# Transpose data
ProteomicsData <- ProteomicsData %>% 
  rownames_to_column %>%
  gather(CellLine, value, -rowname) %>% 
  spread(rowname, value)

# proteomics (?) cell line metadata
MetaDataDF <- read.table(metadata_file, sep = "\t", header = TRUE)
MetaDataDF <- subset(MetaDataDF, select = c("CellLine", "Subtype"))
MetaDataDF$Subtype <- gsub(" ", "", MetaDataDF$Subtype)
MetaDataDF$CellLine <- gsub("-", "", MetaDataDF$CellLine)
MetaDataDF <- MetaDataDF[!duplicated(MetaDataDF[,c("CellLine")]), ]
TNBC_subtyping <- read_tsv(tnbc_subtyping_file, col_types = cols(classification = col_factor())) %>%
  select(-cell_line)
MetaDataDF <- left_join(MetaDataDF, TNBC_subtyping, by="CellLine") 

# Add metadata to dataset
ProteomicsData <- merge(ProteomicsData, MetaDataDF, by = "CellLine") %>%
  relocate(Subtype, classification, .after = CellLine)
ProteomicsData <- subset(ProteomicsData, CellLine != "SKBR7") # remove SKBR7 since we don't know the subtype
ProteomicsData <- subset(ProteomicsData, CellLine != "MDAMB435s") # remove MDAMB435s since it is a questionable cell line

# Transpose to make reading file faster
df_new <- ProteomicsData %>% 
  rownames_to_column %>%
  gather(variable, value, -rowname) %>% 
  spread(rowname, value)
# Write to file
write_csv(df_new, "HL200910_log2ratio_data_proteomics.csv")