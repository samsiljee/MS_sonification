# Data to wavetable for Vital
# Sam Siljee
# 4th June 2026

# Libraries
library(tuneR) # Audio files
library(mzR) # MS data handling

# Load custom functions
source("functions.R")

# Load raw MS data
#ms_data <- openMSfile("Mix_TMT_F5_20241219181938.mzML")
ms_data <- openMSfile("test.mzML")

# Get metadata to identify spectrum with the most peaks
ms_header <- header(ms_data)

# Extract spectrum with the most peaks
top_spectrum <- peaks(ms_data, which(ms_header$peaksCount == max(ms_header$peaksCount)))

# Pick spectrum with 200 peaks
spectrum <- peaks(ms_data, 10672)

# Run function to make wavetable
wavetable_vector <- make_wavecycle(as.data.frame(spectrum))

# Plot to check waveform
plot(1:length(wavetable_vector), wavetable_vector, type = "l")

# Export to wavetable
wavetable <- Wave(round(wavetable_vector), samp.rate = 44100, bit = 16)

# Export directly to Vital directory
writeWave(wavetable, file = "C:/Users/Sam/Documents/Vital/User/Wavetables/wavetable.wav")
