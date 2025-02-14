# src/analyze_data.R

# Load required libraries
library(readr)
library(dplyr)
library(lubridate)
library(ggplot2)
library(rmarkdown)

# Read the merged CSV from the output directory
df <- read_csv("pl_output/merged_data.csv", show_col_types = FALSE)

# Convert the timestamp column to POSIXct format
df <- df %>% mutate(timestamp = ymd_hms(timestamp))

cat("Rows:", nrow(df), "Columns:", ncol(df), "\n")
num_timestamps <- n_distinct(df$timestamp)
cat("Number of distinct timestamps:", num_timestamps, "\n\n")

### --- CPU Compute Unit Analysis ---
# For CPU, we define a CPU compute score using vCPUs and RAM (with 4 GB = 1 unit)
df <- df %>%
  mutate(
    vcpus = as.numeric(vcpus),
    memory_gib = as.numeric(memory_gib),
    cpu_compute_score = vcpus + (memory_gib / 4)
  )

# Compute normalized CPU price ($ per compute unit)
df <- df %>%
  mutate(
    cpu_norm_price = price_per_hour / cpu_compute_score
  )

# Aggregate by provider (using median for robustness)
cpu_summary <- df %>%
  group_by(provider) %>%
  summarize(
    median_cpu_norm_price = median(cpu_norm_price, na.rm = TRUE),
    median_cpu_price = median(price_per_hour, na.rm = TRUE),
    count = n(),
    .groups = "drop"
  )

cat("CPU-based Aggregated Metrics by Provider:\n")
print(cpu_summary)
cat("\n")

# Plot CPU normalized price by provider (bar plot)
p_cpu <- ggplot(cpu_summary, aes(x = provider, y = median_cpu_norm_price, fill = provider)) +
  geom_bar(stat = "identity") +
  labs(title = "Median $ per CPU Compute Unit by Provider",
       x = "Provider",
       y = "Normalized Price ($ per CPU compute unit)") +
  theme_minimal() +
  theme(panel.background = element_rect(fill = "white", color = NA),
        plot.background = element_rect(fill = "white", color = NA))

ggsave("r_output/cpu_norm_price_by_provider.png", p_cpu, width = 8, height = 6)

### --- GPU Compute Unit Analysis ---
# Filter out rows with "Unknown" gpu_model
df_gpu <- df %>% filter(!(gpu_model %in% c("Unknown")) & !is.na(gpu_model))

# Define a lookup table for GPU weights based on experimental assignments
gpu_scores <- c(
  "A10" = 6,
  "A100" = 10,
  "A100-80GB" = 10,
  "A10G" = 8,
  "Gaudi HL-205" = 7,
  "H100" = 12,
  "H100-MEGA" = 13,
  "K80" = 3,
  "L4" = 5,
  "L40S" = 8,
  "M60" = 4,
  "P100" = 6,
  "P4" = 5,
  "Radeon MI25" = 5,
  "Radeon Pro V520" = 4,
  "T4" = 5,
  "T4g" = 5,
  "V100" = 7,
  "V100-32GB" = 8
)

# For GPU instances, assign a score from the lookup. If a model isn't found, default to 5.
df_gpu <- df_gpu %>%
  mutate(
    gpu_score = ifelse(gpu_model %in% names(gpu_scores), gpu_scores[gpu_model], 5),
    gpu_count = as.numeric(gpu_count),
    total_gpu_compute = gpu_score * gpu_count,
    gpu_norm_price = ifelse(total_gpu_compute > 0, price_per_hour / total_gpu_compute, NA)
  )

# Aggregate the GPU data by provider (using median for robustness)
gpu_summary <- df_gpu %>%
  group_by(provider) %>%
  summarize(
    median_gpu_norm_price = median(gpu_norm_price, na.rm = TRUE),
    median_gpu_price = median(price_per_hour, na.rm = TRUE),
    count = n(),
    .groups = "drop"
  )

cat("GPU-based Aggregated Metrics by Provider:\n")
print(gpu_summary)
cat("\n")

# Plot: Normalized GPU price per provider (bar plot)
p_gpu <- ggplot(gpu_summary, aes(x = provider, y = median_gpu_norm_price, fill = provider)) +
  geom_bar(stat = "identity") +
  labs(title = "Median $ per GPU Compute Unit by Provider",
       x = "Provider",
       y = "Normalized Price ($ per GPU compute unit)") +
  theme_minimal() +
  theme(panel.background = element_rect(fill = "white", color = NA),
        plot.background = element_rect(fill = "white", color = NA))

ggsave("r_output/gpu_norm_price_by_provider.png", p_gpu, width = 8, height = 6)

### --- Generate Analysis Report in Markdown for GitHub ---
# Create an R Markdown document with output configured for GitHub-flavored Markdown.
report_file <- "README.Rmd"

report_content <- '
---
title: "Cloud VM Instance Price Analysis Report"
author: "Mithran Mohanraj"
date: "`r Sys.Date()`"
output: github_document
---

## Introduction

This report provides an analysis of cloud instance prices based on CPU and GPU compute units. The data covers various cloud instance details from multiple providers, allowing for a robust comparison of cost-efficiency.

## Methodology

### Data Loading and Preprocessing
The analysis begins by reading a merged CSV file (`pl_output/merged_data.csv`) and converting the `timestamp` column to a standard date-time format. Numerical columns (such as `vcpus` and `memory_gib`) are explicitly cast to numeric types to ensure correct computations.

### CPU Compute Unit Analysis
For CPU analysis, a compute score is defined as:

\\[
\\operatorname{cpu\\_compute\\_score} = \\operatorname{vcpus} + \\frac{\\operatorname{memory\\_gib}}{4}
\\]

The hourly price is then normalized by dividing by this compute score:

\\[
\\operatorname{cpu\\_norm\\_price} = \\frac{\\operatorname{price\\_per\\_hour}}{\\operatorname{cpu\\_compute\\_score}}
\\]

Median values for the normalized CPU price are computed for each provider to allow a robust comparison across different offerings.

### GPU Compute Unit Analysis
For GPU analysis, instances with an unknown GPU model are filtered out. A lookup table assigns a score to each GPU model based on experimental benchmarks. The total GPU compute score is calculated as:

\\[
\\operatorname{total\\_gpu\\_compute} = \\operatorname{gpu\\_score} \\times \\operatorname{gpu\\_count}
\\]

The normalized GPU price is obtained by:

\\[
\\operatorname{gpu\\_norm\\_price} = \\frac{\\operatorname{price\\_per\\_hour}}{\\operatorname{total\\_gpu\\_compute}}
\\]

Median values are then computed per provider to mitigate the impact of outliers.

## Results

### CPU Analysis
The bar plot below shows the median normalized CPU price per compute unit for each provider.

![CPU Normalized Price](r_output/cpu_norm_price_by_provider.png)

### GPU Analysis
The bar plot below shows the median normalized GPU price per compute unit for each provider.

![GPU Normalized Price](r_output/gpu_norm_price_by_provider.png)

## Conclusion

This analysis provides insights into the relative cost-efficiency of cloud instances. The differences in CPU and GPU compute unit pricing across providers can help inform decisions regarding cloud resource procurement.
'

# Write the R Markdown content to a file
writeLines(report_content, con = report_file)

# Render the R Markdown document to a GitHub-flavored Markdown file
render(report_file, output_format = "github_document", clean = TRUE)

cat("Analysis report generated at: README.md\n")
