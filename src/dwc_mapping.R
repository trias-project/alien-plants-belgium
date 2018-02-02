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
Sys.setlocale("LC_CTYPE", "en_US.UTF-8")

#' Load libraries:
library(tidyverse) # For data transformations

# None core tidyverse packages:
library(magrittr)  # For %<>% pipes
library(readxl)    # For reading Excel
library(stringr)   # For string manipulation

# Other packages
library(janitor)   # For cleaning input data
library(knitr)     # For nicer (kable) tables
library(digest)    # To generate hashes

#' Set file paths (all paths should be relative to this script):
raw_data_file = "../data/raw/Checklist2.xlsx"
dwc_taxon_file = "../data/processed/taxon.csv"
dwc_distribution_file = "../data/processed/distribution.csv"
dwc_description_file = "../data/processed/description.csv"

#' ## Read data
#' 
#' Read the source data:
raw_data <- read_excel(path = raw_data_file) 

#' Clean data somewhat:
raw_data %<>%
  # Remove empty rows
  remove_empty_rows() %>%
  # Have sensible (lowercase) column names
  clean_names()

#' We need to integrate the DwC term `taxonID` in each of the generated files (Taxon Core and Extensions).
#' For this reason, it is easier to generate `taxonID` in the raw file. 
#' First, we vectorize the digest function (The digest() function isn't vectorized. 
#' So if you pass in a vector, you get one value for the whole vector rather than a digest for each element of the vector):
vdigest <- Vectorize(digest)

#' Generate `taxonID`:
raw_data %<>% mutate(taxonID = paste("alien-plants-belgium", "taxon", vdigest (taxon, algo="md5"), sep=":"))


#' Add prefix `raw_` to all column names to avoid name clashes with Darwin Core terms:
colnames(raw_data) <- paste0("raw_", colnames(raw_data))

#' Save those column names as a list (makes it easier to remove them all later):
raw_colnames <- colnames(raw_data)

#' Preview data:
kable(head(raw_data))

#' ## Create taxon core
#' 
#' ### Pre-processing
taxon <- raw_data

#' ### Term mapping
#' 
#' Map the source data to [Darwin Core Taxon](http://rs.gbif.org/core/dwc_taxon_2015-04-24.xml):
#' 
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
taxon %<>% mutate(datasetID = "https://doi.org/10.15468/wtda1m")

#' #### datasetName
taxon %<>% mutate(datasetName = "Manual of the Alien Plants of Belgium")

#' #### references
#' #### taxonID
taxon %<>% mutate(taxonID = raw_taxonID)

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

#' The checklist contains minimal presence information (`X`,`?` or `NA`) for the three regions in Belgium (Flanders, Wallonia and the Brussels-Capital Region).
#' Both national and regional information is required in the checklist. In the `distribution.csv`, we first provide the information on a national level for pathway, status and dates; followed by specific information for the regions. 
#' However, information regarding pathway, status, first and last recorded observation applies to the distribution in Belgium as a whole.
#' It is impossible to extrapolate this information for the regions, unless the species is present in only one region.
#' In this case, we can assume pathway, status and date relate to that region and so we can keep lines for Belgium and for the specific region populated for all DwC terms (see #45)
#' When a species is present in more than one region, we decided to only provide occurrenceStatus for the regional information, and specify all other information regarding pathway and dates only for Belgium

#' Thus, we need to specify when a species is present in only one of the regions.
#' We generate 4 new columns: `Flanders`, `Brussels`,`Wallonia` and `Belgium`. 
#' The content of these columns refers to the specific occurrence of a species on a regional or national level.
#' `S` if present in a single region or in Belgium, `?` if presence uncertain, `NA` if absent and `M` if present in multiple regions.
#' This should look like this:
kable(matrix(
  c(
    "X", NA, NA, "S", NA, NA, "S",
    NA, "X", NA, NA, "S", NA, "S", 
    NA, NA, "x", NA, NA, "S", "S",
    "X", "X", NA, "M", "M", NA, "S",
    "X", NA, "X", "M", NA, "M", "S",
    NA, "X", "X", NA, "M", "M", "S",
    NA, NA, NA, NA, NA, NA, NA,
    "X", "?", NA, "S", "?", NA, "S",
    "X", NA, "?", "S", NA, "?", "S",
    "X", "X", "?", "M", "M", "?", "S"
  ),
  ncol = 7,
  byrow = TRUE,
  dimnames = list(c(1:10), c(
    "raw_presence_fl",
    "raw_presence_br", 
    "raw_presence_wa", 
    "Flanders", 
    "Brussels", 
    "Wallonia",
    "Belgium"
  ))
))

