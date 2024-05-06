# Shiny application to run the advanced spectrum to tone function as a web application
# Sam Siljee
# 6th May 2024

# Libraries
library(shiny)
library(tuneR)
library(dplyr)

# Source functions
source("../functions.R", local = TRUE)

# Define UI
ui <- fluidPage(
  fileInput("spectrum", "Specrtum upload",
    buttonLabel = "Browse",
    placeholder = "Upload spectrum file"
  ),
  actionButton("tonify", "Tonify!"),
  actionButton("write_wav", "Write to disk"),
  verbatimTextOutput("test")
)

# Define server logic
server <- function(input, output) {
  # Get the spectrum input - supports .csv files with specific headers
  spectrum_input <- reactive({
    read.table(input$spectrum$datapath, header = TRUE, sep = ",")
  })
  
  # Run code to generate the tone
  tone <- eventReactive(input$tonify, {
    advanced_spectrum_to_tone(
      spectrum = spectrum_input(),
      duration = input$duration,
      sampling_rate = input$sampling_rate,
      filter_mz = input$filter_mz,
      filter_threshold = input$filter_threshold,
      scale = input$scale,
      scale_min = input$scale_min,
      scale_max = input$scale_max,
      log_transform = input$log_transform,
      reverse_mz = input$reverse_mz
    )
  })
  
  # Write the tone to disk. This will be replaced by a download button
  observeEvent(input$write_wav, {
    writeWave(tone(), file = "shiny_tone.wav")
  })
}

# Run the application
shinyApp(ui = ui, server = server)
