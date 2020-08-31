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
                                 "RNA seq of 3D cell lines" = "3D",
                                 "RNA seq of patients" = "patient"),
                  selected = "RNA seq of 2D cell lines"),
      
      selectInput("subtype_set", 
                  label = "Choose a subtype classification",
                  choices = c("TNBC vs non-TNBC" = "classification", 
                                 "Luminal vs Basal A vs Basal B" = "Subtype"),
                  selected = "TNBC vs non-TNBC"),
      
      textInput("gene", label = "Enter gene symbol of interest",
                value = ""),
      
      actionButton("gene_check", label = "Check gene"),
      
      actionButton("plot_gene", label = "Plot gene")

    ),
    
    mainPanel(
      textOutput("gene_check_warning"),
      
      plotOutput("gene_plot")
      
    )
  )
)

# Define server logic ----
server <- function(input, output) {
  # Look up Ensembl ID of gene of interest
  output$gene_check_warning <- renderText({ 
    if(input$gene != ""){
      ensembl <- gene_symbol_lookup(input$gene)
      if(ensembl == FALSE){
        paste("Cannot find ", input$gene, "...", sep="")
      } else {
        paste("Plotting data for gene", input$gene, "with ENSEMBL ID", ensembl)
      }
    } else {
      "Enter gene symbol to plot gene"
    }
  })
  
  # Set data frame
  df <- reactive({
    return(read_df(input$dataset))
  })
  
  # Subset data frame
  df_subset <- reactive({
    return(subset_data(df(), input$gene))
  })
  
  # Plot gene
  output$gene_plot <- renderPlot({
    make_cool_plot(df = df_subset(), gene_symbol = input$gene, subtype_or_classification = input$subtype_set)
  })
  
}

# Run the app ----
shinyApp(ui = ui, server = server)