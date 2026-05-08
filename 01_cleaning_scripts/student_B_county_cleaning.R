# =============================================================================
# Student B: County Proprietary Data Cleaning
# =============================================================================
# Input:  00_raw_data/county_proprietary_valid_2000_2018.csv
# Output: 02_clean_data/ca_prop_clean.RData
#
# Your job: clean the proprietary county dataset, which has pre-computed
# filing rates, threatened rates, and judgement rates.
# You will merge your output with Student A's in 03_analysis_scripts.
# =============================================================================

rm(list = ls())

library(pacman)

p_load(tidyverse, tidylog, janitor)

# -----------------------------------------------------------------------------
# 1. Load the raw proprietary data
# -----------------------------------------------------------------------------

prop_raw <- read_csv("00_raw_data/county_proprietary_valid_2000_2018.csv")

glimpse(prop_raw)


# -----------------------------------------------------------------------------
# 2. Filter to California only
# -----------------------------------------------------------------------------
#Step 2 — Filter to California, keep only observed rows:
  
  ca_prop <- prop_raw %>%
  filter(state == "California") %>%
  filter(type == "observed")

nrow(ca_prop)           # 123 rows
n_distinct(ca_prop$county)  # 16 counties
# -----------------------------------------------------------------------------
# 3. Keep only observed rows
# -----------------------------------------------------------------------------

# The "type" column is either "observed" (actual court records)
# or "imputed" (modeled estimates). We keep only observed.

#Step 3 — Clean names and FIPS:
  
  ca_prop <- ca_prop %>%
  mutate(
    county = str_remove(county, " County"),
    geoid  = str_pad(as.character(cofips), width = 5, pad = "0")
  )
# -----------------------------------------------------------------------------
# 4. Clean county names
# -----------------------------------------------------------------------------

#Step 4 — Select and rename columns:
  
  # Rename filing_rate → filing_rate_prop to avoid clash when merging with Student A
  ca_prop_clean <- ca_prop %>%
  select(
    geoid,
    county,
    year,
    filing_rate_prop = filing_rate,
    threatened_rate,
    judgement_rate
  )

glimpse(ca_prop_clean)

# -----------------------------------------------------------------------------
# 5. Fix the FIPS code
# -----------------------------------------------------------------------------

# cofips contains values like 6001, 6037 — same issue as Student A.
# We need a 5-character string with leading zero: "06001"

ca_prop <- ca_prop %>%
  mutate(geoid = str_pad(as.character(cofips), width = 5, pad = "0"))

unique(ca_prop$geoid) %>% head(10)


# -----------------------------------------------------------------------------
# 6. Select and rename relevant columns
# -----------------------------------------------------------------------------

# Rename filing_rate to filing_rate_prop so it doesn't clash with
# Student A's computed filing_rate when we merge later.

ca_prop_clean <- ca_prop %>%
  select(
    geoid,
    county,
    year,
    filing_rate_prop = filing_rate,
    threatened_rate,
    judgement_rate
  ) %>%
  arrange(county, year)

glimpse(ca_prop_clean)


# -----------------------------------------------------------------------------
# 7. Save to 02_clean_data
# -----------------------------------------------------------------------------

save(ca_prop_clean, file = "02_clean_data/ca_prop_clean.RData")

message("Done! Saved ca_prop_clean.RData with ", nrow(ca_prop_clean), " rows.")
