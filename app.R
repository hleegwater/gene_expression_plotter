# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Code based on Shiny tutorial
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Copyright (C) 2020 Hanneke Leegwater
# Add license stuff here?
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

if (!require("pacman")) install.packages("pacman"); library(pacman)
p_load(shiny, tidyverse, glue, vroom)

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
                              "Boxplot with dots" = "box_d",
                              "Unsorted bar plot" = "bar_u",
                              "Sorted bar plot" = "bar_s"),
                  selected = 1),

      selectInput("id_type", label = "Choose ID type",
                  choices = c("NCBI gene (Entrez) ID" = "NCBI_Gene_ID",
                              "ENSEMBL ID" = "Ensembl_gene_ID",
                              "Gene symbol" = "gene_symbol"),
                  selected = "gene_symbol"),

      textInput("id", label = "Enter ID of interest",
                value = "TP53"),

      # Export images
      downloadButton("downloadData", "Save dataset"),
      downloadButton("downloadPlot", "Save image")

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
    req(gene_id_to_plot())
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

  gene_plot <- reactive({
    req(df_for_plot(), input$id, input$subtype_set, input$plot_type)
    choose_and_plot(plot_type = input$plot_type, df = df_for_plot(),
                    gene_symbol = input$id, subtype_to_plot = input$subtype_set,
                    dataset_name = input$dataset)
  })

  # Plot gene
  output$gene_plot <- renderPlot({
    print(gene_plot())
  })



  # Download data for plot

  output_filename <- reactive({
    return(input$id)
  })

  output$downloadData <- downloadHandler(
    filename = function() {
      glue("Expression data for BC cell lines {dataset} {id} {plot_type}.csv",
           dataset = input$dataset, id = input$id, plot_type = input$plot_type)
    },
    content = function(file) {
      df_to_write = df_for_plot()
      names(df_to_write)[names(df_to_write) == "expression"] <- get_y_axis_name(input$dataset)
      write_csv(df_to_write, file)
    },
    contentType = "text/csv"
  )


  # Download plot
  output$downloadPlot <- downloadHandler(
    filename = function(){
      glue("Expression plot for BC cell lines {dataset} {id} {plot_type}.png",
            dataset = input$dataset, id = input$id, plot_type = input$plot_type)
    },
    content = function(file) {
      ggsave(file, plot = gene_plot(), device = "png")
    },
    contentType = "image/png"
  )

}

# Run the app ----
shinyApp(ui = ui, server = server)