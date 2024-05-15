# Test script for sonifying MS data
# Sam Siljee
# 5th March 2024

# Load the required packages
library(tuneR)
library(mzR)
library(dplyr)
library(ggplot2)

# Source the tonification function
source("functions.R")

# Open test MS file
ms_data <- openMSfile("test.mzML")

# Extract all the peaks
ms_peaks <- peaks(ms_data)

# Extract correspondign header information
ms_header <- header(ms_data)

# Get list of MS1 and MS2 spectrum indexes
ms_1_indexes <- filter(ms_header, msLevel == 1) %>% .$seqNum
ms_2_indexes <- filter(ms_header, msLevel == 2) %>% .$seqNum

# Play a random MS1 spectrum
ms_data %>%
  peaks(scan = sample(ms_1_indexes, 1)) %>%
  as.data.frame() %>%
  tonify_spectrum() %>%
  play()

# Play a random MS2 spectrum
ms_data %>%
  peaks(scan = sample(ms_2_indexes, 1)) %>%
  as.data.frame() %>%
  tonify_spectrum() %>%
  play()

# Extract some spectra (faster than loading all peaks)
spectrum_1 <- peaks(ms_data, 2311)
spectrum_2 <- peaks(ms_data, 8401)

# Load test spectrum
spectrum_3 <- read.csv("test_spectra/spectrum_1.csv", header = TRUE)
spectrum_4 <- read.csv("test_spectra/spectrum_2.csv", header = TRUE)

# Run the function
spectrum_tone_1 <- tonify_spectrum(spectrum_1, 0)
spectrum_tone_2 <- tonify_spectrum(spectrum_2, 0)
spectrum_tone_3 <- tonify_spectrum(spectrum_3, 0)
spectrum_tone_4 <- tonify_spectrum(spectrum_4, 0)

# Play the sound
play(spectrum_tone_1)
play(spectrum_tone_2)
play(spectrum_tone_3)
play(spectrum_tone_4)

# Save the audio as a WAV file
writeWave(spectrum_tone_1, file = "spectrum_1.wav")
writeWave(spectrum_tone_2, file = "spectrum_2.wav")
writeWave(spectrum_tone_3, file = "spectrum_3.wav")
writeWave(spectrum_tone_4, file = "spectrum_4.wav")

# Example loop to check some spectra
for(i in c(100, 1000, 10000, 30000)) {
  audio_clip <- tonify_spectrum(as.data.frame(peaks(ms_data, scan = i)))
  play(audio_clip)
}

# extract the chromatogram
chr <- ProtGenerics::chromatogram(ms_data) %>% .[[1]]

# Create audio from chromatogram
chromatogram_audio <- tonify_chromatogram(chr$TIC)

# Play and save
play(chromatogram_audio)
writeWave(chromatogram_audio, file = "chromatogram.wav")

# Explore the number of MS2 spectra associated with each MS1 scan
ms_2_scan_numbers <- ms_header %>%
  filter(msLevel == 2) %>%
  group_by(precursorScanNum) %>%
  summarise(number_of_scans = n())
ms_2_scan_numbers %>%
  ggplot(aes(x = number_of_scans)) +
  geom_histogram(bins = 20)
