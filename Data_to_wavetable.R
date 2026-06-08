# Data to wavetable for Vital
# Sam Siljee
# 4th June 2026

# Libraries
library(tuneR) # Audio files
library(dplyr) # Data manipulation and piping
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


# Use tone to make complete wavetable
# Read in 7 minutes wide tone
tone <- readWave("wide_drone_7min.wav")
tone <- tone@left

# # Make a tone
# tone <- advanced_spectrum_to_tone(
#   spectrum = top_spectrum,
#   duration = 12, # sufficient for 256 * 2048 samples at 44,100 Hz
#   scale = TRUE,
#   scale_min = 100,
#   scale_max = 15000,
#   waveform = "sine"
# )

# Initialise wavetable vector
wavetable_2 <- numeric()

# Loop through vector for each frame
for(i in 1:256) {
  start_point <- (i*2048)-2047
  end_point <- start_point + 2047
  wavetable_2 <- c(
    wavetable_2,
    make_wavecycle(data.frame(intensity = tone[start_point:end_point]))
  )
}

# Export to wavetable
wavetable_2 <- Wave(round(wavetable_2), samp.rate = 44100, bit = 16)

# Export directly to Vital directory
writeWave(wavetable_2, file = "full_tone_wavetable.wav")
