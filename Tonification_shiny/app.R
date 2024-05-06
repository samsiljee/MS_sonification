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
  fileInput("spectrum", "Spectrum upload",
    buttonLabel = "Browse",
    placeholder = "Upload spectrum file"
  ),
  numericInput("duration", "Clip length (s)", value = 2),
  numericInput("sampling_rate", "Sampling rate", value = 44100),
  checkboxInput("filter_mz", "Filter peaks", value = FALSE),
  conditionalPanel(
    condition = "input.filter_mz == true",
    numericInput(
      "filter_threshold",
      "Peak threshold (top proprotion)",
      value = 0.5,
      min = 0,
      max = 1)),
  checkboxInput("scale", "Scale (linear)"),
  conditionalPanel(
    condition = "input.scale == true",
    numericInput(
      "scale_min",
      "Lower value",
      value = 100),
    numericInput(
      "scale_max",
      "Upper value",
      value = 15000)),
  checkboxInput("log_transform", "Log transform", value = FALSE),
  checkboxInput("reverse_mz", "Reverse m/z values"),
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
