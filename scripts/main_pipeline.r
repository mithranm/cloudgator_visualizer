# main_pipeline.R
# ------------------------------------------------------------
# This script generates a unified final report that includes outputs
# from create_analysis.R, central_tendency.R, and kruskal_dunn_normalized.R.
# The final report is rendered as README.md in the project root.
# The intermediate R Markdown file is created in a temporary folder.

library(rmarkdown)
cat("=== Starting unified pipeline ===\n")

# Define a temporary file for the intermediate R Markdown report
temp_rmd <- file.path(tempdir(), "final_pipeline.Rmd")

# Build the content of the final report.
# Note that we have removed the 'self_contained: false' option
# to avoid errors in older rmarkdown versions.
# Instead, we rely on chunk options to ensure relative figure paths.

report_content <- '
---
title: "CloudGator Unified Analysis Report"
author: "Mithran Mohanraj"
date: "`r Sys.Date()`"
output: github_document
---

```{r setup, include=FALSE}
# Force knitr to treat the project root as the working directory.
# Also specify that figures should be stored in a relative path.
knitr::opts_knit$set(root.dir = getwd())
knitr::opts_chunk$set(
  fig.path   = "README_files/figure-gfm/",
  echo       = TRUE,
  message    = TRUE,
  warning    = TRUE
)
```

# Introduction

This report attempts to evaluate the Spot Prices of VM Instances from the
big three clouds: AWS, Azure, and GCP. It combines outputs from several
analysis scripts:

1. **Basic Analysis & Plots** (from `scripts/create_analysis.R`)
2. **Central Tendency Summaries** (from `scripts/central_tendency.R`)
3. **Statistical Tests** (from `scripts/kruskal_dunn_normalized.R`)

Below you will find the detailed outputs from each step.

---

## 1. Basic Analysis & Plots

```{r create_analysis}
source("scripts/create_analysis.R")
```

---

## 2. Central Tendency Summaries

```{r central_tendency}
source("scripts/central_tendency.R")
```

---

## 3. Statistical Tests (Kruskal-Wallis & Dunn)

```{r statistical_tests}
source("scripts/kruskal_dunn_normalized.R")
```
'

# Write the intermediate Rmd file to the temporary directory
writeLines(report_content, con = temp_rmd)
cat("Created intermediate Rmd file at:", temp_rmd, "\n")

# Render the report to project root as README.md,
# setting knit_root_dir = getwd() for consistent relative paths.
render(
  input          = temp_rmd, 
  output_file    = "README.md", 
  output_dir     = getwd(),      # Render to project root
  output_format  = "github_document", 
  clean          = TRUE,
  knit_root_dir  = getwd()
)

cat("Final report generated as README.md in the project root\n")