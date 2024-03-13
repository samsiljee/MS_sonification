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

# Load and extract data
ms_data <- openMSfile("test.mzML")
ms_peaks <- peaks(ms_data, scans = 1:100)
ms_header <- header(ms_data) %>% head(100)

# Get list of MS1 and MS2 spectrum indexes
ms_1_indexes <- filter(ms_header, msLevel == 1) %>% .$seqNum
ms_2_indexes <- filter(ms_header, msLevel == 2) %>% .$seqNum

# Synthesise waveforms, and write to .txt (so big runs can be interupted)
for (i in 1:nrow(ms_header)) {
  waveform <- spectrum_to_waveform(as.data.frame(ms_peaks[[i]]))
  write(waveform, ncolumns = 1, file = paste0("waveforms/waveform_", i, ".txt"))
}

# Total time of run
total_time <- round(sample_rate * max(ms_header$retentionTime))

# Initialise blank matrix for all waveforms
waveform_matrix <- NULL

# Read in the .txt files and account for RT and total ion current
for (i in 1:length(list.files("waveforms"))) {
  # Generate blank time before and after the waveform
  RT_pre <- rep(0, round(sample_rate * ms_header$retentionTime[i]))
  RT_post <- rep(0, total_time - length(RT_pre))
  
  # read in the waveform and account for intensity
  waveform <- read.delim(paste0("waveforms/waveform_", i, ".txt"), header = FALSE)[, 1] * ms_header$totIonCurrent[i]

  # Add to the waveform
  waveform_matrix <- rbind(waveform_matrix, c(RT_pre, waveform, RT_post))
  waveform_matrix <- colSums(waveform_matrix)
}

# Normalise the waveform
run_waveform <- (run_waveform / max(abs(run_waveform))) * 32000

# Create wav object
wave_obj <- Wave(round(run_waveform), samp.rate = sample_rate, bit = 16)
play(wave_obj)

# Save as .wav
writeWave(wave_obj, file = "run.wav")

# Make a stereo compilation
# Left channel (MS1 spectra)
# Initialise blank matrix for all MS1 waveforms
ms1_waveform_matrix <- NULL

# Read in the .txt files
for (i in ms_1_indexes) {
  # Generate blank time before and after the waveform
  RT_pre <- rep(0, round(sample_rate * ms_header$retentionTime[i]))
  RT_post <- rep(0, total_time - length(RT_pre))
  
  # read in the waveform and account for intensity
  waveform <- read.delim(paste0("waveforms/waveform_", i, ".txt"), header = FALSE)[, 1] * ms_header$totIonCurrent[i]
  
  # Add to the waveform
  ms1_waveform_matrix <- rbind(ms1_waveform_matrix, c(RT_pre, waveform, RT_post))
  ms1_waveform_matrix <- colSums(ms1_waveform_matrix)
}

# Normalise the waveform
ms1_run_waveform <- (ms1_run_waveform / max(abs(ms1_run_waveform))) * 32000

# Repeat for MS2 scans
# Initialise blank matrix for all MS1 waveforms
ms2_waveform_matrix <- NULL

# Read in the .txt files
for (i in ms_2_indexes) {
  # Generate blank time before and after the waveform
  RT_pre <- rep(0, round(sample_rate * ms_header$retentionTime[i]))
  RT_post <- rep(0, total_time - length(RT_pre))
  
  # read in the waveform and account for intensity
  waveform <- read.delim(paste0("waveforms/waveform_", i, ".txt"), header = FALSE)[, 1] * ms_header$totIonCurrent[i]
  
  # Add to the waveform
  ms2_waveform_matrix <- rbind(ms2_waveform_matrix, c(RT_pre, waveform, RT_post))
  ms2_waveform_matrix <- colSums(ms2_waveform_matrix)
}

# Normalise the waveform
ms2_run_waveform <- (ms2_run_waveform / max(abs(ms2_run_waveform))) * 32000

# Create stereo wav object
stereo_wave_obj <- Wave(
  left = round(ms1_run_waveform),
  right = round(ms2_run_waveform),
  samp.rate = sample_rate,
  bit = 16)
play(stereo_wave_obj)

# Save as .wav
writeWave(stereo_wave_obj, file = "stereo_run.wav")
