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
ms <- openMSfile("22-091_1_1ul_SS.mzML")

# Extract some spectra
spectrum_1 <- as.data.frame(peaks(ms, 2311))
spectrum_2 <- as.data.frame(peaks(ms, 8401))

# Load test spectrum
spectrum_3 <- read.csv("test_spectra/spectrum_1.csv", header = TRUE)
spectrum_4 <- read.csv("test_spectra/spectrum_2.csv", header = TRUE)

# Run the function
spectrum_tone_1 <- tonify_spectrum(spectrum_1)
spectrum_tone_2 <- tonify_spectrum(spectrum_2)
spectrum_tone_3 <- tonify_spectrum(spectrum_3)
spectrum_tone_4 <- tonify_spectrum(spectrum_4)

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

# extract the chromatogram
chr <- ProtGenerics::chromatogram(ms) %>% .[[1]]

# Create audio from chromatogram
chromatogram_audio <- tonify_chromatogram(chr$TIC)

# Playand save
play(chromatogram_audio)
writeWave(chromatogram_audio, file = "chromatogram.wav")
