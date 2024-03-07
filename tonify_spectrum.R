# Function to create a polyphonic sound from a raw mass-spectrometry spectrum
# Sam Siljee
# Created 5th March 2024
# Input: A table input of two columns, one column (m/z of the peak) determines the frequency of the sinewave, the second (intensity) determines the relative amplitude of that peak in the polyphonic signal
# Output: An audio object of one second duration
# This function requires the "tuneR" and "dplyr" packages

tonify_spectrum <- function(spectrum, filter_threshold = 0) {
  # Filter out peaks of 0 intensity
  dat <- spectrum %>%
    filter(intensity > max(spectrum$intensity) * filter_threshold)

  # Normalise the intensity
  dat$intensity <- dat$intensity / max(dat$intensity) * 10000000

  # Create a blank time vector for 1s of tone
  time <- seq(0, 2 * pi, length = 44100)

  # Initialize an empty vector for the sound signal
  sound_signal <- numeric(length(time))

  # Add a sinewave for each row of the table
  for (i in 1:nrow(dat)) {
    # Generate sine wave
    sine_wave <- dat$intensity[i] * sin(round(dat$mz[i]) * time)

    # Add the sine wave to the sound signal
    sound_signal <- sound_signal + sine_wave
  }

  # Normalize the sound signal
  sound_signal <- (sound_signal / max(abs(sound_signal))) * 32000

  # Create an audio object
  return(Wave(round(sound_signal), samp.rate = 44100, bit = 16))
}
