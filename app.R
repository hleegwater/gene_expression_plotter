# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Code based on PlotsOfData, created by Joachim Goedhart (@joachimgoedhart), first version 2018
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Copyright (C) 2020 Hanneke Leegwater
# Add license stuff here?
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

library(shiny)

# Define UI ----
ui <- fluidPage(
  titlePanel("Gene expression plotter"),
  
  sidebarLayout(
    sidebarPanel(
      helpText("Settings"),
      
      selectInput("dataset", 
                  label = "Choose a breast cancer dataset",
                  choices = list("RNA seq of 2D cell lines", 
                                 "RNA seq of 3D cell lines",
                                 "RNA seq of patients"),
                  selected = "RNA seq of 2D cell lines"),
      
      selectInput("subtypes", 
                  label = "Choose a subtype classification",
                  choices = list("TNBC vs non-TNBC", 
                                 "Luminal vs Basal A vs Basal B"),
                  selected = "TNBC vs non-TNBC"),
      
      textInput("gene", label = "Enter gene symbol of interest",
                value = ""),
      
      actionButton("gene_check", label = "Check gene"),
      
      actionButton("plot_gene", label = "Plot gene")

    ),
    
    mainPanel(
      textOutput("gene_check_warning")
      
    )
  )
)

# Define server logic ----
server <- function(input, output) {
  output$gene_check_warning <- renderText({ 
    "Your gene is okay"
  })
  
}

# Run the app ----
shinyApp(ui = ui, server = server)