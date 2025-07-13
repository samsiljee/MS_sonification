# Script to make some tones for the Spectral_1 song
# Sam Siljee
# 12th July 2025

library(dplyr)

Interesting_proteins <- c(
  "P25705",
  "Q8N5M1",
  "P06576",
  "Q5TC12",
  "P36542",
  "P30049",
  "P56381",
  "P48047", # ATP synthase subunits
  "P14780", # MMP-9
  "Q05397", # Focal adhesion kinase
  "P16104" # H2AX
)

# Load the PSM data
load("~/Documents/Coding/MSstats_workflow/TMT_input/PSMs.rda")

data <- PSMs %>%
  filter(Master.Protein.Accessions %in% Interesting_proteins)

# Find the run with the most IDs
data %>%
  group_by(Spectrum.File) %>%
  summarise(count = n()) %>%
  arrange(desc(count))

# Identified "Mix_TMT_F5_20241219181938.raw" as having the most PSMs matching. Check which proteins are identified in this run
data %>% filter(
  Spectrum.File == "Mix_TMT_F5_20241219181938.raw" &
  Master.Protein.Accessions %in% Interesting_proteins
) %>%
  .$Master.Protein.Accessions %>%
  unique


