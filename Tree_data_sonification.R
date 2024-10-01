# Script to sonify test tree spectra
# Sam Siljee
# 1/10/24

# Libraries
library(tuneR) # Making audio files
library(dplyr) # Pipe

# Source functions
source("functions.R")

# Set some variables
directory <- "Tree_data"

# List files
files_list <- list.files(directory)

# Initialise list to load the spectra
spectrum_list <- as.list(files_list)

# Read in the data
for(i in 1:length(spectrum_list)){
  # Read in data
  dat <- read.delim(
    paste(directory, files_list[i], sep = "/"),
    sep = " ",
    header = FALSE)
  # Name columns
  colnames(dat) <- c("mz", "intensity")
  # Add to list
  spectrum_list[[i]] <- dat
}

# Create tones
for(i in 1:length(spectrum_list)){
  # Generate tone
  tone <- advanced_spectrum_to_tone(
    spectrum = spectrum_list[[i]],
    duration = 10
  )
  file_name <- paste(
    directory,
    paste0(strtrim(files_list[i], nchar(files_list[i]) - 4), ".wav"),
    sep = "/"
    )
  # Save as audio clip
  writeWave(tone, file = file_name)
}
