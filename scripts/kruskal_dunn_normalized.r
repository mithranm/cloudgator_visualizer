# kruskal_dunn_normalized.R
# Purpose: Run Kruskal-Wallis and Dunn's tests on normalized spot prices.

library(dunn.test)
library(dplyr)
library(readr)

cat("Running kruskal_dunn_normalized.R...\n")

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
df_cpu_only <- df %>% filter(!is.na(cpu_spot_norm_price) & cpu_compute_score > 0)

cat("\n--- Kruskal-Wallis Test for CPU Normalized Spot Price ---\n")
kruskal_cpu <- kruskal.test(cpu_spot_norm_price ~ provider, data = df_cpu_only)
print(kruskal_cpu)

if (kruskal_cpu$p.value < 0.05) {
  cat("\nSignificant differences found for CPU normalized prices. Running Dunn\'s test...\n")
  dunn_cpu <- dunn.test(
    x = df_cpu_only$cpu_spot_norm_price,
    g = df_cpu_only$provider,
    method = "bonferroni"
  )
  print(dunn_cpu)
}

# GPU normalization using a lookup table
df <- df %>%
  mutate(
    gpu_count = as.numeric(gpu_count),
    gpu_score = case_when(
      gpu_model == "A10" ~ 6,
      gpu_model == "A100" ~ 10,
      gpu_model == "A100-80GB" ~ 10,
      gpu_model == "A10G" ~ 8,
      gpu_model == "Gaudi HL-205" ~ 7,
      gpu_model == "H100" ~ 12,
      gpu_model == "H100-MEGA" ~ 13,
      gpu_model == "K80" ~ 3,
      gpu_model == "L4" ~ 5,
      gpu_model == "L40S" ~ 8,
      gpu_model == "M60" ~ 4,
      gpu_model == "P100" ~ 6,
      gpu_model == "P4" ~ 5,
      gpu_model == "Radeon MI25" ~ 5,
      gpu_model == "Radeon Pro V520" ~ 4,
      gpu_model == "T4" ~ 5,
      gpu_model == "T4g" ~ 5,
      gpu_model == "V100" ~ 7,
      gpu_model == "V100-32GB" ~ 8,
      TRUE ~ 5
    ),
    total_gpu_compute = gpu_score * gpu_count,
    gpu_spot_norm_price = ifelse(total_gpu_compute > 0, spot_price_per_hour / total_gpu_compute, NA)
  )
df_gpu_only <- df %>% filter(!is.na(gpu_spot_norm_price) & total_gpu_compute > 0)

cat("\n--- Kruskal-Wallis Test for GPU Normalized Spot Price ---\n")
kruskal_gpu <- kruskal.test(gpu_spot_norm_price ~ provider, data = df_gpu_only)
print(kruskal_gpu)

if (kruskal_gpu$p.value < 0.05) {
  cat("\nSignificant differences found for GPU normalized prices. Running Dunn\'s test...\n")
  dunn_gpu <- dunn.test(
    x = df_gpu_only$gpu_spot_norm_price,
    g = df_gpu_only$provider,
    method = "bonferroni"
  )
  print(dunn_gpu)
}

cat("kruskal_dunn_normalized.R completed.\n")