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
    dplyr::filter(intensity > 0)

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
# Input: One spectrum, with columns "mz" and "intensity"
# Output: A plot object
# This function requires the "dplyr" and "ggplot2" packages

plot_spectrum <- function(spectrum) {
  # Filter out peaks of 0 intensity
  dat <- as.data.frame(spectrum) %>%
    dplyr::filter(intensity > 0)

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
    log_transform_mz = FALSE,
    log_transform_intensity = FALSE,
    reverse_mz = FALSE) {
  # Filter out peaks of 0 intensity
  dat <- as.data.frame(spectrum) %>%
    dplyr::filter(intensity > 0)

  # Filter more peaks if selected
  if (filter_mz) {
    # Arrange the data
    dat <- arrange(dat, by = desc(mz))
    # Take the top X peaks
    dat <- dat[1:round(nrow(dat) * filter_threshold), ]
  }

  # Log2 transform m/z values if selected
  if (log_transform_mz) {
    # Save old m/z values for re-scaling if needed
    old_min <- min(dat$mz)
    old_max <- max(dat$mz)
    # Log transform
    dat$mz <- log2(dat$mz)
    # Re-scale if not scaling separately
    if (!scale) {
      dat$mz <- (dat$mz - min(dat$mz)) / max(dat$mz - min(dat$mz)) * (old_max - old_min) + old_min
    }
  }
  
  # Log transform intensity values if selected
  if (log_transform_intensity) {
    dat$intensity <- log2(dat$intensity)
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


# Function to plot two spectra back-to-back for visualisation purposes
# Input: Two spectra, with columns "mz" and "intensity"
# Output: A plot object
# This function requires the "dplyr" and "ggplot2" packages

double_plot <- function(
    spectrum_left,
    spectrum_right,
    colour_1 = "darkblue",
    colour_2 = "white",
    colour_3 = "salmon",
    contrast = 1,
    precursor_mz = 0,
    precursor_intensity = 0) {
  # Combine the two spectra into the same dataset and normalise the intensities
  plot <- rbind(
    spectrum_left %>%
      mutate(
        side = "left",
        intensity = intensity / max(intensity)
      ),
    spectrum_right %>%
      mutate(
        side = "right",
        intensity = intensity / max(intensity)
      ),
    data.frame(
      mz = precursor_mz,
      intensity = precursor_intensity / max(spectrum_left$intensity),
      side = "precursor"
    )
  ) %>%
    # Create the plot
    ggplot(
      aes(
        x = mz,
        y = ifelse(side == "right", intensity, -intensity),
        fill = side
      )
    ) +
    # Colours for the plotted spectra
    scale_color_manual(
      values = c(colour_1, colour_3, colour_2),
      aesthetics = "fill"
    ) +
    # Half/half background - to reduce the contrast
    annotate(
      geom = "rect",
      ymin = -Inf,
      ymax = Inf,
      xmin = -Inf,
      xmax = Inf,
      colour = NA,
      fill = colour_2,
      alpha = 0.5
    ) +
    # Background for the right side
    annotate(
      geom = "rect",
      ymin = 0,
      ymax = Inf,
      xmin = -Inf,
      xmax = Inf,
      colour = NA,
      fill = colour_1,
      alpha = contrast
    ) +
    # Background for the left side
    annotate(
      geom = "rect",
      ymin = -Inf,
      ymax = 0,
      xmin = -Inf,
      xmax = Inf,
      colour = NA,
      fill = colour_2,
      alpha = contrast
    ) +
    # Plot the spectra
    geom_col(
      width = 5,
      position = "jitter",
      show.legend = FALSE,
      alpha = contrast
    ) +
    # Rotate and apply theme
    coord_flip() +
    theme_void() +
    theme(panel.background = element_rect(fill = colour_1, color = NULL))
  return(plot)
}


# Function to image two spectra as crossing lines
# Input: Two spectra, with columns "mz" and "intensity"
# Output: An image object
# This function requires the "data.table" package

double_image <- function(
    spectrum_1,
    spectrum_2,
    colour_1 = "white",
    colour_2 = "darkblue",
    x_dim = 1920,
    y_dim = 1080) {
  # Set some variables
  color_palette <- colorRampPalette(c(colour_1, colour_2))
  x_min <- min(spectrum_1$mz)
  x_max <- max(spectrum_1$mz)
  x_bin_size <- (max(spectrum_1$mz) - min(spectrum_1$mz)) / x_dim
  x_vect <- numeric(x_dim)
  y_min <- min(spectrum_2$mz)
  y_max <- max(spectrum_2$mz)
  y_bin_size <- (max(spectrum_2$mz) - min(spectrum_2$mz)) / y_dim
  y_vect <- numeric(y_dim)

  # Convert the spectra to datatables
  setDT(spectrum_1)
  setDT(spectrum_2)

  # Create bins for mz values
  spectrum_1[, bin := cut(mz, breaks = seq(x_min, x_max, length.out = x_dim + 1), include.lowest = TRUE, labels = FALSE)]
  spectrum_2[, bin := cut(mz, breaks = seq(y_min, y_max, length.out = y_dim + 1), include.lowest = TRUE, labels = FALSE)]

  # Sum intensities within each bin
  x_binned_intensities <- spectrum_1[, .(total_intensity = sum(intensity, na.rm = TRUE)), by = bin]
  y_binned_intensities <- spectrum_2[, .(total_intensity = sum(intensity, na.rm = TRUE)), by = bin]

  # Fill in the vectors
  x_vect[x_binned_intensities$bin] <- x_binned_intensities$total_intensity
  y_vect[y_binned_intensities$bin] <- y_binned_intensities$total_intensity

  # Normalise the vectors
  x_vect <- x_vect / max(x_vect)
  y_vect <- y_vect / max(y_vect)

  # Add the two vectors together to create a matrix
  image_matrix <- outer(y_vect, x_vect, pmax)

  # Create the image
  par(mar = c(0, 0, 0, 0)) # Remove margins
  return(
    image(
      1:x_dim, 1:y_dim,
      t(image_matrix[y_dim:1, ]),
      col = color_palette(256), axes = FALSE, xlab = "", ylab = ""
    )
  )
}
