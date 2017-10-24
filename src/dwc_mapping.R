#' # Darwin Core mapping
#' 
#' Peter Desmet, Quentin Groom, Lien Reyserhove
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

#' Set file paths (all paths should be relative to this script):
raw_data_file = "../data/raw/Checklist2.xlsx"
dwc_taxon_file = "../data/processed/taxon.csv"
dwc_distribution_file = "../data/processed/distribution.csv"
dwc_description_file = "../data/processed/description.csv"

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
taxon %<>% mutate(scientificNameID = raw_scientificnameid)

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
write.csv(taxon, file = dwc_taxon_file, na = "", row.names = FALSE, fileEncoding = "UTF-8")

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
#' Map values using [IUCN definitions](http://www.iucnredlist.org/technical-documents/red-list-training/iucnspatialresources):
distribution %<>% mutate(occurrenceStatus = recode(presence_be,
  "X" = "present",
  "?" = "presence uncertain",
  .default = "",
  .missing = "absent"
))

#' #### threatStatus
#' #### establishmentMeans
#'
#' `establishmentMeans` is based on `raw_v_i`, which contains a list of introductions pathways (e.g. `Agric., wool`). We'll separate, clean, map and combine these values.
#' 
#' Create `pathway` from `raw_v_i`:
distribution %<>% mutate(pathway = raw_v_i)

#' Separate `pathway` on `,` in 4 columns:
# In case there are more than 4 values, these will be merged in pathway_4. 
# The dataset currently contains no more than 3 values per record.
distribution %<>% separate(
  pathway,
  into = c("pathway_1", "pathway_2", "pathway_3", "pathway_4"),
  sep = ",",
  remove = TRUE,
  convert = FALSE,
  extra = "merge",
  fill = "right"
)

#' Gather pathways in a key and value column:
distribution %<>% gather(
  key, value,
  pathway_1, pathway_2, pathway_3, pathway_4,
  na.rm = TRUE, # Also removes records for which there is no pathway_1
  convert = FALSE
)

#' Sort on `id` to see pathways in context for each record:
distribution %<>% arrange(id)

#' Show unique values:
distribution %>%
  distinct(value) %>%
  arrange(value) %>%
  kable()

