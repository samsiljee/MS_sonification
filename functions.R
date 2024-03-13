# Function to create polyphonic sounds from a raw mass-spectrometry spectrum
# Sam Siljee
# Created 5th March 2024

# Functon to convert a spectrum into a tone
# Input: A table input of two columns, one column (m/z of the peak) determines the frequency of the sinewave, the second (intensity) determines the relative amplitude of that peak in the polyphonic signal
# Output: An audio object of one second duration
# This function requires the "tuneR" and "dplyr" packages

tonify_spectrum <- function(spectrum, duration = 1, sampling_rate = 44100) {
  # Call the spectrum_to_waveform function
  sound_signal <- spectrum_to_waveform(spectrum = spectrum, duration = duration, sampling_rate = sampling_rate)

  # Create an audio object
  return(Wave(round(sound_signal), samp.rate = 44100, bit = 16))
}


# Function to take a spectrum and return a waveform as a numeric vector
# Input: A table input of two columns, one column (m/z of the peak) determines the frequency of the sinewave, the second (intensity) determines the relative amplitude of that peak in the polyphonic signal
# Output: An audio object of one second duration
# This function requires the "tuneR" and "dplyr" packages

spectrum_to_waveform <- function(spectrum, duration = 1, sampling_rate = 44100) {
  # Start time for optimisation 
  # start_time <- Sys.time()
  
  # Filter out peaks of 0 intensity
  dat <- as.data.frame(spectrum) %>%
    filter(intensity > 0)

  # Create time sequence
  time_seq <- seq(0, duration * 2 * pi, length = duration * sampling_rate)

  # Create and add a sine wave for every peak
  sound_signal <- (sin(outer(time_seq, dat$mz, "*")) %*% dat$intensity)
  
  # Normalize the sound signal
  sound_signal <- (sound_signal / max(abs(sound_signal))) * 32000

  # Return the waveform as a numeric vector
  return(round(sound_signal))
  # return(Sys.time() - start_time)
}


# Function to convert a chromatogram into an audio clip
# Input: a vector of TIC from a chromatogram
# Output: An audio object of variable duration
# This function requires the "tuneR" and "dplyr" packages

tonify_chromatogram <- function(TIC) {
  # Normalize the TIC vector
  sound_signal <- (TIC / max(abs(TIC))) * 32000

  # Create an audio object
  return(Wave(round(sound_signal), samp.rate = 44100, bit = 16))
}
