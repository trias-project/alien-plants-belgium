#' # Darwin Core mapping
#' 
#' Peter Desmet & Quentin Groom
#' 
#' `r Sys.Date()`
#'
#' This document describes how we map the checklist data to Darwin Core.
#' 
#' ## Setup
#' 
#+ configure_knitr, include = FALSE
knitr::opts_chunk$set(echo = TRUE, warning = FALSE, message = FALSE)

#' Set locale (so we use UTF-8 character encoding):
# This works on Mac OS X, might not work on other OS
Sys.setlocale("LC_ALL", 'en_US.UTF-8')

#' Load libraries:
library(tidyverse) # For data transformations

# None core tidyverse packages:
library(magrittr)  # For %<>% pipes
library(readxl)    # For reading Excel
library(stringr)   # For string manipulation

# Other packages
library(janitor)   # For cleaning input data
library(knitr)     # For nicer (kable) tables
source("functions/term_mapping.R") # For mapping values

#' Set file paths (all paths should be relative to this script):
raw_data_file = "../data/raw/Checklist2.xlsx"
lookup_file = "../settings/lookup.csv"
dwc_taxon_file = "../data/processed/taxon.csv"
dwc_distribution_file = "../data/processed/distribution.csv"
dwc_description_file = "../data/processed/description.csv"

#' Load lookup table (contains information to map values):
lookup_table <- read.csv(lookup_file)

#' ## Read data
#' 
#' Read the source data:
raw_data <- read_excel(
  path = raw_data_file
) 

#' Clean data somewhat:
raw_data %<>%
  # Remove empty rows
  remove_empty_rows() %>%
  # Have sensible (lowercase) column names
  clean_names()

#' Add prefix `raw_` to all column names to avoid name clashes with Darwin Core terms:
colnames(raw_data) <- paste0("raw_", colnames(raw_data))

#' Save those column names as a list (makes it easier to remove them all later):
raw_colnames <- colnames(raw_data)

#' Preview data:
kable(head(raw_data))

#' ## Create taxon core
taxon <- raw_data

#' ### Term mapping
#' 
#' Map the source data to [Darwin Core Taxon](http://rs.gbif.org/core/dwc_taxon_2015-04-24.xml):
#' 
#' #### id
taxon %<>% mutate(id = raw_id)

#' Number of duplicates: (should be 0):
anyDuplicated(taxon[["id"]])

#' #### modified
#' #### language
taxon %<>% mutate(language = "en")

#' #### license
taxon %<>% mutate(license = "http://creativecommons.org/publicdomain/zero/1.0/")

#' #### rightsHolder
taxon %<>% mutate(rightsHolder = "Botanic Garden Meise")

#' #### accessRights
#' #### bibliographicCitation
#' #### informationWithheld
#' #### datasetID
taxon %<>% mutate(datasetID = "") # Should become dataset DOI

#' #### datasetName
taxon %<>% mutate(datasetName = "Manual of the Alien Plants of Belgium")

#' #### references
#' #### taxonID
taxon %<>% mutate(taxonID = raw_id)

#' #### scientificNameID
taxon %<>% mutate(scientificNameID = raw_scientificnameid)

#' #### acceptedNameUsageID
#' #### parentNameUsageID
#' #### originalNameUsageID
#' #### nameAccordingToID
#' #### namePublishedInID
#' #### taxonConceptID
#' #### scientificName
taxon %<>% mutate(scientificName = raw_taxon)

#' Number of unique scientific names:
length(unique(taxon[["scientificName"]]))

#' #### acceptedNameUsage
#' #### parentNameUsage
#' #### originalNameUsage
#' #### nameAccordingTo
#' #### namePublishedIn
#' #### namePublishedInYear
#' #### higherClassification
#' #### kingdom
taxon %<>% mutate(kingdom = "Plantae")

#' #### phylum
#' #### class
#' #### order
#' #### family
taxon %<>% mutate(family = raw_family)

#' Number of unique families:
length(unique(taxon[["family"]]))

#' #### genus
#' #### subgenus
#' #### specificEpithet
#' #### infraspecificEpithet
#' #### taxonRank
taxon %<>% mutate(taxonRank = raw_taxonrank)

#' Show unique values:
taxon %>%
  distinct(taxonRank) %>%
  arrange(taxonRank) %>%
  kable()

#' #### verbatimTaxonRank
#' #### scientificNameAuthorship
#' #### vernacularName
#' #### nomenclaturalCode
taxon %<>% mutate(nomenclaturalCode = "ICBN")

#' #### taxonomicStatus
#' #### nomenclaturalStatus
#' #### taxonRemarks
#'
#' ### Post-processing
#' 
#' Remove the original columns:
taxon %<>% select(-one_of(raw_colnames))