#' We translate this to the distribution extension:
distribution %<>% 
  mutate(Flanders = case_when(
    raw_presence_fl == "X" & (is.na(raw_presence_br) | raw_presence_br == "?") & (is.na(raw_presence_wa) | raw_presence_wa == "?") ~ "S",
    raw_presence_fl == "?" ~ "?",
    is.na(raw_presence_fl) ~ "NA",
    TRUE ~ "M")) %>%
  mutate(Brussels = case_when(
    (is.na(raw_presence_fl) | raw_presence_fl == "?") & raw_presence_br == "X" & (is.na(raw_presence_wa) | raw_presence_wa == "?") ~ "S",
    raw_presence_br == "?" ~ "?",
    is.na(raw_presence_br) ~ "NA",
    TRUE ~ "M")) %>%
  mutate(Wallonia = case_when(
    (is.na(raw_presence_fl) | raw_presence_fl == "?") & (is.na(raw_presence_br) | raw_presence_br == "?") & raw_presence_wa == "X" ~ "S",
    raw_presence_wa == "?" ~ "?",
    is.na(raw_presence_wa) ~ "NA",
    TRUE ~ "M")) %>%
  mutate(Belgium = case_when(
    raw_presence_fl == "X" | raw_presence_br == "X" | raw_presence_wa == "X" ~ "S", # One is "X"
    raw_presence_fl == "?" | raw_presence_br == "?" | raw_presence_wa == "?" ~ "?" # One is "?"
  ))


#' Remove species for which we lack presence information (i.e. `Belgium` = `NA``)
distribution %<>% filter (!is.na(Belgium))

#' Summary of the previous action:
distribution %>% select (raw_presence_fl, raw_presence_br, raw_presence_wa, Flanders, Wallonia, Brussels, Belgium) %>%
  group_by_all() %>%
  summarize(records = n()) %>%
  arrange(Flanders, Wallonia, Brussels) %>%
  kable()

#' From wide to long table (i.e. create a `key` and `value` column)
distribution %<>% gather(
  key, value,
  Flanders, Wallonia, Brussels, Belgium,
  convert = FALSE
) 

#' Rename `key` and `value`
distribution %<>% rename ("location" = "key", "presence" = "value")


#' ### Term mapping
#' 
#' Map the source data to [Species Distribution](http://rs.gbif.org/extension/gbif/1.0/distribution.xml):

#' #### taxonID
distribution %<>% mutate(taxonID = raw_taxonID)

#' #### locationID
distribution %<>% mutate(locationID = case_when (
  location == "Belgium" ~ "ISO_3166-2:BE",
  location == "Flanders" ~ "ISO_3166-2:BE-VLG",
  location == "Wallonia" ~ "ISO_3166-2:BE-WAL",
  location == "Brussels" ~ "ISO_3166-2:BE-BRU"))

#' #### locality
distribution %<>% mutate(locality = case_when (
  location == "Belgium" ~ "Belgium",
  location == "Flanders" ~ "Flemish Region",
  location == "Wallonia" ~ "Walloon Region",
  location == "Brussels" ~ "Brussels-Capital Region"))

#' #### countryCode
distribution %<>% mutate(countryCode = "BE")

#' #### lifeStage
#' #### occurrenceStatus
#' 
#' Map values using [IUCN definitions](http://www.iucnredlist.org/technical-documents/red-list-training/iucnspatialresources):
distribution %<>% mutate(occurrenceStatus = recode(presence,
  "S" = "present",
  "M" = "present",
  "?" = "presence uncertain",
  "NA" = "absent",
  .default = "",
  .missing = "absent"
))


#' Remove records with `absent`:
distribution %<>% filter (!occurrenceStatus == "absent")

#' Overview of `occurrenceStatus` for each location x presence combination
distribution %>% select (location, presence, occurrenceStatus) %>%
  group_by_all() %>%
  summarize(records = n()) %>% 
  kable()

#' #### threatStatus
#' #### establishmentMeans
distribution %<>% mutate (establishmentMeans = "introduced")

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

#' Combine `start_year` and `end_year` in an ranged `Date` (ISO 8601 format). If any those two dates is empty or the same, we use a single year, as a statement when it was seen once (either as a first record or a most recent record):
distribution %<>% mutate(Date = 
  case_when(
    start_year == "" & end_year == "" ~ "",
    start_year == ""                  ~ end_year,
    end_year == ""                    ~ start_year,
    start_year == end_year            ~ start_year,
    TRUE                              ~ paste(start_year, end_year, sep = "/")
  )
)

#' Populate `eventDate` only when `presence` = `S`.
distribution %<>% mutate (eventDate = case_when(
  presence == "S" ~ Date,
  TRUE ~ ""))


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
  -location,-presence,
  -start_year, -end_year, - Date
)

#' Sort on `taxonID`:
distribution %<>% arrange(taxonID)

#' Preview data:
kable(head(distribution))

#' Save to CSV:
write.csv(distribution, file = dwc_distribution_file, na = "", row.names = FALSE, fileEncoding = "UTF-8")

#' ## Create description extension
#' 
#' In the description extension we want to include **origin** (`raw_d_n`), **native range** (`raw_origin`) and **pathway** (`raw_v_i``) information. We'll create a separate data frame for all and then combine these with union.
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

