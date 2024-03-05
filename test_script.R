# Test script for sonifying MS data
# Sam Siljee
# 5th March 2024

# Load the required packages
library(tuneR)

# Source the function
source("tonify_spectrum.R")

# test data
spectrum <- data.frame(
  frequency = c(440, 660, 880),
  amplitude = c(0.1, 0.5, 0.5)
)

# Run the function
audio_obj <- tonify_spectrum(spectrum)

# Play the sound
play(audio_obj)

# Save the audio as a WAV file
writeWave(audio_obj, file = "polyphonic_sound.wav")