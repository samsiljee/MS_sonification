# Data to wavetable for Vital
# Sam Siljee
# 4th June 2026

# Libraries
library(tuneR)

# Load custom functions
source("functions.R")

# Make some fake data
fake_data <- data.frame(intensity = rnorm(20000))

# Run function to make wavetable
wavetable_vector <- make_wavecycle(fake_data)

# Plot to check waveform
plot(1:length(wavetable_vector), wavetable_vector, type = "l")

# Export to wavetable
wavetable <- Wave(round(wavetable_vector), samp.rate = 44100, bit = 16)

# Export directly to Vital directory
writeWave(wavetable, file = "C:/Users/Sam/Documents/Vital/User/Wavetables/wavetable.wav")
