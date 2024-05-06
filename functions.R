# Function to create polyphonic sounds from a raw mass-spectrometry spectrum
# Sam Siljee
# Created 5th March 2024

# Function to convert a spectrum into a tone
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


# Function to convert a spectrum into a plot
# Input: a vector of TIC from a chromatogram
# Output: An audio object of variable duration
# This function requires the "tuneR" and "dplyr" packages

plot_spectrum <- function(spectrum) {
  # Filter out peaks of 0 intensity
  dat <- as.data.frame(spectrum) %>%
    filter(intensity > 0)

  # Create plot
  plot <- dat %>%
    ggplot(aes(x = mz, y = intensity)) +
    geom_line(col = "green") +
    theme_void() +
    theme(
      plot.background = element_rect(fill = "black")
    )

  # Return plot
  return(plot)
}

# Function to convert a spectrum into a tone, with extra options
# Input: A table input of two columns, one column (m/z of the peak) determines the frequency of the sinewave, the second (intensity) determines the relative amplitude of that peak in the polyphonic signal
# Output: An audio object of one second duration
# This function requires the "tuneR" and "dplyr" packages

# Generate the function to test different options
advanced_spectrum_to_tone <- function(
    spectrum,
    duration = 1,
    sampling_rate = 44100,
    filter_mz = FALSE,
    filter_threshold = 0.5,
    scale = FALSE,
    scale_min = 100,
    scale_max = 15000,
    log_transform = FALSE,
    reverse_mz = FALSE) {
  # Filter out peaks of 0 intensity
  dat <- as.data.frame(spectrum) %>%
    filter(intensity > 0)

  # Filter more peaks if selected
  if (filter_mz) {
    # Arrange the data
    dat <- arrange(dat, by = desc(mz))
    # Take the top X peaks
    dat <- dat[1:round(nrow(dat) * filter_threshold), ]
  }

  # Log2 transform if selected
  if (log_transform) {
    # Save old m/z values for re-scaling if needed
    old_min <- min(dat$mz)
    old_max <- max(dat$mz)
    # Log transform
    dat$mz <- log2(dat$mz)
    # Re-scale if not scaling separately
    if(!scale) {
      dat$mz <- (dat$mz - min(dat$mz)) / max(dat$mz - min(dat$mz)) * (old_max - old_min) + old_min
    }
  }

  # Scale m/z if selected
  if (scale) {
    dat$mz <- (dat$mz - min(dat$mz)) / max(dat$mz - min(dat$mz)) * (scale_max - scale_min) + scale_min
  }

  # Reverse mz values if selected
  if (reverse_mz) {
    dat$mz <- ((dat$mz - mean(c(max(dat$mz), min(dat$mz)))) * -1) + mean(c(max(dat$mz), min(dat$mz)))
  }

  # Create time sequence
  time_seq <- seq(0, duration * 2 * pi, length = duration * sampling_rate)

  # Create and add a sine wave for every peak
  sound_signal <- (sin(outer(time_seq, dat$mz, "*")) %*% dat$intensity)

  # Normalize the sound signal and return as numeric vector
  sound_signal <- round((sound_signal / max(abs(sound_signal))) * 32000)

  # Return audio object
  return(Wave(round(sound_signal), samp.rate = 44100, bit = 16))
}