#' Clean values:
distribution %<>% mutate(
  value = str_replace_all(value, "\\?|…|\\.{3}", ""), # Strip ?, …, ...
  value = str_to_lower(value), # Convert to lowercase
  value = str_trim(value) # Clean whitespace
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
  .default = "",
  .missing = "" # As result of stripping, records with no pathway already removed by gather()
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

#' Convert empty values to `NA` (important to be able to remove them after paste):
distribution %<>% mutate(mapped_value = na_if(mapped_value, ""))

#'Since our pathway controlled vocabulary is not allowed by GBIF in `establishmentMeans` (see <https://github.com/trias-project/alien-plants-belgium/issues/35>), we'll also add it to the Description extension. Rather than cleaning it all over again there, we save it here:

pathway <- distribution %>% select(
    one_of(raw_colnames), # Add raw columns
    mapped_value)

#' Spread values back to columns:
distribution %<>% spread(key, mapped_value)

#' Create `establishmentMeans` columns where these values are concatentated with ` | `:
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

#' Clean values:
distribution %<>% mutate(start_year = 
  str_replace_all(start_year, "(\\?|ca. |<|>)", "") # Strip ?, ca., < and >
)

#' Create `end_year` from `raw_mrr` (most recent record):
distribution %<>% mutate(end_year = raw_mrr)

#' Clean values:
distribution %<>% mutate(end_year = 
  str_replace_all(end_year, "(\\?|ca. |<|>)", "") # Strip ?, ca., < and >
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

#' ### Post-processing
#' 
#' Remove the original columns:
distribution %<>% select(
  -one_of(raw_colnames),
  -presence_be,
  -pathway_1, -pathway_2, -pathway_3, -pathway_4,
  -start_year, -end_year
)

#' Sort on `id`:
distribution %<>% arrange(id)

#' Preview data:
kable(head(distribution))

#' Save to CSV:
write.csv(distribution, file = dwc_distribution_file, na = "", row.names = FALSE, fileEncoding = "UTF-8")

#' ## Create description extension
#' 
#' In the description extension we want to include **origin** (`raw_d_n`) and **native range** (`raw_origin`) information. We'll create a separate data frame for both and then combine these with union.
#' 
#' ### Pre-processing
#' 
#' #### Origin
#' 
#' `origin` describes if a species is native in a distribution or not. Since Darwin Core has no `origin` field yet as suggested in [ias-dwc-proposal](https://github.com/qgroom/ias-dwc-proposal/blob/master/proposal.md#origin-new-term), we'll add this information in the description extension.
#' 
#' Create new data frame:
origin <- raw_data

#' Create `description` from `raw_d_n`:
origin %<>% mutate(description = raw_d_n)

#' Create a `type` field to indicate the type of description:
origin %<>% mutate(type = "origin")

#' Clean values:
origin %<>% mutate(description = 
  str_replace_all(description, "\\?", ""), # Strip ?
  description = str_trim(description) # Clean whitespace
)

#' Map values using [this vocabulary](https://github.com/qgroom/ias-dwc-proposal/blob/master/vocabulary/origin.tsv):
origin %<>% mutate(description = recode(description,
  "Cas." = "vagrant",
  "Nat." = "introduced",
  "Ext." = "",
  "Inv." = "",
  "Ext./Cas." = "",
  .default = "",
  .missing = ""
))

#' Show mapped values:
origin %>%
  select(raw_d_n, description) %>%
  group_by(raw_d_n, description) %>%
  summarize(records = n()) %>%
  arrange(raw_d_n) %>%
  kable()

#' Keep only non-empty descriptions:
origin %<>% filter(!is.na(description) & description != "")

#' Preview data:
kable(head(origin))

#' #### Native range
#' 
#' `raw_origin` contains native range information (e.g. `E AS-Te NAM`). We'll separate, clean, map and combine these values.
#' 
#' Create new data frame:
native_range <- raw_data

#' Create `description` from `raw_d_n`:
native_range %<>% mutate(description = raw_origin)

#' Separate `description` on space in 4 columns:
# In case there are more than 4 values, these will be merged in native_range_4. 
# The dataset currently contains no more than 4 values per record.
native_range %<>% separate(
  description,
  into = c("native_range_1", "native_range_2", "native_range_3", "native_range_4"),
  sep = " ",
  remove = TRUE,
  convert = FALSE,
  extra = "merge",
  fill = "right"
)

#' Gather native ranges in a key and value column:
native_range %<>% gather(
  key, value,
  native_range_1, native_range_2, native_range_3, native_range_4,
  na.rm = TRUE, # Also removes records for which there is no native_range_1
  convert = FALSE
)

#' Sort on ID to see pathways in context for each record:
native_range %<>% arrange(raw_id)

#' Clean values:
native_range %<>% mutate(
  value = str_replace_all(value, "\\?", ""), # Strip ?
  value = str_trim(value) # Clean whitespace
)

#' Map values:
native_range %<>% mutate(mapped_value = recode(value,
  "AF" = "Africa",
  "AM" = "pan-American",
  "AS" = "Asia",
  "AS-Te" = "temperate Asia",
  "AS-Tr" = "tropical Asia",
  "AUS" = "Australasia",
  "Cult." = "cultivated origin",
  "E" = "Europe",
  "Hybr." = "hybrid origin",
  "NAM" = "Northern America",
  "SAM" = "Southern America",
  "Trop." = "Pantropical",
  .default = "",
  .missing = "" # As result of stripping, records with no native range already removed by gather()
))

#' Show mapped values:
native_range %>%
  select(value, mapped_value) %>%
  group_by(value, mapped_value) %>%
  summarize(records = n()) %>%
  arrange(value) %>%
  kable()

#' Drop `key` and `value` column and rename `mapped value`:
native_range %<>% select(-key, -value)
native_range %<>% rename(description = mapped_value)

#' Keep only non-empty descriptions:
native_range %<>% filter(!is.na(description) & description != "")

#' Create a `type` field to indicate the type of description:
native_range %<>% mutate(type = "native range")

#' Preview data:
kable(head(native_range))

#' #### Pathway (pathway of introduction) 
#' 
#' Pathway information was already generated for `establishmentMeans` in the Distribution extension and saved in a dataframe `pathway`. It contains one record per pathway (with potentially more than one pathway per taxon).

#' Change column name `mapped_value` to `description`:
pathway %<>%  rename(description = mapped_value)

#' Create a `type` field to indicate the type of description:
pathway %<>% mutate (type = "pathway")

#' Show pathway descriptions:
pathway %>% 
  select(description) %>% 
  group_by(description) %>% 
  summarize(records = n()) %>% 
  kable()

#' Keep only non-empty descriptions:
pathway %<>% filter(!is.na(description) & description != "")

#' #### Union origin, native range and pathway:
description_ext <- bind_rows(origin, native_range, pathway)

#' ### Term mapping
#' 
#' Map the source data to [Taxon Description](http://rs.gbif.org/extension/gbif/1.0/description.xml):
#' 
#' #### id
description_ext %<>% mutate(id = raw_id)

#' #### description
description_ext %<>% mutate(description = description)

#' #### type
description_ext %<>% mutate(type = type)

#' #### source
#' #### language
description_ext %<>% mutate(language = "en")

#' #### created
#' #### creator
#' #### contributor
#' #### audience
#' #### license
#' #### rightsHolder
#' #### datasetID

#' ### Post-processing
#' 
#' Remove the original columns:
description_ext %<>% select(
  -one_of(raw_colnames)
)

#' Move `id` to the first position:
description_ext %<>% select(id, everything())

#' Sort on `id`:
description_ext %<>% arrange(id)

#' Preview data:
kable(head(description_ext, 10))

#' Save to CSV:
write.csv(description_ext, file = dwc_description_file, na = "", row.names = FALSE, fileEncoding = "UTF-8")

#' ## Summary
#' 
#' ### Number of records
#' 
#' * Source file: `r nrow(raw_data)`
#' * Taxon core: `r nrow(taxon)`
#' * Distribution extension: `r nrow(distribution)`
#' * Description extension: `r nrow(description_ext)`
#'
#' ### Taxon core
#' 
#' Number of duplicates: `r anyDuplicated(taxon[["id"]])` (should be 0)
#' 
#' The following numbers are expected to be the same:
#' 
#' * Number of records: `r nrow(taxon)`
#' * Number of distinct `taxonID`: `r n_distinct(taxon[["taxonID"]], na.rm = TRUE)`
#' * Number of distinct `scientificName`: `r n_distinct(taxon[["scientificName"]], na.rm = TRUE)`
#' * Number of distinct `scientificNameID`: `r n_distinct(taxon[["scientificNameID"]], na.rm = TRUE)` (can contain NAs)
#' * Number of distinct `scientificNameID` and `NA`: `r n_distinct(taxon[["scientificNameID"]], na.rm = TRUE) + sum(is.na(taxon[["scientificNameID"]]))`
#'
#' Number of unique families: `r n_distinct(taxon[["family"]])`
