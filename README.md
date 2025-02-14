Cloud Instance Price Analysis Report
================
Mithran Mohanraj
2025-02-14

## Introduction

This report provides an analysis of cloud instance prices based on CPU
and GPU compute units. The data covers various cloud instance details
from multiple providers, allowing for a robust comparison of
cost-efficiency.

## Methodology

### Data Loading and Preprocessing

The analysis begins by reading a merged CSV file
(`pl_output/merged_data.csv`) and converting the `timestamp` column to a
standard date-time format. Numerical columns (such as `vcpus` and
`memory_gib`) are explicitly cast to numeric types to ensure correct
computations.

### CPU Compute Unit Analysis

For CPU analysis, a compute score is defined as:

$$
\text{cpu\_compute\_score} = \text{vcpus} + \frac{\text{memory\_gib}}{4}
$$

The hourly price is then normalized by dividing by this compute score:

$$
\text{cpu\_norm\_price} = \frac{\text{price\_per\_hour}}{\text{cpu\_compute\_score}}
$$

Median values for the normalized CPU price are computed for each
provider to allow a robust comparison across different offerings.

### GPU Compute Unit Analysis

For GPU analysis, instances with an unknown GPU model are filtered out.
A lookup table assigns a score to each GPU model based on experimental
benchmarks. The total GPU compute score is calculated as:

$$
\text{total\_gpu\_compute} = \text{gpu\_score} \times \text{gpu\_count}
$$

The normalized GPU price is obtained by:

$$
\text{gpu\_norm\_price} = \frac{\text{price\_per\_hour}}{\text{total\_gpu\_compute}}
$$

Median values are then computed per provider to mitigate the impact of
outliers.

## Results

### CPU Analysis

The bar plot below shows the median normalized CPU price per compute
unit for each provider.

<figure>
<img src="r_output/cpu_norm_price_by_provider.png"
alt="CPU Normalized Price" />
<figcaption aria-hidden="true">CPU Normalized Price</figcaption>
</figure>

### GPU Analysis

The bar plot below shows the median normalized GPU price per compute
unit for each provider.

<figure>
<img src="r_output/gpu_norm_price_by_provider.png"
alt="GPU Normalized Price" />
<figcaption aria-hidden="true">GPU Normalized Price</figcaption>
</figure>

## Conclusion

This analysis provides insights into the relative cost-efficiency of
cloud instances. The differences in CPU and GPU compute unit pricing
across providers can help inform decisions regarding cloud resource
procurement.
