# Shiny application to run the advanced spectrum to tone function as a demo for presentation
# Sam Siljee
# 13th October 2024

# Libraries
library(shiny)
library(tuneR)
library(dplyr)
library(ggplot2)

# Define functions
# Function to convert a spectrum into a tone
# Input: A table input of two columns, one column (m/z of the peak) determines the frequency of the sinewave, the second (intensity) determines the relative amplitude of that peak in the polyphonic signal
# Output: An audio object of one second duration
# This function requires the "tuneR" and "dplyr" packages

tonify_spectrum <- function(spectrum, duration = 1, sampling_rate = 44100) {
  # Call the spectrum_to_waveform function
  sound_signal <- spectrum_to_waveform(spectrum = spectrum, duration = duration, sampling_rate = sampling_rate)

  # Create an audio object
  return(Wave(round(sound_signal), samp.rate = 44100, bit = 16))
}


# Function to take a spectrum and return a waveform as a numeric vector
# Input: A table input of two columns, one column (m/z of the peak) determines the frequency of the sinewave, the second (intensity) determines the relative amplitude of that peak in the polyphonic signal
# Output: An audio object of one second duration
# This function requires the "tuneR" and "dplyr" packages

spectrum_to_waveform <- function(spectrum, duration = 1, sampling_rate = 44100) {
  # Filter out peaks of 0 intensity
  dat <- as.data.frame(spectrum) %>%
    filter(intensity > 0)

  # Create time sequence
  time_seq <- seq(0, duration * 2 * pi, length = duration * sampling_rate)

  # Create and add a sine wave for every peak
  sound_signal <- (sin(outer(time_seq, dat$mz, "*")) %*% dat$intensity)

  # Normalize the sound signal
  sound_signal <- (sound_signal / max(abs(sound_signal))) * 32000

  # Return the waveform as a numeric vector
  return(round(sound_signal))
}

# Define UI
ui <- fluidPage(
  numericInput("duration", "Duration", value = 2),
  selectInput(
    "spectrum",
    "Spectrum",
    choices = c(
      "GABA" = "GABA_spectrum.csv",
      "Spectrum 1" = "spectrum_1.csv",
      "Spectrum 2" = "spectrum_2.csv"
    )
  ),
  checkboxInput("filter_mz", "Filter peaks", value = FALSE),
  conditionalPanel(
    condition = "input.filter_mz == true",
    numericInput(
      "filter_threshold",
      "Peak threshold (top proprotion)",
      value = 0.5,
      min = 0,
      max = 1,
      step = 0.1
    )
  ),
  checkboxInput("scale", "Scale (linear)"),
  conditionalPanel(
    condition = "input.scale == true",
    numericInput(
      "scale_min",
      "Lower value",
      value = 100,
      step = 100
    ),
    numericInput(
      "scale_max",
      "Upper value",
      value = 15000,
      step = 1000
    )
  ),
  checkboxInput("log_transform", "Log transform m/z values", value = FALSE),
  checkboxInput("log_transform_intensity", "Log transform intensities", value = FALSE),
  checkboxInput("reverse_mz", "Reverse m/z values"),
  actionButton("update_tone", "Update"),
  uiOutput("tone"),
  h3("Modified spectrum"),
  br(),
  plotOutput("modified_spectrum"),
  h3("Original spectrum"),
  br(),
  plotOutput("original_spectrum")
)

# Define server logic
server <- function(input, output) {
  # Load the GABA spectrum as default
  spectrum_input <- reactive({
    read.table(input$spectrum, header = TRUE, sep = ",")
  })

  # Modify the spectrum using input settings
  modified_spectrum <- reactive({
    # Load in data and filter out peaks of 0 intensity
    dat <- as.data.frame(spectrum_input()) %>%
      filter(intensity > 0)

    # Filter more peaks if selected
    if (input$filter_mz) {
      # Arrange the data
      dat <- arrange(dat, by = desc(mz))
      # Take the top X peaks
      dat <- dat[1:round(nrow(dat) * input$filter_threshold), ]
    }

    # Log2 transform m/z if selected
    if (input$log_transform) {
      # Save old m/z values for re-scaling if needed
      old_min <- min(dat$mz)
      old_max <- max(dat$mz)
      # Log transform
      dat$mz <- log2(dat$mz)
      # Re-scale if not scaling separately
      if (!input$scale) {
        dat$mz <- (dat$mz - min(dat$mz)) / max(dat$mz - min(dat$mz)) * (old_max - old_min) + old_min
      }
    }

    # Log2 transform intensities if selected
    if (input$log_transform_intensity) {
      # Save old m/z values for re-scaling if needed
      old_min_int <- min(dat$intensity)
      old_max_int <- max(dat$intensity)
      # Log transform
      dat$intensity <- log2(dat$intensity)
      # Re-scale if not scaling separately
      dat$intensity <- (dat$intensity - min(dat$intensity)) / max(dat$intensity - min(dat$intensity)) * (old_max_int - old_min_int) + old_min_int
    }

    # Scale m/z if selected
    if (input$scale) {
      dat$mz <- (dat$mz - min(dat$mz)) / max(dat$mz - min(dat$mz)) * (input$scale_max - input$scale_min) + input$scale_min
    }

    # Reverse mz values if selected
    if (input$reverse_mz) {
      dat$mz <- ((dat$mz - mean(c(max(dat$mz), min(dat$mz)))) * -1) + mean(c(max(dat$mz), min(dat$mz)))
    }

    return(dat)
  })

  # Generate the tone from the modified spectrum
  tone <- reactive({
    tonify_spectrum(
      spectrum = modified_spectrum(),
      duration = input$duration,
      sampling_rate = 44100
    )
  })

  # Reactive value to store the tone source URL
  tone_src <- reactiveVal("www/tone.wav")

  # Update tone event
  observeEvent(input$update_tone, {
    # Generate and save the new tone
    writeWave(tone(), "www/tone.wav")

    # Update the reactive tone source with a timestamp to avoid caching
    tone_src(paste0("tone.wav?", Sys.time()))
  })

  # Render tone for UI
  output$tone <- renderUI({
    tags$audio(
      autoplay = NA,
      controls = NA,
      src = tone_src(),
      type = "audio/wav"
    )
  })

  # Create some plots of the spectra
  output$original_spectrum <- renderPlot({
    req(spectrum_input())
    spectrum_input() %>% ggplot(aes(x = mz, y = intensity)) +
      geom_col(width = 0.5, col = "black") +
      theme_bw()
  })

  output$modified_spectrum <- renderPlot({
    req(spectrum_input())
    modified_spectrum() %>% ggplot(aes(x = mz, y = intensity)) +
      geom_col(width = 0.5, col = "black") +
      theme_bw()
  })
}

# Run the application
shinyApp(ui = ui, server = server)
