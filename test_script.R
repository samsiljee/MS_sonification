# Test script for sonifying MS data
# Sam Siljee
# 5th March 2024

# Load the required packages
library(tuneR)
library(mzR)
library(dplyr)

# Source the tonification function
source("tonify_spectrum.R")
source("tonify_chromatogram.R")

# Open test MS file
ms_file <- openMSfile("22-091_1_1ul_SS.mzML")

# Extract all the peaks
ms_peaks <- peaks(ms_file)

# Extract correspondign header information
ms_header <- header(ms_file)

# Extract some spectra (faster than loading all peaks)
spectrum_1 <- peaks(ms_file, 2311)
spectrum_2 <- peaks(ms_file, 8401)

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
  audio_clip <- tonify_spectrum(as.data.frame(peaks(ms_file, scan = i)))
  play(audio_clip)
}

# extract the chromatogram
chr <- ProtGenerics::chromatogram(ms_file) %>% .[[1]]

# Create audio from chromatogram
chromatogram_audio <- tonify_chromatogram(chr$TIC)

# Playand save
play(chromatogram_audio)
writeWave(chromatogram_audio, file = "chromatogram.wav")
