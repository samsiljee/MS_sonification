# Test script for sonifying MS data
# Sam Siljee
# 5th March 2024

# Load the required packages
library(tuneR)
library(mzR)
library(dplyr)

# Source the tonification function
source("tonify_spectrum.R")

# Open test MS file
ms <- openMSfile("22-091_1_1ul_SS.mzML")

# Extract some spectra
spectrum_1 <- as.data.frame(peaks(ms, 2311))
spectrum_2 <- as.data.frame(peaks(ms, 8401))

# Load test spectrum
spectrum_3 <- read.csv("test_spectra/spectrum_1.csv", header = TRUE)
spectrum_4 <- read.csv("test_spectra/spectrum_2.csv", header = TRUE)

# Run the function
# audio_tone <- tonify_spectrum(spectrum)
audio_tone_1 <- tonify_spectrum(spectrum_1)
audio_tone_2 <- tonify_spectrum(spectrum_2)
audio_tone_3 <- tonify_spectrum(spectrum_4)
audio_tone_3 <- tonify_spectrum(spectrum_4)

# Play the sound
play(audio_tone_1)
play(audio_tone_2)
play(audio_tone_3)
play(audio_tone_4)

# Save the audio as a WAV file
writeWave(audio_tone_1, file = "polyphonic_sound.wav")
