# central_tendency.R
# Purpose: Calculate and print central tendency measures for normalized spot prices.

library(dplyr)
library(readr)

cat("Running central_tendency.R...\n")

# Read the merged CSV file
df <- read_csv("pl_output/merged_data.csv", show_col_types = FALSE)

# CPU normalization
df <- df %>%
  mutate(
    vcpus = as.numeric(vcpus),
    memory_gib = as.numeric(memory_gib),
    cpu_compute_score = vcpus + (memory_gib / 4),
    cpu_spot_norm_price = ifelse(cpu_compute_score > 0, spot_price_per_hour / cpu_compute_score, NA)
  )

cpu_summary <- df %>%
  filter(!is.na(cpu_spot_norm_price)) %>%
  group_by(provider) %>%
  summarize(
    mean_cpu_norm = mean(cpu_spot_norm_price, na.rm = TRUE),
    median_cpu_norm = median(cpu_spot_norm_price, na.rm = TRUE),
    .groups = "drop"
  )
cat("\nCPU Normalized Price Summary:\n")
print(cpu_summary)

# GPU normalization (using a default mapping for simplicity)
df <- df %>%
  mutate(
    gpu_count = as.numeric(gpu_count),
    gpu_score = ifelse(gpu_model == "T4", 5, 5),  # Adjust if needed
    total_gpu_compute = gpu_score * gpu_count,
    gpu_spot_norm_price = ifelse(total_gpu_compute > 0, spot_price_per_hour / total_gpu_compute, NA)
  )

gpu_summary <- df %>%
  filter(!is.na(gpu_spot_norm_price)) %>%
  group_by(provider) %>%
  summarize(
    mean_gpu_norm = mean(gpu_spot_norm_price, na.rm = TRUE),
    median_gpu_norm = median(gpu_spot_norm_price, na.rm = TRUE),
    .groups = "drop"
  )
cat("\nGPU Normalized Price Summary:\n")
print(gpu_summary)

cat("central_tendency.R completed.\n")