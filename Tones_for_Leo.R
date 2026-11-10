# Script to make some tones for Leo Martinez
# Sam Siljee
# 10th November 2026

# Libraries
library(tuneR) # Audio processing
library(mzR) # MS data handling
library(dplyr) # Data manipulation

# Source functions
source("functions.R")

# Set some variables
sample_rate <- 44100

# Load raw MS data
ms_data <- openMSfile("Mix_TMT_F5_20241219181938.mzML")

# Get metadata to identify spectrum with the most peaks
ms_header <- header(ms_data)

# Get list of spectra with highest number of peaks
top_spectra <- ms_header %>%
  arrange(desc(peaksCount)) %>%
  .[1:15, 1]

# Loop through with increasing length of time
time_length <- 1
for (k in 1:7) {
  time_length <- time_length * 2
  for (i in top_spectra) {
    spectrum_i <- peaks(ms_data, i)

    tone <- advanced_spectrum_to_tone(
      spectrum = spectrum_i,
      duration = 0.5,
      waveform = "sine"
    )

    # Save as audio clip
    writeWave(tone, file = paste0("Tones_for_Leo/", i, "_", k, "s.wav"))
  }
}
