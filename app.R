# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Code based on Shiny tutorial  
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Copyright (C) 2020 Hanneke Leegwater
# Add license stuff here?
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

library(shiny)
library(tidyverse)
source("helpers.R")

# Define UI ----
ui <- fluidPage(
  titlePanel("Gene expression plotter"),
  
  sidebarLayout(
    sidebarPanel(
      helpText("Settings"),
      
      selectInput("dataset", 
                  label = "Choose a breast cancer dataset",
                  choices = c("RNA seq of 2D cell lines" = "2D", 
                              "Proteomics of 2D cell lines" = "prot",
                              "RNA seq of 3D cell lines" = "3D",
                              "RNA seq of patients" = "tcga"),
                  selected = "2D"),
      
      selectizeInput("subtype_set", 
                  label = "Choose a subtype classification",
                  choices = c("choose" = "")),
      
      selectInput("plot_type", 
                  label = "Choose what to plot",
                  choices = c("Boxplot" = "box", 
                              "Unsorted bar plot" = "bar_u",
                              "Sorted bar plot" = "bar_s"),
                  selected = 1),
      
      selectInput("id_type", label = "Choose ID type",
                  choices = c("NCBI gene (Entrez) ID" = "NCBI_Gene_ID",
                              "ENSEMBL ID" = "Ensembl_gene_ID",
                              "Gene symbol" = "gene_symbol"),
                  selected = "gene_symbol"),
      
      textInput("id", label = "Enter ID of interest",
                value = "TP53")

    ),
    
    mainPanel(
      textOutput("error_warning"),
      
      plotOutput("gene_plot")
      
    )
  )
)

# Define server logic ----
server <- function(input, output, session) {

  # Set data frame
  gene_id_to_plot <- reactive({
    return(gene_symbol_lookup(input$id, id_type = input$id_type, dataset_name = input$dataset))
  })
  
  # Ask for error when something changes
  error_string <- reactive(get_error_string(input$id))
  output$gene_check_warning <- renderText(error_string)
  
  # Subset data frame
  df_for_plot <- reactive({
    return(subset_data(input$dataset, gene_id_to_plot()))
  })
  
  # Ask options for subtype classifications
  subtype_options <- reactive({
    subtype_options <- colnames(df_for_plot()) 
    subtype_options <- setdiff(subtype_options, c("ID", "name", "expression"))
    return(subtype_options)
  })
  observe({
    updateSelectizeInput(session, "subtype_set", choices = subtype_options())
  })
  
  # Plot gene
  output$gene_plot <- renderPlot({
    choose_and_plot(plot_type = input$plot_type, df = df_for_plot(), 
                    gene_symbol = input$id, subtype_to_plot = input$subtype_set)
  })
  
}

# Run the app ----
shinyApp(ui = ui, server = server)