# Script to make some tones for the Spectral_1 song
# Sam Siljee
# 12th July 2025

# Libraries
library(tuneR) # Audio processing
library(mzR) # MS data handling
library(dplyr) # Data manipulation

# Source functions
source("functions.R")

# Set some variables
sample_rate <- 44100

# Load raw MS data
ms_data <- openMSfile("test.mzML")

# Get metadata to identify spectrum with the most peaks
ms_header <- header(ms_data)

# Extract spectrum with the most peaks
top_spectrum <- peaks(ms_data, which(ms_header$peaksCount == max(ms_header$peaksCount)))

# Generate tones
tone <- advanced_spectrum_to_tone(
  spectrum = top_spectrum,
  duration = 5,
  scale = TRUE,
  scale_min = 100,
  scale_max = 15000
)

# Save as audio clip
writeWave(tone, file = "tones/wide_drone.wav")
