# Function to create a waveform from a chromatogram
# Sam Siljee
# Created 7th March 2024
# Input: a vector of TIC from a chromatogram
# Output: An audio object of variable duration
# This function requires the "tuneR" and "dplyr" packages

tonify_chromatogram <- function(TIC) {
  # Normalize the TIC vector
  sound_signal <- (TIC / max(abs(TIC))) * 32000

  # Create an audio object
  return(Wave(round(sound_signal), samp.rate = 44100, bit = 16))
}