#' Create `description` from `raw_origin`:
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
  "AF" = "Africa (WGSRPD:2)",
  "AM" = "pan-American",
  "AS" = "Asia",
  "AS-Te" = "temperate Asia (WGSRPD:3)",
  "AS-Tr" = "tropical Asia (WGSRPD:4)",
  "AUS" = "Australasia (WGSRPD:5)",
  "Cult." = "cultivated origin",
  "E" = "Europe (WGSRPD:1)",
  "Hybr." = "hybrid origin",
  "NAM" = "Northern America (WGSRPD:7)",
  "SAM" = "Southern America (WGSRPD:8)",
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
pathway_desc <- raw_data

#' `pathway_desc` (pathway description) information is based on `raw_v_i`, which contains a list of introduction pathways (e.g. `Agric., wool`). We'll separate, clean, map and combine these values.
#' 
#' Create `pathway` from `raw_v_i`:
pathway_desc %<>% mutate(pathway = raw_v_i)

#' Separate `pathway` on `,` in 4 columns:
# In case there are more than 4 values, these will be merged in pathway_4. 
# The dataset currently contains no more than 3 values per record.
pathway_desc %<>% separate(
  pathway,
  into = c("pathway_1", "pathway_2", "pathway_3", "pathway_4"),
  sep = ",",
  remove = TRUE,
  convert = FALSE,
  extra = "merge",
  fill = "right"
)

#' Gather pathways in a key and value column:
pathway_desc %<>% gather(
  key, value,
  pathway_1, pathway_2, pathway_3, pathway_4,
  na.rm = TRUE, # Also removes records for which there is no pathway_1
  convert = FALSE
)

#' Sort on `taxonID` to see pathways in context for each record:
pathway_desc %<>% arrange(raw_taxonID)

#' Show unique values:
pathway_desc %>%
  distinct(value) %>%
  arrange(value) %>%
  kable()

#' Clean values:
pathway_desc %<>% mutate(
  value = str_replace_all(value, "\\?|…|\\.{3}", ""), # Strip ?, …, ...
  value = str_to_lower(value), # Convert to lowercase
  value = str_trim(value) # Clean whitespace
)

#' Map values to the CBD standard::
pathway_desc %<>% mutate(cbd_stand = recode(value, 
                                               "agric." = "escape_agriculture",
                                               "bird seed" = "contaminant_seed",
                                               "birdseed" = "contaminant_seed",
                                               "bulbs" = "",
                                               "coconut mats" = "contaminant_seed",
                                               "fish" = "",
                                               "food refuse" = "escape_food_bait",
                                               "grain" = "contaminant_seed",
                                               "grain (rice)" = "contaminant_seed",
                                               "grass seed" = "contaminant_seed",
                                               "hay" = "",
                                               "hort" = "escape_horticulture",
                                               "hort." = "escape_horticulture",
                                               "hybridization" = "",
                                               "military troops" = "",
                                               "nurseries" = "contaminant_nursery",
                                               "ore" = "contaminant_habitat_material",
                                               "pines" = "contaminant_on_plants",
                                               "rice" = "",
                                               "salt" = "",
                                               "seeds" = "contaminant_seed",
                                               "timber" = "contaminant_timber",
                                               "tourists" = "stowaway_people_luggage",
                                               "traffic" = "",
                                               "unknown" = "unknown",
                                               "urban weed" = "stowaway",
                                               "waterfowl" = "contaminant_on_animals",
                                               "wool" = "contaminant_on_animals",
                                               "wool alien" = "contaminant_on_animals",
                                               .default = "",
                                               .missing = "" # As result of stripping, records with no pathway already removed by gather()
))

#' Add prefix `cbd_2014_pathway` in case there is a match with the CBD standard:
pathway_desc %<>% mutate(mapped_value = case_when(
  cbd_stand != "" ~ paste ("cbd_2014_pathway", cbd_stand, sep = ":"),
  TRUE ~ ""))

#' Show mapped values:
pathway_desc %>%
  select(value, mapped_value) %>%
  group_by(value, mapped_value) %>%
  summarize(records = n()) %>%
  arrange(value) %>%
  kable()

#' Drop `key`,`value` and `cbd_stand` column:
pathway_desc %<>% select(-key, -value, -cbd_stand)

#' Change column name `mapped_value` to `description`:
pathway_desc %<>%  rename(description = mapped_value)

#' Create a `type` field to indicate the type of description:
pathway_desc %<>% mutate (type = "pathway")

#' Show pathway descriptions:
pathway_desc %>% 
  select(description) %>% 
  group_by(description) %>% 
  summarize(records = n()) %>% 
  kable()

#' Keep only non-empty descriptions:
pathway_desc %<>% filter(!is.na(description) & description != "")

#' #### Union origin, native range and pathway:
description_ext <- bind_rows(origin, native_range, pathway_desc)

#' ### Term mapping
#' 
#' Map the source data to [Taxon Description](http://rs.gbif.org/extension/gbif/1.0/description.xml):
#' 
#' #### id
description_ext %<>% mutate(taxonID = raw_taxonID)

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

#' Move `taxonID` to the first position:
description_ext %<>% select(taxonID, everything())

#' Sort on `taxonID`:
description_ext %<>% arrange(taxonID)

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
#' Number of duplicates: `r anyDuplicated(taxon[["taxonID"]])` (should be 0)
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
