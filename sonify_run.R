# Script to sonify an entire mass spectrometry run
# Sam Siljee
# 9 March 2024
# MIT licence

# Libraries
library(tuneR)
library(mzR)
library(dplyr)

# Source functions
source("functions.R")

# Set some variables
sample_rate <- 44100
duration <- 1

# Load data
# Open test MS file
ms_data <- openMSfile("22-091_1_1ul_SS.mzML")

# Extract the first 10,000 the peaks
ms_peaks <- peaks(ms_data, scans = 1:10)

# Extract corresponding header information
ms_header <- header(ms_data) %>% head(10)

# Get list of MS1 and MS2 spectrum indexes
ms_1_indexes <- filter(ms_header, msLevel == 1) %>% .$seqNum
ms_2_indexes <- filter(ms_header, msLevel == 2) %>% .$seqNum

# Inverse Fourier transform to get waveforms, and write to folder
for (i in 1:nrow(ms_header)) {
  # Reverse Fourier transform
  waveform <- spectrum_to_waveform(as.data.frame(ms_peaks[[i]]))

  # Write to .txt file to interrupt long tasks
  write(waveform, ncolumns = 1, file = paste0("waveforms/waveform_", i, ".txt"))
}

# Get total time length of the run waveform, not including the second of audio to be added
total_time <- round(sample_rate * max(ms_header$retentionTime))

# Initialise blank matrix for all waveforms
waveform_matrix <- NULL

# Read in the .txt files
for (i in 1:length(list.files("waveforms"))) {
  # Generate blank time before and after the waveform
  RT_pre <- rep(0, round(sample_rate * ms_header$retentionTime[i]))
  RT_post <- rep(0, total_time - length(RT_pre))
  
  # read in the waveform
  waveform <- read.delim(paste0("waveforms/waveform_", i, ".txt"), header = FALSE)[, 1]

  # Account for intensity
  waveform <- waveform * ms_header[i]$totIonCurrent

  # Add in blank time before and after
  waveform <- c(RT_pre, waveform, RT_post)

  # Add to the waveform matrix
  waveform_matrix <- rbind(waveform_matrix, waveform)
}

# Add all of the waveforms together
run_waveform <- colSums(waveform_matrix)

# Normalise
run_waveform <- (run_waveform / max(abs(run_waveform))) * 32000

# Create wav object
wave_obj <- Wave(round(run_waveform), samp.rate = sample_rate, bit = 16)

# Play the sound
play(wave_obj)

# Save as .wav
writeWave(wave_obj, file = "run.wav")


# Testing matrix functions
test_matrix <- NULL
tot_length <- 6

# Read in the .txt files
for (i in 1:4) {
  # Generate blank time before and after the waveform
  RT_pre <- rep(0, round(1 * i))
  RT_post <- rep(0, tot_length - length(RT_pre))
  
  # Add in blank time before and after
  waveform <- c(RT_pre, i, RT_post)
  print(i)
  print(waveform)
  
  # Add to the waveform matrix
  test_matrix <- rbind(test_matrix, waveform)
}
