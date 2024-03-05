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

# Extract the 700th spectrum
spectrum <- as.data.frame(peaks(ms, 311))
spectrum2 <- as.data.frame(peaks(ms, 401))

# Run the function
# audio_tone <- tonify_spectrum(spectrum)
audio_tone2 <- tonify_spectrum(spectrum)

# Play the sound
play(audio_tone)
play(audio_tone2)

# Save the audio as a WAV file
writeWave(audio_obj, file = "polyphonic_sound.wav")
