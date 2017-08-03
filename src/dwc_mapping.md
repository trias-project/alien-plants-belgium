# Darwin Core mapping

Peter Desmet & Quentin Groom

2017-08-03

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
library(magrittr)  # For %<>% pipes (not part of core tidyverse)
library(readxl)    # For reading Excel (not part of core tidyverse)
library(janitor)   # For cleaning input data
library(knitr)     # For nicer (kable) tables
source("functions/term_mapping.R") # For mapping values
```

Set file paths (all paths should be relative to this script):


```r
raw_data_file = "../data/raw/Checklist2.xlsx"
lookup_file = "../settings/lookup.csv"
dwc_taxon_file = "../data/processed/taxon.csv"
dwc_distribution_file = "../data/processed/distribution.csv"
dwc_description_file = "../data/processed/description.csv"
```

Load lookup table (contains information to map values):


```r
lookup_table <- read.csv(lookup_file)
```

## Read data

Read the source data:


```r
raw_data <- read_excel(
  path = raw_data_file
) 
```

Clean data somewhat:


```r
raw_data %<>%
  # Remove empty rows
  remove_empty_rows() %>%
  # Have sensible (lowercase) column names
  clean_names()
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



| raw_id|raw_taxon                                                  |raw_hybrid_formula |raw_synonym |raw_family    |raw_m_i |raw_fr |raw_mrr |raw_origin |raw_presence_fl |raw_presence_br |raw_presence_wa |raw_d_n |raw_v_i     |raw_taxonrank |raw_scientificnameid                             |
|------:|:----------------------------------------------------------|:------------------|:-----------|:-------------|:-------|:------|:-------|:----------|:---------------|:---------------|:---------------|:-------|:-----------|:-------------|:------------------------------------------------|
|      1|Acanthus mollis L.                                         |NA                 |NA          |Acanthaceae   |D       |1998   |2016    |E AF       |X               |NA              |X               |Cas.    |Hort.       |species       |http://ipni.org/urn:lsid:ipni.org:names:44892-1  |
|      2|Acanthus spinosus L.                                       |NA                 |NA          |Acanthaceae   |D       |2016   |2016    |E AF AS-Te |X               |NA              |NA              |Cas.    |Hort.       |species       |http://ipni.org/urn:lsid:ipni.org:names:44920-1  |
|      3|Acorus calamus L.                                          |NA                 |NA          |Acoraceae     |D       |1680   |N       |AS-Te      |X               |X               |X               |Nat.    |Hort.       |species       |http://ipni.org/urn:lsid:ipni.org:names:84009-1  |
|      4|Actinidia deliciosa (Chevalier) C.S. Liang & A.R. Ferguson |NA                 |NA          |Actinidiaceae |D       |2000   |Ann.    |AS-Te      |X               |NA              |X               |Cas.    |Food refuse |species       |http://ipni.org/urn:lsid:ipni.org:names:913605-1 |
|      5|Sambucus canadensis L.                                     |NA                 |NA          |Adoxaceae     |D       |1972   |2015    |NAM        |X               |NA              |NA              |Cas.    |Hort.       |species       |http://ipni.org/urn:lsid:ipni.org:names:321978-2 |
|      6|Viburnum davidii Franch.                                   |NA                 |NA          |Adoxaceae     |D       |2014   |2015    |AS-Te      |X               |NA              |NA              |Cas.    |Hort.       |species       |http://ipni.org/urn:lsid:ipni.org:names:149642-1 |

## Create taxon core


```r
taxon <- raw_data
```

### Term mapping

