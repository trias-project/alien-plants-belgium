# Darwin Core mapping

Peter Desmet & Quentin Groom

2017-08-08

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

# None core tidyverse packages:
library(magrittr)  # For %<>% pipes
library(readxl)    # For reading Excel
library(stringr)   # For string manipulation

# Other packages
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
Create a `presence_be` column, which contains `X` if any of the regions has `X` or else `?` if any of the regions has `?`:


```r
distribution %<>% mutate(presence_be =
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
## 1            present        X
## 2 presence uncertain        ?
## 3             absent .missing
```

```r
distribution %<>% mutate(occurrenceStatus = 
  recode(presence_be, !!!occurrencestatus_lookup)
)
```

#### threatStatus
#### establishmentMeans


```r
# To be added
```

#### appendixCITES
#### eventDate

Create `start_year` from `raw_fr` (first record):


```r
distribution %<>% mutate(start_year = raw_fr)
```

Strip `?`, `ca.`, `>` and `<` from the values:


```r
distribution %<>% mutate(start_year = 
  str_replace_all(start_year, "(\\?|ca. |<|>)", "")
)
```

Show reformatted values:


```r
distribution %>%
  select(raw_fr, start_year) %>%
  group_by(raw_fr, start_year) %>%
  summarize(records = n()) %>%
  filter(nchar(raw_fr) != 4) %>% # Only show values that were not YYYY
  kable()
```



|raw_fr    |start_year | records|
|:---------|:----------|-------:|
|?         |           |      53|
|<1800     |1800       |      16|
|<1812     |1812       |       1|
|<1824     |1824       |       1|
|<1827     |1827       |       2|
|<1830     |1830       |       4|
|<1834     |1834       |       1|
|<1835     |1835       |      38|
|<1836     |1836       |       2|
|<1837     |1837       |       2|
|<1842     |1842       |       1|
|<1850     |1850       |      67|
|<1858     |1858       |       6|
|<1861     |1861       |       2|
|<1865     |1865       |       1|
|<1868     |1868       |       1|
|<1885     |1885       |       1|
|<1890     |1890       |       1|
|<1893     |1893       |       2|
|<1895     |1895       |       2|
|<1899     |1899       |       1|
|<1900     |1900       |      13|
|<1900?    |1900       |       1|
|<1929     |1929       |       1|
|<1934     |1934       |       1|
|<1949     |1949       |       1|
|<1950     |1950       |       5|
|<1951     |1951       |       1|
|<1957     |1957       |       1|
|<1980     |1980       |       1|
|<1994     |1994       |       1|
|<1997     |1997       |       1|
|<1999     |1999       |       5|
|<2010     |2010       |       1|
|<2011     |2011       |       1|
|<2012     |2012       |       1|
|>1972     |1972       |       1|
|1813?     |1813       |       1|
|1817?     |1817       |       1|
|1860?     |1860       |       1|
|1866?     |1866       |       1|
|1886?     |1886       |       1|
|1893?     |1893       |       1|
|1911?     |1911       |       1|
|1931?     |1931       |       1|
|1955?     |1955       |       1|
|1960?     |1960       |       1|
|1963?     |1963       |       1|
|1965?     |1965       |       1|
|1975?     |1975       |       1|
|1976?     |1976       |       1|
|1979?     |1979       |       1|
|1985?     |1985       |       1|
|1998?     |1998       |       1|
|2000?     |2000       |       1|
|2002?     |2002       |       1|
|2006?     |2006       |       1|
|ca. 1975  |1975       |       1|
|ca. 1985? |1985       |       1|
|ca. 1996  |1996       |       1|

Create `end_year` from `raw_mrr` (most recent record):


```r
distribution %<>% mutate(end_year = raw_mrr)
```

Strip `?`, `ca.`, `>` and `<` from the values:


```r
distribution %<>% mutate(end_year = 
  str_replace_all(end_year, "(\\?|ca. |<|>)", "")
)
```

If `end_year` is `Ann.` or `N` use current year:


```r
current_year = format(Sys.Date(), "%Y")
distribution %<>% mutate(end_year =
  recode(end_year, "Ann." = current_year, "N" = current_year)
)
```

If `last_year` is empty we leave it empty.

Show reformatted values:


```r
distribution %>%
  select(raw_mrr, end_year) %>%
  group_by(raw_mrr, end_year) %>%
  summarize(records = n()) %>%
  filter(nchar(raw_mrr) != 4) %>% # Only show values that were not YYYY
  kable()
```



|raw_mrr |end_year | records|
|:-------|:--------|-------:|
|?       |         |      23|
|<1812   |1812     |       1|
|<1827   |1827     |       1|
|<1835   |1835     |       3|
|<1837   |1837     |       2|
|<1850   |1850     |      25|
|<1858   |1858     |       2|
|<1861   |1861     |       1|
|<1890   |1890     |       1|
|<1893   |1893     |       2|
|<1900   |1900     |       5|
|<1900?  |1900     |       1|
|<1914   |1914     |       1|
|<1927   |1927     |       1|
|<1934   |1934     |       1|
|<1949   |1949     |       2|
|<1950   |1950     |       2|
|<1951   |1951     |       1|
|<1957   |1957     |       1|
|<1963   |1963     |       1|
|<1979   |1979     |       1|
|<1994   |1994     |       2|
|<1997   |1997     |       1|
|<1999   |1999     |       1|
|<2003   |2003     |       1|
|>1940   |1940     |       1|
|1912?   |1912     |       1|
|1947?   |1947     |       1|
|1959?   |1959     |       1|
|1960?   |1960     |       1|
|1965?   |1965     |       1|
|1972?   |1972     |       1|
|1976?   |1976     |       1|
|1979?   |1979     |       1|
|1985?   |1985     |       1|
|2004?   |2004     |       1|
|2010?   |2010     |       1|
|N       |2017     |     512|
|N?      |2017     |      99|

Check if any `start_year` fall after `end_year` (expected to be none):


```r
distribution %>%
  select(start_year, end_year) %>%
  mutate(start_year = as.numeric(start_year)) %>%
  mutate(end_year = as.numeric(end_year)) %>%
  group_by(start_year, end_year) %>%
  summarize(records = n()) %>%
  filter(start_year > end_year) %>%
  kable()
```



| start_year| end_year| records|
|----------:|--------:|-------:|

Combine `start_year` and `end_year` in an ranged `eventDate` (ISO 8601 format). If any those two dates is empty, we use a single year, as a statement when it was seen once (either as a first record or a most recent record):


```r
distribution %<>% mutate(eventDate = 
  case_when(
    start_year == "" & end_year == "" ~ "",
    start_year == ""                  ~ end_year,
    end_year == ""                    ~ start_year,
    TRUE                              ~ paste(start_year, end_year, sep = "/")
  )
)
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
distribution %<>% select(-one_of(raw_colnames), -presence_be, -start_year, -end_year)
```

Preview data:


```r
kable(head(distribution))
```



| id|locationID   |locality |countryCode |occurrenceStatus |eventDate |
|--:|:------------|:--------|:-----------|:----------------|:---------|
|  1|ISO3166-2:BE |Belgium  |BE          |present          |1998/2016 |
|  2|ISO3166-2:BE |Belgium  |BE          |present          |2016/2016 |
|  3|ISO3166-2:BE |Belgium  |BE          |present          |1680/2017 |
|  4|ISO3166-2:BE |Belgium  |BE          |present          |2000/2017 |
|  5|ISO3166-2:BE |Belgium  |BE          |present          |1972/2015 |
|  6|ISO3166-2:BE |Belgium  |BE          |present          |2014/2015 |

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