#' Preview data:
kable(head(taxon))

#' Save to CSV:
write.csv(taxon, file = dwc_taxon_file, na = "", row.names = FALSE)

#' ## Create distribution extension
#' 
#' ### Pre-processing
distribution <- raw_data

#' The checklist contains minimal presence information (`X` or `?`) for the three regions in Belgium (Flanders, Wallonia and the Brussels-Capital Region). Information regarding pathway, status, first and last recorded observation however apply to the distribution in Belgium as a whole. Since it is impossible to extrapolate that information for the regions, we decided to only provide distribution information for Belgium.

#' Create a `presence_be` column, which contains `X` if any of the regions has `X` or else `?` if any of the regions has `?`:
distribution %<>% mutate(presence_be =
  case_when(
    raw_presence_fl == "X" | raw_presence_br == "X" | raw_presence_wa == "X" ~ "X", # One is "X"
    raw_presence_fl == "?" | raw_presence_br == "?" | raw_presence_wa == "?" ~ "?" # One is "?"
  )
)

#' ### Term mapping
#' 
#' Map the source data to [Species Distribution](http://rs.gbif.org/extension/gbif/1.0/distribution.xml):

#' #### id
distribution %<>% mutate(id = raw_id)

#' #### locationID
distribution %<>% mutate(locationID = "ISO3166-2:BE")

#' #### locality
distribution %<>% mutate(locality = "Belgium")

#' #### countryCode
distribution %<>% mutate(countryCode = "BE")

#' #### lifeStage
#' #### occurrenceStatus
#' 
#' Use lookup table to map to [IUCN definitions](http://www.iucnredlist.org/technical-documents/red-list-training/iucnspatialresources):
occurrencestatus_lookup <- term_mapping(lookup_table, "occurrenceStatus")
stack(occurrencestatus_lookup)

distribution %<>% mutate(occurrenceStatus = 
  recode(presence_be, !!!occurrencestatus_lookup)
)

#' #### threatStatus
#' #### establishmentMeans
#'
#' `establishmentMeans` is based on `raw_v_i`, which contains a list of introductions pathways (e.g. `Agric., wool`). We'll separate, clean, map and combine these values.
#' 
#' Create `pathway` from `raw_v_i`:
distribution %<>% mutate(pathway = raw_v_i)

#' Interpret `?` as empty (note that some raw values are already):
distribution %<>% mutate(pathway = recode(pathway, "?" = ""))

#' Separate pathway on `,` in 4 columns:
# In case there are more than 4 values, these will be merged in pathway_4. 
# The dataset currently contains no more than 3 values per record, so pathway_4
# will be empty.
distribution %<>% separate(
  pathway,
  into = c("pathway_1", "pathway_2", "pathway_3", "pathway_4"),
  sep = ",",
  remove = TRUE,
  convert = FALSE,
  extra = "merge"
)

#' Gather pathways in a key and value column:
distribution %<>% gather(
  key, value,
  pathway_1, pathway_2, pathway_3, pathway_4,
  na.rm = TRUE,
  convert = FALSE
)

#' Sort on ID to see pathways in context for each record:
distribution %<>% arrange(id)

#' Show unique values:
distribution %>%
  distinct(value) %>%
  arrange(value) %>%
  kable()

#' Strip `?`, `...` from values, convert to lowercase, and clean whitespace:
distribution %<>% mutate(
  value = str_replace_all(value, "\\?|…|\\.{3}", ""),
  value = str_to_lower(value),
  value = str_trim(value)
)

#' Map values:
distribution %<>% mutate(mapped_value = recode(value, 
  "agric." = "escape:agriculture",
  "bird seed" = "contaminant:seed",
  "birdseed" = "contaminant:seed",
  "bulbs" = "",
  "coconut mats" = "contaminant:seed",
  "fish" = "",
  "food refuse" = "escape:food_bait",
  "grain" = "contaminant:seed",
  "grain (rice)" = "contaminant:seed",
  "grass seed" = "contaminant:seed",
  "hay" = "",
  "hort" = "escape:horticulture",
  "hort." = "escape:horticulture",
  "hybridization" = "",
  "military troops" = "",
  "nurseries" = "contaminant:nursery",
  "ore" = "contaminant:habitat_material",
  "pines" = "contaminant:on_plants",
  "rice" = "",
  "salt" = "",
  "seeds" = "contaminant:seed",
  "timber" = "contaminant:timber",
  "tourists" = "stowaway:people_luggage",
  "traffic" = "",
  "unknown" = "unknown",
  "urban weed" = "stowaway",
  "waterfowl" = "contaminant:on_animals",
  "wool" = "contaminant:on_animals",
  "wool alien" = "contaminant:on_animals",
  .default = ""
))

