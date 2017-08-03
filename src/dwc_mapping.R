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
# To be added

#' #### appendixCITES
#' #### eventDate
distribution %<>% mutate(first_year = raw_fr)
distribution %<>% mutate(last_year = raw_mrr)

distribution %<>% mutate(eventDate = 
  paste(first_year, last_year, sep = "/")
)

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
#' Remove the original columns:
distribution %<>% select(-one_of(raw_colnames), -presence_be, -first_year, -last_year)

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
