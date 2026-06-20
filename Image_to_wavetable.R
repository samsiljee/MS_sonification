# Data to wavetable for Vital
# Sam Siljee
# 4th June 2026

# Libraries
library(tuneR) # Audio files
library(dplyr) # Data manipulation and piping
library(png) # Load in image
library(pracma) # interp2 call in the make_image_wavetable function

# Load custom functions
source("functions.R")

# Read in image
image_data <- readPNG("ULTRASOUND OBSTETRIC ANATOMY - Set 3 - Image 63.png")

# Reduce to 2D greyscale, mean RGB channels
image_matrix <- (image_data[, , 1] + image_data[, , 2] + image_data[, , 3]) / 3

# Call function to turn image into a wavetable
wavetable_vector <- make_image_wavetable(
    image_matrix,
    data_points = 2048,
    frames = 256,
    row_wise = FALSE)

# Check some individual wavecycles
plot(1:2048, wavetable_vector[1:2048], type = "l")
plot(1:2048, wavetable_vector[((255*2048)+1):((255*2048)+2048)], type = "l")
plot(1:2048, wavetable_vector[((100*2048)+1):((100*2048)+2048)], type = "l")

# Export to wavetable
wavetable <- Wave(round(wavetable_vector), samp.rate = 44100, bit = 16)

# Export directly to Vital directory
writeWave(wavetable, file = "C:/Users/Sam/Documents/Vital/User/Wavetables/image_wavetable.wav")
