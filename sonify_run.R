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

# Initialise blank matrix for all waveforms
waveform_matrix <- matrix()

# Get total time length of the run waveform
total_time <- 44100 * max(ms_header$retentionTime)

# Read in the .txt files
for (i in list.files("waveforms")) {
  ## Generate blank time before and after the waveform
  # RT_pre <- rep(0, 44100 * ms_header[i]$retentionTime)
  # RT_post <- rep(0, total_time - RT_pre)

  # read in the waveform
  waveform <- read.delim(paste0("waveforms/", i), header = FALSE)[, 1]
  print(length(waveform))

  ## Account for intensity
  # waveform <- waveform * ms_header[i]$totIonCurrent
  # 
  # # Add in blank time before and after
  # waveform <- c(RT_pre, waveform, RT_post)

  # # Add to the waveform matrix
  # waveform_matrix <- rbind(waveform_matrix, waveform)
}

# Add all of the waveforms together
run_waveform <- colSums(waveform_matrix)

# Normalise
run_waveform <- (run_waveform / max(abs(run_waveform))) * 32000

# Save as .wav
writeWave(run_waveform, file = "run.wav")
