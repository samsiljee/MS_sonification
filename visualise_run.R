# Script to for accompanying visualisation to sonification
# Sam Siljee
# 19 March 2024
# MIT licence

# Libraries
library(mzR)
library(dplyr)
library(ggplot2)

# Source functions
source("functions.R")

# Load and extract data
ms_data <- openMSfile("test.mzML")
ms_peaks <- peaks(ms_data)
ms_header <- header(ms_data)

# Get list of MS1 and MS2 spectrum indexes and rows
ms1_indexes <- filter(ms_header, msLevel == 1) %>% .$seqNum
ms2_indexes <- filter(ms_header, msLevel == 2) %>% .$seqNum

# Write the plots to the plot folder
for (i in 1:10) {
  ms_peaks[[i]] %>%
    plot_spectrum()
  ggsave(
    filename = paste0("plots/plot_", i, ".png"),
    width = 4000,
    height = 4000,
    units = "px",
    dpi = 600
  )
  print(i)
}
