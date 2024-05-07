# Shiny application to run the advanced spectrum to tone function as a web application
# Sam Siljee
# 6th May 2024

# Libraries
library(shiny)
library(tuneR)
library(dplyr)

# Define functions
# Generate the function to test different options
advanced_spectrum_to_tone <- function(
    spectrum,
    duration = 1,
    sampling_rate = 44100,
    filter_mz = FALSE,
    filter_threshold = 0.5,
    scale = FALSE,
    scale_min = 100,
    scale_max = 15000,
    log_transform = FALSE,
    reverse_mz = FALSE) {
  # Filter out peaks of 0 intensity
  dat <- as.data.frame(spectrum) %>%
    filter(intensity > 0)
  
  # Filter more peaks if selected
  if (filter_mz) {
    # Arrange the data
    dat <- arrange(dat, by = desc(mz))
    # Take the top X peaks
    dat <- dat[1:round(nrow(dat) * filter_threshold), ]
  }
  
  # Log2 transform if selected
  if (log_transform) {
    # Save old m/z values for re-scaling if needed
    old_min <- min(dat$mz)
    old_max <- max(dat$mz)
    # Log transform
    dat$mz <- log2(dat$mz)
    # Re-scale if not scaling separately
    if(!scale) {
      dat$mz <- (dat$mz - min(dat$mz)) / max(dat$mz - min(dat$mz)) * (old_max - old_min) + old_min
    }
  }
  
  # Scale m/z if selected
  if (scale) {
    dat$mz <- (dat$mz - min(dat$mz)) / max(dat$mz - min(dat$mz)) * (scale_max - scale_min) + scale_min
  }
  
  # Reverse mz values if selected
  if (reverse_mz) {
    dat$mz <- ((dat$mz - mean(c(max(dat$mz), min(dat$mz)))) * -1) + mean(c(max(dat$mz), min(dat$mz)))
  }
  
  # Create time sequence
  time_seq <- seq(0, duration * 2 * pi, length = duration * sampling_rate)
  
  # Create and add a sine wave for every peak
  sound_signal <- (sin(outer(time_seq, dat$mz, "*")) %*% dat$intensity)
  
  # Normalize the sound signal and return as numeric vector
  sound_signal <- round((sound_signal / max(abs(sound_signal))) * 32000)
  
  # Return audio object
  return(Wave(round(sound_signal), samp.rate = 44100, bit = 16))
}

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
  actionButton("tonify", "Generate tone!"),
  downloadButton("download_wav", "Download .wav file"),
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
  
  # Download as a .wav file
  output$download_wav <- downloadHandler(
    filename = function() {
      paste("tone_", Sys.Date(), ".wav", sep = "")
    },
    content = function(file) {
      writeWave(tone(), file = file)
    }
  )
}

# Run the application
shinyApp(ui = ui, server = server)
