## Helper functions for the Shiny

library(tidyverse)
# Information on the used data ----
path_to_datasets <- "datasets"
datasets <- tibble( name = c("2D", "3D", "proteomics"),
                    filename = c("HL200831_Log2NormalizedCounts_2DCellLines.csv",
                                 "HL200910_Log2NormalizedCounts_3DCellLines.csv", 
                                 "HL200910_log2rati_data_proteomics.csv"))
gene_symbol_table <- read_csv(file.path(path_to_datasets, "ENSEMBL identifiers to gene names.csv"), col_types = cols()) %>%
  select(ensemblID = "Gene stable ID", gene_symbol = "Gene name")
# Define functions to read and preprocess data ----

# To read the data
read_df <- function(df_name){
  df <- datasets[datasets$name == df_name,]$filename
  df <- read_csv(file.path(path_to_datasets, df), col_types = cols()) %>%
    column_to_rownames("variable")
  return(df)
}

# To select one gene from a data frame
gene_symbol_lookup <- function(gene_symbol){
  ensemblID <- gene_symbol_table[gene_symbol_table$gene_symbol == gene_symbol,]$ensemblID
  if(length(ensemblID) > 0){
    return(ensemblID)
  } else{
    return(FALSE)
  }
}

subset_data <- function(df, gene_symbol, ensembl_id){
  # Look up ENSEMBL ID to subset data on
  if(ensembl_id == ""){
    ensemblID <- gene_symbol_lookup(gene_symbol)
  } else {
    ensemblID <- ensembl_id  
  }
  
  ## Subset expression data
  df_new <- df[c("CellLine", "classification", "Subtype", ensemblID),]
  # transpose data
  df_new <- df_new %>% 
    rownames_to_column %>%
    gather(variable, value, -rowname) %>% 
    spread(rowname, value)
  df_new <- rename(df_new,Log2Expression = all_of(ensemblID) )
  df_new$Log2Expression <- as.numeric(df_new$Log2Expression)
  # return data
  return(df_new)
}


make_boxplot <- function(df, gene_symbol, subtype_or_classification){
  ggplot(data = df, aes_string(x = subtype_or_classification, y = "Log2Expression")) +
    geom_boxplot(aes_string(fill = subtype_or_classification), alpha = 0.7) +
    geom_jitter(shape = 21, aes_string(fill = subtype_or_classification)) +
    ylab("Log2 Expression Level") +
    ggtitle(gene_symbol) +
    scale_y_continuous(expand = c(0,0)) +
    theme_classic() +
    theme(axis.line.x = element_line(colour = "black"),
          axis.line.y = element_line(colour = "black"),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.border = element_blank(),
          panel.background = element_blank(),
          legend.key = element_blank(),
          plot.title = element_text(hjust = 0.5))
}

make_unsorted_barplot <- function(df, gene_symbol, subtype_or_classification){
  ggplot(data = df, aes(x = CellLine, y = Log2Expression)) +
        geom_bar(aes_string(fill = subtype_or_classification), stat = "identity") +
        ylab("Log2 Expression Level") +
        xlab("Cell line") +
        ggtitle(gene_symbol) +
        scale_y_continuous(expand = c(0,0)) +
        scale_fill_manual(values = c("red3", "dodgerblue3", "green4", "gray")) +
        theme_bw() +
        theme(axis.line.x = element_line(colour = "black"),
              axis.line.y = element_line(colour = "black"),
              panel.grid.major = element_blank(),
              panel.grid.minor = element_blank(),
              panel.border = element_blank(),
              panel.background = element_blank(),
              legend.key = element_blank(),
              axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1, size = 8),
              plot.title = element_text(hjust = 0.5))
}

make_sorted_barplot <-function(df, gene_symbol, subtype_or_classification){
  ggplot(data = df, aes(x = reorder(CellLine, -Log2Expression), y = Log2Expression)) +
        geom_bar(aes_string(fill = subtype_or_classification), stat = "identity") +
        ylab("Log2 Expression Level") +
        xlab("Cell line") +
        ggtitle(gene_symbol) +
        scale_y_continuous(expand = c(0,0)) +
        scale_fill_manual(values = c("red3", "dodgerblue3", "green4", "gray")) +
        theme_bw() +
        theme(axis.line.x = element_line(colour = "black"),
              axis.line.y = element_line(colour = "black"),
              panel.grid.major = element_blank(),
              panel.grid.minor = element_blank(),
              panel.border = element_blank(),
              panel.background = element_blank(),
              legend.key = element_blank(),
              axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1, size = 8),
              plot.title = element_text(hjust = 0.5))
}

choose_and_plot <- function(plot_type, df, gene_symbol, subtype_or_classification){
  if(plot_type == 1){
    make_boxplot(df, gene_symbol, subtype_or_classification)
  } else if (plot_type == 2){
    make_unsorted_barplot(df, gene_symbol, subtype_or_classification)
  } else if (plot_type == 3){
    make_sorted_barplot(df, gene_symbol, subtype_or_classification)
  }
}