Map the source data to [Darwin Core Taxon](http://rs.gbif.org/core/dwc_taxon_2015-04-24.xml):

#### id


```r
taxon %<>% mutate(id = raw_id)
```

#### modified
#### language


```r
taxon %<>% mutate(language = "en")
```

#### license


```r
taxon %<>% mutate(license = "http://creativecommons.org/publicdomain/zero/1.0/")
```

#### rightsHolder


```r
taxon %<>% mutate(rightsHolder = "Botanic Garden Meise")
```

#### accessRights
#### bibliographicCitation
#### informationWithheld
#### datasetID


```r
taxon %<>% mutate(datasetID = "") # Should become dataset DOI
```

#### datasetName


```r
taxon %<>% mutate(datasetName = "Manual of the Alien Plants of Belgium")
```

#### references
#### taxonID


```r
taxon %<>% mutate(taxonID = raw_id)
```

#### scientificNameID


```r
# Code to be added
```

#### acceptedNameUsageID
#### parentNameUsageID
#### originalNameUsageID
#### nameAccordingToID
#### namePublishedInID
#### taxonConceptID
#### scientificName


```r
taxon %<>% mutate(scientificName = raw_taxon)
```

#### acceptedNameUsage
#### parentNameUsage
#### originalNameUsage
#### nameAccordingTo
#### namePublishedIn
#### namePublishedInYear
#### higherClassification
#### kingdom


```r
taxon %<>% mutate(kingdom = "Plantae")
```

#### phylum
#### class
#### order
#### family


```r
taxon %<>% mutate(family = raw_family)
```

#### genus
#### subgenus
#### specificEpithet
#### infraspecificEpithet
#### taxonRank


```r
# Code to be added
```

#### verbatimTaxonRank
#### scientificNameAuthorship
#### vernacularName
#### nomenclaturalCode


```r
taxon %<>% mutate(nomenclaturalCode = "ICBN")
```

#### taxonomicStatus
#### nomenclaturalStatus
#### taxonRemarks

### Post-processing

Remove the original columns:


```r
taxon %<>% select(-one_of(raw_colnames))
```

Preview data:


```r
kable(head(taxon))
```



| id|language |license                                           |rightsHolder         |datasetID |datasetName                           | taxonID|scientificName                                             |kingdom |family        |nomenclaturalCode |
|--:|:--------|:-------------------------------------------------|:--------------------|:---------|:-------------------------------------|-------:|:----------------------------------------------------------|:-------|:-------------|:-----------------|
|  1|en       |http://creativecommons.org/publicdomain/zero/1.0/ |Botanic Garden Meise |          |Manual of the Alien Plants of Belgium |       1|Acanthus mollis L.                                         |Plantae |Acanthaceae   |ICBN              |
|  2|en       |http://creativecommons.org/publicdomain/zero/1.0/ |Botanic Garden Meise |          |Manual of the Alien Plants of Belgium |       2|Acanthus spinosus L.                                       |Plantae |Acanthaceae   |ICBN              |
|  3|en       |http://creativecommons.org/publicdomain/zero/1.0/ |Botanic Garden Meise |          |Manual of the Alien Plants of Belgium |       3|Acorus calamus L.                                          |Plantae |Acoraceae     |ICBN              |
|  4|en       |http://creativecommons.org/publicdomain/zero/1.0/ |Botanic Garden Meise |          |Manual of the Alien Plants of Belgium |       4|Actinidia deliciosa (Chevalier) C.S. Liang & A.R. Ferguson |Plantae |Actinidiaceae |ICBN              |
|  5|en       |http://creativecommons.org/publicdomain/zero/1.0/ |Botanic Garden Meise |          |Manual of the Alien Plants of Belgium |       5|Sambucus canadensis L.                                     |Plantae |Adoxaceae     |ICBN              |
|  6|en       |http://creativecommons.org/publicdomain/zero/1.0/ |Botanic Garden Meise |          |Manual of the Alien Plants of Belgium |       6|Viburnum davidii Franch.                                   |Plantae |Adoxaceae     |ICBN              |

Save to CSV:


```r
write.csv(taxon, file = dwc_taxon_file, na = "", row.names = FALSE)
```

## Create distribution extension

### Pre-processing


```r
distribution <- raw_data
```

The checklist contains minimal presence information (`X` or `?`) for the three regions in Belgium (Flanders, Wallonia and the Brussels-Capital Region). Information regarding pathway, status, first and last recorded observation however apply to the distribution in Belgium as a whole. Since it is impossible to extrapolate that information for the regions, we decided to only provide distribution information for Belgium.
Create a `raw_presence_be` column, which contains `X` if any of the regions has `X` or else `?` if any of the regions has `?`:


```r
distribution %<>% mutate(raw_presence_be =
  case_when(
    raw_presence_fl == "X" | raw_presence_br == "X" | raw_presence_wa == "X" ~ "X", # One is "X"
    raw_presence_fl == "?" | raw_presence_br == "?" | raw_presence_wa == "?" ~ "?" # One is "?"
  )
)
```

### Term mapping

Map the source data to [Species Distribution](http://rs.gbif.org/extension/gbif/1.0/distribution.xml):
#### id


```r
distribution %<>% mutate(id = raw_id)
```

#### locationID


```r
distribution %<>% mutate(locationID = "ISO3166-2:BE")
```

#### locality


```r
distribution %<>% mutate(locality = "Belgium")
```

#### countryCode


```r
distribution %<>% mutate(countryCode = "BE")
```

#### lifeStage
#### occurrenceStatus

Use lookup table to map to [IUCN definitions](http://www.iucnredlist.org/technical-documents/red-list-training/iucnspatialresources):


```r
occurrencestatus_lookup <- term_mapping(lookup_table, "occurrenceStatus")
stack(occurrencestatus_lookup)
```

```
##               values      ind
## 1             extant        X
## 2 presence uncertain        ?
## 3             absent .missing
```

```r
distribution %<>% mutate(occurrenceStatus = 
  recode(raw_presence_be, !!!occurrencestatus_lookup)
)
```

#### threatStatus
#### establishmentMeans


```r
# To be added
```

#### appendixCITES
#### eventDate


```r
# To be added
```

#### startDayOfYear
#### endDayOfYear
#### source


```r
# Add?
```

#### occurrenceRemarks


```r
# Add?
```

#### datasetID

### Post-processing

Remove the original columns:


```r
distribution %<>% select(-one_of(raw_colnames), -raw_presence_be)
```

Preview data:


```r
kable(head(distribution))
```



| id|locationID   |locality |countryCode |occurrenceStatus |
|--:|:------------|:--------|:-----------|:----------------|
|  1|ISO3166-2:BE |Belgium  |BE          |extant           |
|  2|ISO3166-2:BE |Belgium  |BE          |extant           |
|  3|ISO3166-2:BE |Belgium  |BE          |extant           |
|  4|ISO3166-2:BE |Belgium  |BE          |extant           |
|  5|ISO3166-2:BE |Belgium  |BE          |extant           |
|  6|ISO3166-2:BE |Belgium  |BE          |extant           |

Save to CSV:


```r
write.csv(distribution, file = dwc_distribution_file, na = "", row.names = FALSE)
```

## Create description extension

### Pre-processing


```r
description <- raw_data
```

Transpose the data for the description columns, including for NA values:


```r
description %<>%
  gather(
    raw_description_type, raw_description_value,
    raw_origin, raw_d_n, raw_v_i,
    na.rm = FALSE,
    convert = FALSE
  ) %>%
  arrange(raw_id)
```

Preview the newly created columns:


```r
description %>% 
  select(raw_id, raw_description_type, raw_description_value) %>%
  head() %>%
  kable()
```



| raw_id|raw_description_type |raw_description_value |
|------:|:--------------------|:---------------------|
|      1|raw_origin           |E AF                  |
|      1|raw_d_n              |Cas.                  |
|      1|raw_v_i              |Hort.                 |
|      2|raw_origin           |E AF AS-Te            |
|      2|raw_d_n              |Cas.                  |
|      2|raw_v_i              |Hort.                 |

