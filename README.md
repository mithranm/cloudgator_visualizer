CloudGator Unified Analysis Report
================
Mithran Mohanraj
2025-02-14

# Introduction

This report attempts to evaluate the Spot Prices of VM Instances from
the big three clouds: AWS, Azure, and GCP. It combines outputs from
several analysis scripts:

1.  **Basic Analysis & Plots** (from `scripts/create_analysis.R`)
2.  **Central Tendency Summaries** (from `scripts/central_tendency.R`)
3.  **Statistical Tests** (from `scripts/kruskal_dunn_normalized.R`)

Below you will find the detailed outputs from each step.

------------------------------------------------------------------------

## 1. Basic Analysis & Plots

``` r
source("scripts/create_analysis.R")
```

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

    ## 
    ## Attaching package: 'lubridate'

    ## The following objects are masked from 'package:base':
    ## 
    ##     date, intersect, setdiff, union

    ## Running create_analysis.R...
    ## Rows: 18968 Columns: 13 
    ## 
    ## CPU-based Aggregated Spot Price Metrics:
    ## # A tibble: 3 × 4
    ##   provider median_cpu_spot_norm_price median_cpu_spot_price count
    ##   <chr>                         <dbl>                 <dbl> <int>
    ## 1 AWS                         0.00909                 0.510  3384
    ## 2 Azure                       0.00388                 0.246  3844
    ## 3 GCP                         0.00772                 0.446  4708

![](README_files/figure-gfm/create_analysis-1.png)<!-- -->

    ## 
    ## GPU-based Aggregated Spot Price Metrics:
    ## # A tibble: 3 × 4
    ##   provider median_gpu_spot_norm_price median_gpu_spot_price count
    ##   <chr>                         <dbl>                 <dbl> <int>
    ## 1 AWS                          0.0996                 0.981   216
    ## 2 Azure                        0.0635                 0.636    96
    ## 3 GCP                          0.0998                 2.17    416

![](README_files/figure-gfm/create_analysis-2.png)<!-- -->![](README_files/figure-gfm/create_analysis-3.png)<!-- -->

    ## 
    ## create_analysis.R completed.

------------------------------------------------------------------------

## 2. Central Tendency Summaries

``` r
source("scripts/central_tendency.R")
```

    ## Running central_tendency.R...
    ## 
    ## CPU Normalized Price Summary:
    ## # A tibble: 3 × 3
    ##   provider mean_cpu_norm median_cpu_norm
    ##   <chr>            <dbl>           <dbl>
    ## 1 AWS            0.0103          0.00909
    ## 2 Azure          0.00508         0.00388
    ## 3 GCP            0.00722         0.00772
    ## 
    ## GPU Normalized Price Summary:
    ## # A tibble: 3 × 3
    ##   provider mean_gpu_norm median_gpu_norm
    ##   <chr>            <dbl>           <dbl>
    ## 1 AWS              0.147          0.121 
    ## 2 Azure            0.194          0.0857
    ## 3 GCP              0.293          0.186 
    ## central_tendency.R completed.

------------------------------------------------------------------------

## 3. Statistical Tests (Kruskal-Wallis & Dunn)

``` r
source("scripts/kruskal_dunn_normalized.R")
```

    ## Running kruskal_dunn_normalized.R...
    ## 
    ## --- Kruskal-Wallis Test for CPU Normalized Spot Price ---
    ## 
    ##  Kruskal-Wallis rank sum test
    ## 
    ## data:  cpu_spot_norm_price by provider
    ## Kruskal-Wallis chi-squared = 4733.3, df = 2, p-value < 2.2e-16
    ## 
    ## 
    ## Significant differences found for CPU normalized prices. Running Dunn's test...
    ##   Kruskal-Wallis rank sum test
    ## 
    ## data: x and group
    ## Kruskal-Wallis chi-squared = 4733.0482, df = 2, p-value = 0
    ## 
    ## 
    ##                            Comparison of x by group                            
    ##                                  (Bonferroni)                                  
    ## Col Mean-|
    ## Row Mean |        AWS      Azure
    ## ---------+----------------------
    ##    Azure |   66.84918
    ##          |    0.0000*
    ##          |
    ##      GCP |   22.82791  -47.32789
    ##          |    0.0000*    0.0000*
    ## 
    ## alpha = 0.05
    ## Reject Ho if p <= alpha/2
    ## $chi2
    ## [1] 4733.048
    ## 
    ## $Z
    ## [1]  66.84918  22.82792 -47.32789
    ## 
    ## $P
    ## [1]  0.000000e+00 1.211166e-115  0.000000e+00
    ## 
    ## $P.adjusted
    ## [1]  0.000000e+00 3.633497e-115  0.000000e+00
    ## 
    ## $comparisons
    ## [1] "AWS - Azure" "AWS - GCP"   "Azure - GCP"
    ## 
    ## 
    ## --- Kruskal-Wallis Test for GPU Normalized Spot Price ---
    ## 
    ##  Kruskal-Wallis rank sum test
    ## 
    ## data:  gpu_spot_norm_price by provider
    ## Kruskal-Wallis chi-squared = 54.144, df = 2, p-value = 1.749e-12
    ## 
    ## 
    ## Significant differences found for GPU normalized prices. Running Dunn's test...
    ##   Kruskal-Wallis rank sum test
    ## 
    ## data: x and group
    ## Kruskal-Wallis chi-squared = 54.1414, df = 2, p-value = 0
    ## 
    ## 
    ##                            Comparison of x by group                            
    ##                                  (Bonferroni)                                  
    ## Col Mean-|
    ## Row Mean |        AWS      Azure
    ## ---------+----------------------
    ##    Azure |   5.559008
    ##          |    0.0000*
    ##          |
    ##      GCP |  -1.398047  -7.321435
    ##          |     0.2431    0.0000*
    ## 
    ## alpha = 0.05
    ## Reject Ho if p <= alpha/2
    ## $chi2
    ## [1] 54.14141
    ## 
    ## $Z
    ## [1]  5.559009 -1.398047 -7.321436
    ## 
    ## $P
    ## [1] 1.356554e-08 8.104947e-02 1.226661e-13
    ## 
    ## $P.adjusted
    ## [1] 4.069662e-08 2.431484e-01 3.679983e-13
    ## 
    ## $comparisons
    ## [1] "AWS - Azure" "AWS - GCP"   "Azure - GCP"
    ## 
    ## kruskal_dunn_normalized.R completed.
