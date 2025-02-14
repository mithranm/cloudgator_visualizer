# scripts/create_analysis.R
# --------------------------------
# Purpose: Data preparation, summary statistics, CPU/GPU normalization,
# plotting, and printing outputs inline.

library(readr)
library(dplyr)
library(lubridate)
library(ggplot2)

cat("Running create_analysis.R...\n")

# Read the merged CSV file
df <- read_csv("pl_output/merged_data.csv", show_col_types = FALSE)

# Convert timestamp column if present
if ("timestamp" %in% names(df)) {
  df <- df %>% mutate(timestamp = ymd_hms(timestamp))
}
cat("Rows:", nrow(df), "Columns:", ncol(df), "\n")

# Filter for rows with a spot price
df_spot <- df %>% filter(!is.na(spot_price_per_hour))

# Create CPU compute score and normalized price
df_spot <- df_spot %>%
  mutate(
    vcpus = as.numeric(vcpus),
    memory_gib = as.numeric(memory_gib),
    cpu_compute_score = vcpus + (memory_gib / 4),
    cpu_spot_norm_price = ifelse(cpu_compute_score > 0,
                                 spot_price_per_hour / cpu_compute_score,
                                 NA)
  )

# Summarize CPU-based spot price
cpu_spot_summary <- df_spot %>%
  group_by(provider) %>%
  summarize(
    median_cpu_spot_norm_price = median(cpu_spot_norm_price, na.rm = TRUE),
    median_cpu_spot_price      = median(spot_price_per_hour, na.rm = TRUE),
    count                      = n(),
    .groups = "drop"
  )
cat("\nCPU-based Aggregated Spot Price Metrics:\n")
print(cpu_spot_summary)

# Plot CPU normalized bar chart
p_cpu_spot <- ggplot(cpu_spot_summary,
                     aes(x = provider, y = median_cpu_spot_norm_price, fill = provider)) +
  geom_bar(stat = "identity") +
  labs(
    title = "Median $ per CPU Compute Unit (Spot Price) by Provider",
    x = "Provider",
    y = "Normalized Spot Price ($ per CPU compute unit)"
  ) +
  theme_minimal()
print(p_cpu_spot)

# Save CPU plot
ggsave("r_output/create-analysis-1.png", p_cpu_spot, width = 8, height = 6)

# GPU analysis
df_gpu <- df_spot %>%
  filter(!(gpu_model %in% c("Unknown")) & !is.na(gpu_model))

gpu_scores <- c(
  "A10" = 6, "A100" = 10, "A100-80GB" = 10, "A10G" = 8,
  "Gaudi HL-205" = 7, "H100" = 12, "H100-MEGA" = 13, "K80" = 3,
  "L4" = 5, "L40S" = 8, "M60" = 4, "P100" = 6, "P4" = 5,
  "Radeon MI25" = 5, "Radeon Pro V520" = 4, "T4" = 5, "T4g" = 5,
  "V100" = 7, "V100-32GB" = 8
)
df_gpu <- df_gpu %>%
  mutate(
    gpu_score = ifelse(gpu_model %in% names(gpu_scores), gpu_scores[gpu_model], 5),
    gpu_count = as.numeric(gpu_count),
    total_gpu_compute = gpu_score * gpu_count,
    gpu_spot_norm_price = ifelse(total_gpu_compute > 0,
                                 spot_price_per_hour / total_gpu_compute,
                                 NA)
  )

# Summarize GPU-based spot price
gpu_spot_summary <- df_gpu %>%
  group_by(provider) %>%
  summarize(
    median_gpu_spot_norm_price = median(gpu_spot_norm_price, na.rm = TRUE),
    median_gpu_spot_price      = median(spot_price_per_hour, na.rm = TRUE),
    count                      = n(),
    .groups = "drop"
  )
cat("\nGPU-based Aggregated Spot Price Metrics:\n")
print(gpu_spot_summary)

# Plot GPU normalized bar chart
p_gpu_spot <- ggplot(gpu_spot_summary,
                     aes(x = provider, y = median_gpu_spot_norm_price, fill = provider)) +
  geom_bar(stat = "identity") +
  labs(
    title = "Median $ per GPU Compute Unit (Spot Price) by Provider",
    x = "Provider",
    y = "Normalized Spot Price ($ per GPU compute unit)"
  ) +
  theme_minimal()
print(p_gpu_spot)

# Save GPU plot
ggsave("r_output/create_analysis-2.png", p_gpu_spot, width = 8, height = 6)

# Optional: Plot spot price over time if timestamp is available
if ("timestamp" %in% names(df_spot)) {
  time_series_spot <- df_spot %>%
    group_by(provider, timestamp) %>%
    summarize(median_spot_price = median(spot_price_per_hour, na.rm = TRUE),
              .groups = "drop")

  # Adjust the plot to clearly show each timestamp
  p_time_spot <- ggplot(time_series_spot,
                        aes(x = timestamp, y = median_spot_price)) +
    geom_line(color = "steelblue") +
    geom_point(color = "red", size = 3) +  # Larger red points
    facet_wrap(~ provider, scales = "free_y") +
    scale_x_datetime(date_breaks = "12 hours", date_labels = "%b-%d %H:%M") +
    labs(
      title = "Spot Price Changes Over Time (Faceted by Provider)",
      x = "Timestamp",
      y = "Median Spot Price per Hour"
    ) +
    theme_minimal()

  print(p_time_spot)

  # Save timeseries plot
  ggsave("r_output/create_analysis-3.png", p_time_spot, width = 10, height = 6)
}

cat("\ncreate_analysis.R completed.\n")