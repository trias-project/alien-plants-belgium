# Darwin Core mapping

Peter Desmet & Quentin Groom
2017-07-01

This document describes how we map the checklist data to Darwin Core.

## Setup




Set locale (so we use UTF-8 character encoding):


```r
# This works on Mac OS X, might not work on other OS
Sys.setlocale("LC_ALL", 'en_US.UTF-8')
```

```
## [1] "en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/C"
```

Load libraries:


```r
library(tidyverse) # For data transformations
library(readxl)    # For reading Excel (not part of core tidyverse)
library(janitor)   # For cleaning input data
library(knitr)     # For nicer (kable) tables
source("term_mapping.R") # For mapping values
```

Set file paths (all paths should be relative to this script):


```r
raw_data_file = "../data/raw/Checklist2.xls"
lookup_file = "../settings/lookup.csv"
dwc_taxon_file = "../data/processed/taxon.csv"
dwc_distribution_file = "../data/processed/distribution.csv"
dwc_description_file = "../data/processed/description.csv"
```

Load lookup table


```r
lookup_table <- read.csv(lookup_file)
```

## Read data

Read the source data (an Excel file):


```r
read_excel(
  path = raw_data_file,
  skip = 1 # First row is empty
) -> raw_data
```

Clean data somewhat:


```r
raw_data %>%
  # Remove empty rows
  remove_empty_rows() %>%
  # Have sensible (lowercase) column names
  clean_names() -> raw_data
```

The first row contains subheaders for "presence": Fl., Br., Wa. so, we'll rename to actual headers to keep this information:


```r
raw_data %>%
  rename(presence_fl = presence, presence_br = x_1, presence_wa = x_2) %>%
  # That first row can now be removed, by slicing from 2 till the end
  slice(2:(n())) -> raw_data
```

Add row number as an identifier (`id`):


```r
raw_data <- cbind("id" = seq.int(nrow(raw_data)), raw_data)
```

Add prefix `raw_` to all column names to avoid name clashes with Darwin Core terms:


```r
colnames(raw_data) <- paste0("raw_", colnames(raw_data))
```

Save those column names as a list (makes it easier to remove them all later):


```r
raw_colnames <- colnames(raw_data)
```

Preview data:


```r
kable(head(raw_data))
```



| raw_id|raw_taxon                                                   |raw_synonym |raw_family    |raw_m_i |raw_fr |raw_mrr |raw_origin |raw_presence_fl |raw_presence_br |raw_presence_wa |raw_d_n |raw_v_i     |
|------:|:-----------------------------------------------------------|:-----------|:-------------|:-------|:------|:-------|:----------|:---------------|:---------------|:---------------|:-------|:-----------|
|      1|Acanthus mollis L.                                          |NA          |Acanthaceae   |D       |1998   |2016    |E AF       |X               |NA              |X               |Cas.    |Hort.       |
|      2|Acanthus spinosus L.                                        |NA          |Acanthaceae   |D       |2016   |2016    |E AF AS-Te |X               |NA              |NA              |Cas.    |Hort.       |
|      3|Acorus calamus L.                                           |NA          |Acoraceae     |D       |1680   |N       |AS-Te      |X               |X               |X               |Nat.    |Hort.       |
|      4|Actinidia deliciosa (Chevalier) C.S. Liang et A.R. Ferguson |NA          |Actinidiaceae |D       |2000   |Ann.    |AS-Te      |X               |NA              |X               |Cas.    |Food refuse |
|      5|Sambucus canadensis L.                                      |NA          |Adoxaceae     |D       |1972   |2015    |NAM        |X               |NA              |NA              |Cas.    |Hort.       |
|      6|Viburnum davidii Franch.                                    |NA          |Adoxaceae     |D       |2014   |2015    |AS-Te      |X               |NA              |NA              |Cas.    |Hort.       |

## Create taxon core