#' Show mapped values:
distribution %>%
  select(value, mapped_value) %>%
  group_by(value, mapped_value) %>%
  summarize(records = n()) %>%
  arrange(value) %>%
  kable()

#' Drop `value` column:
distribution %<>% select(-value)

#' Convert empty values as `NA`:
distribution %<>% mutate(mapped_value = na_if(mapped_value, ""))

#' Spread values back to columns:
distribution %<>% spread(key, mapped_value)

#' Create `establishmentMeans` columns where these values are concatentated with ` | ` (omit `NA` values):
distribution %<>% mutate(establishmentMeans = 
  paste(pathway_1, pathway_2, pathway_3, pathway_4, sep = " | ")              
)

#' Annoyingly the `paste()` function does not provide an `rm.na` parameter, so `NA` values will be included as ` | NA`. We can strip those out like this:
distribution %<>% mutate(
  establishmentMeans = str_replace_all(establishmentMeans, " \\| NA", ""), # Remove ' | NA'
  establishmentMeans = recode(establishmentMeans, "NA" = "") # Remove NA at start of string
)

#' #### appendixCITES
#' #### eventDate
#' 
#' Create `start_year` from `raw_fr` (first record):
distribution %<>% mutate(start_year = raw_fr)

#' Strip `?`, `ca.`, `>` and `<` from the values:
distribution %<>% mutate(start_year = 
  str_replace_all(start_year, "(\\?|ca. |<|>)", "")
)

#' Create `end_year` from `raw_mrr` (most recent record):
distribution %<>% mutate(end_year = raw_mrr)

#' Strip `?`, `ca.`, `>` and `<` from the values:
distribution %<>% mutate(end_year = 
  str_replace_all(end_year, "(\\?|ca. |<|>)", "")
)

#' If `end_year` is `Ann.` or `N` use current year:
current_year = format(Sys.Date(), "%Y")
distribution %<>% mutate(end_year = recode(end_year,
  "Ann." = current_year,
  "N" = current_year)
)

#' Show reformatted values for both `raw_fr` and `raw_mrr`:
distribution %>%
  select(raw_fr, start_year) %>%
  rename(raw_year = raw_fr, formatted_year = start_year) %>%
  union( # Union with raw_mrr. Will also remove duplicates
    distribution %>%
      select(raw_mrr, end_year) %>%
      rename(raw_year = raw_mrr, formatted_year = end_year)
  ) %>%
  filter(nchar(raw_year) != 4) %>% # Don't show raw values that were already YYYY
  arrange(raw_year) %>%
  kable()

#'Check if any `start_year` fall after `end_year` (expected to be none):
distribution %>%
  select(start_year, end_year) %>%
  mutate(start_year = as.numeric(start_year)) %>%
  mutate(end_year = as.numeric(end_year)) %>%
  group_by(start_year, end_year) %>%
  summarize(records = n()) %>%
  filter(start_year > end_year) %>%
  kable()

#' Combine `start_year` and `end_year` in an ranged `eventDate` (ISO 8601 format). If any those two dates is empty or the same, we use a single year, as a statement when it was seen once (either as a first record or a most recent record):
distribution %<>% mutate(eventDate = 
  case_when(
    start_year == "" & end_year == "" ~ "",
    start_year == ""                  ~ end_year,
    end_year == ""                    ~ start_year,
    start_year == end_year            ~ start_year,
    TRUE                              ~ paste(start_year, end_year, sep = "/")
  )
)

#' #### startDayOfYear
#' #### endDayOfYear
#' #### source
#' #### occurrenceRemarks
#' #### datasetID
#' 
#' ### Post-processing
#' 
#' Remove the original columns:
distribution %<>% select(
  -one_of(raw_colnames),
  -presence_be,
  -pathway_1, -pathway_2, -pathway_3, -pathway_4,
  -start_year, -end_year
)

#' Preview data:
kable(head(distribution))

#' Save to CSV:
write.csv(distribution, file = dwc_distribution_file, na = "", row.names = FALSE)

#' ## Create description extension
#' 
#' ### Pre-processing
description <- raw_data

#' Transpose the data for the description columns, including for NA values:
description %<>%
  gather(
    raw_description_type, raw_description_value,
    raw_origin, raw_d_n, raw_v_i,
    na.rm = FALSE,
    convert = FALSE
  ) %>%
  arrange(raw_id)

#' Preview the newly created columns:
description %>% 
  select(raw_id, raw_description_type, raw_description_value) %>%
  head() %>%
  kable()
