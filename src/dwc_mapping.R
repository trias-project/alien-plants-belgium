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
library(magrittr)  # For %<>% pipes (not part of core tidyverse)
library(readxl)    # For reading Excel (not part of core tidyverse)
library(janitor)   # For cleaning input data
library(knitr)     # For nicer (kable) tables
source("functions/term_mapping.R") # For mapping values

#' Set file paths (all paths should be relative to this script):
raw_data_file = "../data/raw/Checklist2.xls"
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
  path = raw_data_file,
  skip = 1 # First row is empty
) 

#' Clean data somewhat:
raw_data %<>%
  # Remove empty rows
  remove_empty_rows() %>%
  # Have sensible (lowercase) column names
  clean_names()

#' The first row contains subheaders for "presence": `Fl.`, `Br.`, `Wa.` so, we'll rename to actual headers to keep this information:
raw_data %<>%
  rename(presence_fl = presence, presence_br = x_1, presence_wa = x_2) %>%
  # That first row can now be removed, by slicing from 2 till the end
  slice(2:(n()))

#' Add row number as an identifier (`id`):
raw_data <- cbind("id" = seq.int(nrow(raw_data)), raw_data)

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
# Code to be added

#' #### acceptedNameUsageID
#' #### parentNameUsageID
#' #### originalNameUsageID
#' #### nameAccordingToID
#' #### namePublishedInID
#' #### taxonConceptID
#' #### scientificName
taxon %<>% mutate(scientificName = raw_taxon)

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

#' #### genus
#' #### subgenus
#' #### specificEpithet
#' #### infraspecificEpithet
#' #### taxonRank
# Code to be added

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

#' Create a `raw_presence_be` column, which contains `X` if any of the regions has `X` or else `?` if any of the regions has `?`:
distribution %<>% mutate(raw_presence_be =
  case_when(
    raw_presence_fl == "X" | raw_presence_br == "X" | raw_presence_wa == "X" ~ "X", # One is "X"
    raw_presence_fl == "?" | raw_presence_br == "?" | raw_presence_wa == "?" ~ "?" # One is "?"
  )
)

#' Transpose the data for the presence columns, but not for `NA` values:
distribution %<>%
  gather(
    raw_presence_region, raw_presence_value,
    raw_presence_be, raw_presence_br, raw_presence_fl, raw_presence_wa,
    na.rm = TRUE,
    convert = FALSE
  ) %>%
  arrange(raw_id)

#' Preview the newly created columns:
distribution %>% 
  select(raw_id, raw_presence_region, raw_presence_value) %>%
  head() %>%
  kable()

#' ### Term mapping
#' 
#' Map the source data to [Species Distribution](http://rs.gbif.org/extension/gbif/1.0/distribution.xml):

#' #### id
distribution %<>% mutate(id = raw_id)

#' #### locationID
#' 
#' Use lookup table to get region ISO codes:
locationid_lookup <- term_mapping(lookup_table, "locationID")
stack(locationid_lookup)

distribution %<>% mutate(locationID = 
  paste0("ISO3166-2:", recode(raw_presence_region, !!!locationid_lookup))
)

#' #### locality
#' 
#' Use lookup table to get region names:
locality_lookup <- term_mapping(lookup_table, "locality")
stack(locality_lookup)

distribution %<>% mutate(locality = 
  recode(raw_presence_region, !!!locality_lookup)
)

#' #### countryCode
distribution %<>% mutate(countryCode = "BE")

#' #### lifeStage
#' #### occurrenceStatus
#' 
#' Use lookup table to map to [IUCN definitions](http://www.iucnredlist.org/technical-documents/red-list-training/iucnspatialresources):
occurrencestatus_lookup <- term_mapping(lookup_table, "occurrenceStatus")
stack(occurrencestatus_lookup)

distribution %<>% mutate(occurrenceStatus = 
  recode(raw_presence_value, !!!occurrencestatus_lookup)
)

#' #### threatStatus
#' #### establishmentMeans
# To be added

#' #### appendixCITES
#' #### eventDate
# To be added

#' #### startDayOfYear
#' #### endDayOfYear
#' #### source
# Add?

#' #### occurrenceRemarks
# Add?

#' #### datasetID
#' 
#' ### Post-processing
#' 
#' Remove the original columns + the two new ones:
distribution %<>% select(-one_of(raw_colnames), -raw_presence_region, -raw_presence_value)

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