Map the source data to [Darwin Core Taxon](http://rs.gbif.org/core/dwc_taxon_2015-04-24.xml):


```r
raw_data %>% mutate(
  id = raw_id,
  # modified
  language = "en",
  license = "http://creativecommons.org/publicdomain/zero/1.0/",
  rightsHolder = "Botanic Garden Meise",
  # accessRights
  # bibliographicCitation
  # informationWithheld
  datasetID = "", # Should become the DOI
  datasetName = "Manual of the Alien Plants of Belgium", 
  # references
  taxonID = raw_id,
  # scientificNameID
  # acceptedNameUsageID
  # parentNameUsageID
  # originalNameUsageID
  # nameAccordingToID
  # namePublishedInID
  # taxonConceptID
  scientificName = raw_taxon,
  # acceptedNameUsage
  # parentNameUsage
  # originalNameUsage
  # nameAccordingTo
  # namePublishedIn
  # namePublishedInYear
  # higherClassification
  kingdom = "Plantae",
  # phylum
  # class
  # order
  family = raw_family,
  # genus
  # subgenus
  # specificEpithet
  # infraspecificEpithet
  # taxonRank
  # verbatimTaxonRank
  # scientificNameAuthorship
  # vernacularName
  nomenclaturalCode = "ICBN"
  # taxonomicStatus
  # nomenclaturalStatus
  # taxonRemarks
) -> interim_taxon
```

Remove the original columns:


```r
interim_taxon %>%
  select(-one_of(raw_colnames)) -> taxon
```

Preview data:


```r
kable(head(taxon))
```



| id|language |license                                           |rightsHolder         |datasetID |datasetName                           | taxonID|scientificName                                              |kingdom |family        |nomenclaturalCode |
|--:|:--------|:-------------------------------------------------|:--------------------|:---------|:-------------------------------------|-------:|:-----------------------------------------------------------|:-------|:-------------|:-----------------|
|  1|en       |http://creativecommons.org/publicdomain/zero/1.0/ |Botanic Garden Meise |          |Manual of the Alien Plants of Belgium |       1|Acanthus mollis L.                                          |Plantae |Acanthaceae   |ICBN              |
|  2|en       |http://creativecommons.org/publicdomain/zero/1.0/ |Botanic Garden Meise |          |Manual of the Alien Plants of Belgium |       2|Acanthus spinosus L.                                        |Plantae |Acanthaceae   |ICBN              |
|  3|en       |http://creativecommons.org/publicdomain/zero/1.0/ |Botanic Garden Meise |          |Manual of the Alien Plants of Belgium |       3|Acorus calamus L.                                           |Plantae |Acoraceae     |ICBN              |
|  4|en       |http://creativecommons.org/publicdomain/zero/1.0/ |Botanic Garden Meise |          |Manual of the Alien Plants of Belgium |       4|Actinidia deliciosa (Chevalier) C.S. Liang et A.R. Ferguson |Plantae |Actinidiaceae |ICBN              |
|  5|en       |http://creativecommons.org/publicdomain/zero/1.0/ |Botanic Garden Meise |          |Manual of the Alien Plants of Belgium |       5|Sambucus canadensis L.                                      |Plantae |Adoxaceae     |ICBN              |
|  6|en       |http://creativecommons.org/publicdomain/zero/1.0/ |Botanic Garden Meise |          |Manual of the Alien Plants of Belgium |       6|Viburnum davidii Franch.                                    |Plantae |Adoxaceae     |ICBN              |

Save to CSV:


```r
write.csv(taxon, file = dwc_taxon_file, na = "", row.names = FALSE)
```

## Create distribution extension

Create a `raw_presence_be` column, which contains `X` if any of the regions has `X` and if not has `?` if any of the regions has `?`:


```r
raw_data %>%
  mutate(raw_presence_be = case_when(
    .$raw_presence_fl == "X" | .$raw_presence_br == "X" | .$raw_presence_wa == "X" ~ "X",
    .$raw_presence_fl == "?" | .$raw_presence_br == "?" | .$raw_presence_wa == "?" ~ "?")
  ) -> interim_distribution
```

Transpose the data for the four presence columns, but not for `NA` values:


```r
interim_distribution %>%
  gather(
    raw_presence_region, raw_presence_value,
    raw_presence_be, raw_presence_br, raw_presence_fl, raw_presence_wa,
    na.rm = TRUE,
    convert = FALSE
  ) %>%
  arrange(raw_id) -> interim_distribution # Sort on ID
```

Preview the newly created columns:


```r
interim_distribution %>% 
  select(raw_id, raw_presence_region, raw_presence_value) %>%
  head() %>%
  kable()
```



| raw_id|raw_presence_region |raw_presence_value |
|------:|:-------------------|:------------------|
|      1|raw_presence_be     |X                  |
|      1|raw_presence_fl     |X                  |
|      1|raw_presence_wa     |X                  |
|      2|raw_presence_be     |X                  |
|      2|raw_presence_fl     |X                  |
|      3|raw_presence_be     |X                  |

Map the source data to [Species Distribution](http://rs.gbif.org/extension/gbif/1.0/distribution.xml):


```r
interim_distribution %>% mutate(
  id = raw_id,
  locationID = paste0(
    "ISO3166-2:",
    recode(.$raw_presence_region, !!!term_mapping(lookup_table, "locationID"))
  ),
  locality = recode(.$raw_presence_region, !!!term_mapping(lookup_table, "locality")),
  countryCode = "BE",
  # lifeStage
  occurrenceStatus = recode(.$raw_presence_value, !!!term_mapping(lookup_table, "occurrenceStatus"))
  # threatStatus
  # establishmentMeans
  # appendixCITES
  # eventDate
  # startDayOfYear
  # endDayOfYear
  # source
  # occurrenceRemarks
  # datasetID
) -> interim_distribution
```

Remove the original columns + the two new ones:


```r
interim_distribution %>%
  select(-one_of(raw_colnames), -raw_presence_region, -raw_presence_value) -> distribution
```

Preview data:


```r
kable(head(distribution))
```



| id|locationID       |locality       |countryCode |occurrenceStatus |
|--:|:----------------|:--------------|:-----------|:----------------|
|  1|ISO3166-2:BE     |Belgium        |BE          |present          |
|  1|ISO3166-2:BE-VLG |Flemish Region |BE          |present          |
|  1|ISO3166-2:BE-WAL |Walloon Region |BE          |present          |
|  2|ISO3166-2:BE     |Belgium        |BE          |present          |
|  2|ISO3166-2:BE-VLG |Flemish Region |BE          |present          |
|  3|ISO3166-2:BE     |Belgium        |BE          |present          |

Save to CSV:


```r
write.csv(distribution, file = dwc_distribution_file, na = "", row.names = FALSE)
```

## Create description extension

Transpose the data for the four description columns, including for NA values:


```r
raw_data %>%
  gather(
    raw_description_type, raw_description_value,
    raw_fr, raw_mrr, raw_origin, raw_d_n, raw_v_i,
    na.rm = FALSE,
    convert = FALSE
  ) %>%
  arrange(raw_id) -> interim_description # Sort on ID
```

Preview the newly created columns:


```r
interim_description %>% 
  select(raw_id, raw_description_type, raw_description_value) %>%
  head() %>%
  kable()
```



| raw_id|raw_description_type |raw_description_value |
|------:|:--------------------|:---------------------|
|      1|raw_fr               |1998                  |
|      1|raw_mrr              |2016                  |
|      1|raw_origin           |E AF                  |
|      1|raw_d_n              |Cas.                  |
|      1|raw_v_i              |Hort.                 |
|      2|raw_fr               |2016                  |

