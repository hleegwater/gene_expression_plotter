## Helper functions for the Shiny

library(tidyverse)
library(glue)
library(vroom)

## Load all datasets and metadata
load("new_datasets/tcga_data_for_shiny.RData") # contains tcga_data and tcga_metadata
load("new_datasets/cell_line_data2D_for_shiny.RData") # contains cell_line_data2D and cell_line_metadata2D
load("new_datasets/cell_line_data3D_for_shiny.RData") # contains cell_line_data3D and cell_line_metadata3D
load("new_datasets/cell_line_dataprot_for_shiny.RData") # contains cell_line_dataprot and cell_line_metadataprot
## Rename some columns
cell_line_data2D <- rename(cell_line_data2D, "ID" = "ENSEMBL_ID")
cell_line_metadata2D <- rename(cell_line_metadata2D, "name" = "CellLine")

cell_line_data3D <- rename(cell_line_data3D, "ID" = "ENSEMBL_ID")
cell_line_metadata3D <- rename(cell_line_metadata3D, "name" = "CellLine")

cell_line_dataprot <- rename(cell_line_dataprot, "ID" = "ENSEMBL_ID")
cell_line_metadataprot <- rename(cell_line_metadataprot, "name" = "CellLine")

tcga_data <- rename(tcga_data, "ID" = "entrez_id")
tcga_metadata <- rename(tcga_metadata, "name" = "patient")

# Open gene lookup table
gene_symbol_table <- vroom::vroom("new_datasets/original_files/gene_identifier_table.csv", col_types = cols()) %>%
  select(NCBI_Gene_ID, Ensembl_gene_ID, gene_symbol, gene_name)

# Combine multiple errors to reactive
error_string <- ""
get_error_string <- function(args){
  print(glue("error is{error_string}"))
  return(error_string)
}
############ To select one gene from a data frame ###########
gene_symbol_lookup <- function(id_to_lookup, id_type = "gene_symbol", dataset_name = "2D", return_all = FALSE){
  ## Find the right row in the gene lookup table and return ID that you need for dataset_name
  
  ##!!as.symbol(x) can put the column name id_type in here as variable
  answer <- filter(gene_symbol_table, !!as.symbol(id_type) == id_to_lookup) 
  
  ## Check if the answer is ok
  if(nrow(answer) == 0){
    error_string <- glue("Gene ID '{id_to_lookup}' not found in column '{id_type}' of the lookup table")
    print(error_string)
    return()
  } else if(nrow(answer) > 1){
    error_string <- glue("Multiple options found for {id_to_lookup}. Please specifty an unique ID.")
    print(error_string)
    print(answer)
    return()
  }
  # Return entire df if needed
  if(return_all){
    return(answer)
  }
  ## cell line datasets 2D, 3D and prot need an Ensembl ID
  ## TCGA data needs a NCBI gene ID
  id = switch(dataset_name,
              "2D" = answer$Ensembl_gene_ID,
              "3D" = answer$Ensembl_gene_ID,
              "prot" = answer$Ensembl_gene_ID,
              "tcga"= answer$NCBI_Gene_ID
              )
  return(id)
}

subset_data <- function(dataset_name, id){
  # Subset the dataframe of interest and return transposed df with columns: 
  # "name", "expression" and metadata
  
  answer = switch(dataset_name,
      "2D" = filter(cell_line_data2D, ID == id),
      "3D" = filter(cell_line_data3D, ID == id),
      "prot" = filter(cell_line_dataprot, ID == id),
      "tcga" = filter(tcga_data, ID == id)
  )

  if(nrow(answer) == 0){
    error_string <- glue("ID '{id}' not found in dataset '{dataset_name}'")
    print(error_string)
    return()
  }
  # transpose data
  answer <- answer %>% 
    gather(name, expression, -ID) 
  
  # add metadata
  answer = switch(dataset_name,
      "2D" = left_join(answer, cell_line_metadata2D, by = "name"),
      "3D" = left_join(answer, cell_line_metadata3D, by = "name"),
      "prot" = left_join(answer, cell_line_metadataprot, by = "name"),
      "tcga" = left_join(answer, tcga_metadata, by = "name")
  )

  # return data
  return(answer)
}

########### Plots ###############
make_boxplot <- function(df, gene_symbol, subtype_to_plot){
  ggplot(data = df, aes_string(x = subtype_to_plot, y = "expression")) +
    geom_boxplot(aes_string(fill = subtype_to_plot), alpha = 0.7) +
    geom_jitter(shape = 21, aes_string(fill = subtype_to_plot)) +
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

make_unsorted_barplot <- function(df, gene_symbol, subtype_to_plot){
  ggplot(data = df, aes(x = name, y = expression)) +
        geom_bar(aes_string(fill = subtype_to_plot), stat = "identity") +
        ylab("Log2 Expression Level") +
        xlab("Cell line") +
        ggtitle(gene_symbol) +
        scale_y_continuous(expand = c(0,0)) +
        scale_fill_manual(values = c("red3", "dodgerblue3", "green4", "gray", "yellow")) +
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

make_sorted_barplot <-function(df, gene_symbol, subtype_to_plot){
  ggplot(data = df, aes(x = reorder(name, -expression), y = expression)) +
        geom_bar(aes_string(fill = subtype_to_plot), stat = "identity") +
        ylab("Log2 Expression Level") +
        xlab("Cell line") +
        ggtitle(gene_symbol) +
        scale_y_continuous(expand = c(0,0)) +
        scale_fill_manual(values = c("red3", "dodgerblue3", "green4", "gray", "yellow")) +
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

choose_and_plot <- function(plot_type, df, gene_symbol, subtype_to_plot){
  switch(plot_type,
         "box" = make_boxplot(df, gene_symbol, subtype_to_plot),
         "bar_u" = make_unsorted_barplot(df, gene_symbol, subtype_to_plot),
         "bar_s" = make_sorted_barplot(df, gene_symbol, subtype_to_plot)
  )
}
