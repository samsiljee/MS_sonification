# Script to test some variations on generating tones
# Sam Siljee
# 3rd May 2024

# Libraries
# Load the required packages
library(tuneR)
library(mzR)
library(dplyr)

# Load test spectra
spectrum_1 <- read.csv("test_spectra/spectrum_1.csv", header = TRUE)
spectrum_2 <- read.csv("test_spectra/spectrum_2.csv", header = TRUE)

# Generate the function to test different options
advanced_spectrum_to_tone <- function(
    spectrum,
    duration = 1,
    sampling_rate = 44100,
    scale_min = 100,
    scale_max = 15000,
    scale = FALSE,
    log_transform = FALSE) {
  # Filter out peaks of 0 intensity
  dat <- as.data.frame(spectrum) %>%
    filter(intensity > 0)

  # Log2 transform if selected
  if (log_transform) {
    dat$mz <- log2(dat$mz)
  }
  
  # Scale m/z if selected
  if (scale) {
    dat$mz <- (dat$mz - min(dat$mz)) / max(dat$mz - min(dat$mz)) * (scale_max - scale_min) + scale_min
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

# Testing out different options
# Basic tone
basic_tone_1 <- advanced_spectrum_to_tone(spectrum_1, duration = 2)
writeWave(basic_tone_1, file = "Produced clips/basic_tone_1.wav")

# Scale from 100 - 15K
scaled_tone_1 <- advanced_spectrum_to_tone(
  spectrum_1,
  duration = 2,
  scale = TRUE,
  scale_min = 100,
  scale_max = 15000
)
writeWave(scaled_tone_1, file = "Produced clips/scaled_tone_1.wav")

# Log2 transform (with scale, till I sort that out again)
log_transform_tone_1 <- advanced_spectrum_to_tone(
  spectrum_1,
  duration = 2,
  scale = TRUE,
  scale_min = 120.994,
  scale_max = 1336.602,
  log_transform = TRUE
)
writeWave(not_scaled_tone_1, file = "Produced clips/not_scaled_tone_1.wav")