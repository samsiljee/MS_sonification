# Function to create a polyphonic sound from a raw mass-spectrometry spectrum
# Sam Siljee
# Created 5th March 2024
# Input: A table input of two columns, one column (m/z of the peak) determines the frequency of the sinewave, the second (intensity) determines the relative amplitude of that peak in the polyphonic signal
# Output: An audio object of one second duration
# This function requires the "tuneR" package

# Load the required packages
library(tuneR)

# test data
spectrum <- data.frame(
  frequency = c(440, 660, 880),
  amplitude = c(0.1, 0.5, 0.5) * 100
)

# Run the function
audio_obj <- sonify_spectrum(spectrum)

# Play the sound
play(audio_obj)

# Save the audio as a WAV file
writeWave(audio_obj, file = "polyphonic_sound.wav")

sonify_spectrum <- function(spectrum) {
  # Create a blank time vector for 1s of tone
  time <- seq(0, 2 * pi, length = 44100)

  # Initialize an empty vector for the sound signal
  sound_signal <- numeric(length(time))

  # Add a sinewave for each row of the table
  for (i in 1:nrow(spectrum)) {
    # Generate sine wave
    sine_wave <- round((spectrum$amplitude[i]) * sin(spectrum$frequency[i] * time))

    # Add the sine wave to the sound signal
    sound_signal <- sound_signal + sine_wave
  }

  # Normalize the sound signal
  sound_signal <- (sound_signal / max(abs(sound_signal))) * 32000

  # Create an audio object
  return(Wave(sound_signal, samp.rate = 44100))
}