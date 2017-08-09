# Darwin Core mapping

Peter Desmet & Quentin Groom

2017-08-09

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

Number of duplicates: (should be 0):


```r
anyDuplicated(taxon[["id"]])
```

```
## [1] 0
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
taxon %<>% mutate(scientificNameID = raw_scientificnameid)
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

Number of unique scientific names:


```r
length(unique(taxon[["scientificName"]]))
```

```
## [1] 2481
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

Number of unique families:


```r
length(unique(taxon[["family"]]))
```

```
## [1] 152
```

#### genus
#### subgenus
#### specificEpithet
#### infraspecificEpithet
#### taxonRank


```r
taxon %<>% mutate(taxonRank = raw_taxonrank)
```

Show unique values:


```r
taxon %>%
  distinct(taxonRank) %>%
  arrange(taxonRank) %>%
  kable()
```



|taxonRank  |
|:----------|
|cultivar   |
|genus      |
|hybrid     |
|species    |
|subspecies |
|variety    |

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



| id|language |license                                           |rightsHolder         |datasetID |datasetName                           | taxonID|scientificNameID                                 |scientificName                                             |kingdom |family        |taxonRank |nomenclaturalCode |
|--:|:--------|:-------------------------------------------------|:--------------------|:---------|:-------------------------------------|-------:|:------------------------------------------------|:----------------------------------------------------------|:-------|:-------------|:---------|:-----------------|
|  1|en       |http://creativecommons.org/publicdomain/zero/1.0/ |Botanic Garden Meise |          |Manual of the Alien Plants of Belgium |       1|http://ipni.org/urn:lsid:ipni.org:names:44892-1  |Acanthus mollis L.                                         |Plantae |Acanthaceae   |species   |ICBN              |
|  2|en       |http://creativecommons.org/publicdomain/zero/1.0/ |Botanic Garden Meise |          |Manual of the Alien Plants of Belgium |       2|http://ipni.org/urn:lsid:ipni.org:names:44920-1  |Acanthus spinosus L.                                       |Plantae |Acanthaceae   |species   |ICBN              |
|  3|en       |http://creativecommons.org/publicdomain/zero/1.0/ |Botanic Garden Meise |          |Manual of the Alien Plants of Belgium |       3|http://ipni.org/urn:lsid:ipni.org:names:84009-1  |Acorus calamus L.                                          |Plantae |Acoraceae     |species   |ICBN              |
|  4|en       |http://creativecommons.org/publicdomain/zero/1.0/ |Botanic Garden Meise |          |Manual of the Alien Plants of Belgium |       4|http://ipni.org/urn:lsid:ipni.org:names:913605-1 |Actinidia deliciosa (Chevalier) C.S. Liang & A.R. Ferguson |Plantae |Actinidiaceae |species   |ICBN              |
|  5|en       |http://creativecommons.org/publicdomain/zero/1.0/ |Botanic Garden Meise |          |Manual of the Alien Plants of Belgium |       5|http://ipni.org/urn:lsid:ipni.org:names:321978-2 |Sambucus canadensis L.                                     |Plantae |Adoxaceae     |species   |ICBN              |
|  6|en       |http://creativecommons.org/publicdomain/zero/1.0/ |Botanic Garden Meise |          |Manual of the Alien Plants of Belgium |       6|http://ipni.org/urn:lsid:ipni.org:names:149642-1 |Viburnum davidii Franch.                                   |Plantae |Adoxaceae     |species   |ICBN              |

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

`establishmentMeans` is based on `raw_v_i`, which contains a list of introductions pathways (e.g. `Agric., wool`). We'll separate, clean, map and combine these values.

Create `pathway` from `raw_v_i`:


```r
distribution %<>% mutate(pathway = raw_v_i)
```

Interpret `?` as empty (note that some raw values are already):


```r
distribution %<>% mutate(pathway = recode(pathway, "?" = ""))
```

Separate pathway on `,` in 4 columns:


```r
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
```

Gather pathways in a key and value column:


```r
distribution %<>% gather(
  key, value,
  pathway_1, pathway_2, pathway_3, pathway_4,
  na.rm = TRUE,
  convert = FALSE
)
```

Sort on ID to see pathways in context for each record:


```r
distribution %<>% arrange(id)
```

Show unique values:


```r
distribution %>%
  distinct(value) %>%
  arrange(value) %>%
  kable()
```



|value            |
|:----------------|
|                 |
|...              |
|…                |
|agric.           |
|birdseed         |
|etc.             |
|grain            |
|grain?           |
|hort.            |
|hort.?           |
|nurseries        |
|ore              |
|Ore              |
|ore?             |
|salt             |
|seeds            |
|timber?          |
|tourists         |
|urban weed       |
|wool             |
|...              |
|…                |
|Agric.           |
|Bird seed        |
|Birdseed         |
|Birdseed?        |
|Bulbs?           |
|Coconut mats     |
|Fish             |
|Food refuse      |
|Food refuse?     |
|Grain            |
|Grain (rice)     |
|Grain?           |
|Grass seed       |
|Grass seed?      |
|Hay?             |
|Hort             |
|hort.            |
|Hort.            |
|Hort.?           |
|Hybridization    |
|Military troops  |
|Military troops? |
|Nurseries        |
|Nurseries?       |
|Ore              |
|Ore?             |
|Pines            |
|Rice             |
|Seeds            |
|Seeds?           |
|Timber           |
|Timber?          |
|Tourists         |
|Traffic?         |
|Urban weed       |
|Waterfowl        |
|Waterfowl?       |
|Wool             |
|Wool alien       |
|Wool?            |

Strip `?`, `...` from values, convert to lowercase, and clean whitespace:


```r
distribution %<>% mutate(
  value = str_replace_all(value, "\\?|…|\\.{3}", ""),
  value = str_to_lower(value),
  value = str_trim(value)
)
```

Map values:


```r
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
```

Show mapped values:


```r
distribution %>%
  select(value, mapped_value) %>%
  group_by(value, mapped_value) %>%
  summarize(records = n()) %>%
  arrange(value) %>%
  kable()
```



|value           |mapped_value                 | records|
|:---------------|:----------------------------|-------:|
|                |                             |     540|
|agric.          |escape:agriculture           |      85|
|bird seed       |contaminant:seed             |       1|
|birdseed        |contaminant:seed             |      31|
|bulbs           |                             |       1|
|coconut mats    |contaminant:seed             |       1|
|etc.            |                             |       1|
|fish            |                             |       3|
|food refuse     |escape:food_bait             |      21|
|grain           |contaminant:seed             |     540|
|grain (rice)    |contaminant:seed             |       3|
|grass seed      |contaminant:seed             |       8|
|hay             |                             |       1|
|hort            |escape:horticulture          |       2|
|hort.           |escape:horticulture          |    1082|
|hybridization   |                             |      48|
|military troops |                             |       9|
|nurseries       |contaminant:nursery          |      19|
|ore             |contaminant:habitat_material |      87|
|pines           |contaminant:on_plants        |       4|
|rice            |                             |       1|
|salt            |                             |       2|
|seeds           |contaminant:seed             |      64|
|timber          |contaminant:timber           |      10|
|tourists        |stowaway:people_luggage      |      10|
|traffic         |                             |       4|
|urban weed      |stowaway                     |      10|
|waterfowl       |contaminant:on_animals       |      14|
|wool            |contaminant:on_animals       |     565|
|wool alien      |contaminant:on_animals       |       1|

Drop `value` column:


```r
distribution %<>% select(-value)
```

Convert empty values as `NA`:


```r
distribution %<>% mutate(mapped_value = na_if(mapped_value, ""))
```

Spread values back to columns:


```r
distribution %<>% spread(key, mapped_value)
```

Create `establishmentMeans` columns where these values are concatentated with ` | ` (omit `NA` values):


```r
distribution %<>% mutate(establishmentMeans = 
  paste(pathway_1, pathway_2, pathway_3, pathway_4, sep = " | ")              
)
```

Annoyingly the `paste()` function does not provide an `rm.na` parameter, so `NA` values will be included as ` | NA`. We can strip those out like this:


```r
distribution %<>% mutate(
  establishmentMeans = str_replace_all(establishmentMeans, " \\| NA", ""), # Remove ' | NA'
  establishmentMeans = recode(establishmentMeans, "NA" = "") # Remove NA at start of string
)
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
distribution %<>% mutate(end_year = recode(end_year,
  "Ann." = current_year,
  "N" = current_year)
)
```

Show reformatted values for both `raw_fr` and `raw_mrr`:


```r
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
```



|raw_year  |formatted_year |
|:---------|:--------------|
|?         |               |
|<1800     |1800           |
|<1812     |1812           |
|<1824     |1824           |
|<1827     |1827           |
|<1830     |1830           |
|<1834     |1834           |
|<1835     |1835           |
|<1836     |1836           |
|<1837     |1837           |
|<1842     |1842           |
|<1850     |1850           |
|<1858     |1858           |
|<1861     |1861           |
|<1865     |1865           |
|<1868     |1868           |
|<1885     |1885           |
|<1890     |1890           |
|<1893     |1893           |
|<1895     |1895           |
|<1899     |1899           |
|<1900     |1900           |
|<1900?    |1900           |
|<1914     |1914           |
|<1927     |1927           |
|<1929     |1929           |
|<1934     |1934           |
|<1949     |1949           |
|<1950     |1950           |
|<1951     |1951           |
|<1957     |1957           |
|<1963     |1963           |
|<1979     |1979           |
|<1980     |1980           |
|<1994     |1994           |
|<1997     |1997           |
|<1999     |1999           |
|<2003     |2003           |
|<2010     |2010           |
|<2011     |2011           |
|<2012     |2012           |
|>1940     |1940           |
|>1972     |1972           |
|1813?     |1813           |
|1817?     |1817           |
|1860?     |1860           |
|1866?     |1866           |
|1886?     |1886           |
|1893?     |1893           |
|1911?     |1911           |
|1912?     |1912           |
|1931?     |1931           |
|1947?     |1947           |
|1955?     |1955           |
|1959?     |1959           |
|1960?     |1960           |
|1963?     |1963           |
|1965?     |1965           |
|1972?     |1972           |
|1975?     |1975           |
|1976?     |1976           |
|1979?     |1979           |
|1985?     |1985           |
|1998?     |1998           |
|2000?     |2000           |
|2002?     |2002           |
|2004?     |2004           |
|2006?     |2006           |
|2010?     |2010           |
|ca. 1975  |1975           |
|ca. 1985? |1985           |
|ca. 1996  |1996           |
|N         |2017           |
|N?        |2017           |

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

Combine `start_year` and `end_year` in an ranged `eventDate` (ISO 8601 format). If any those two dates is empty or the same, we use a single year, as a statement when it was seen once (either as a first record or a most recent record):


```r
distribution %<>% mutate(eventDate = 
  case_when(
    start_year == "" & end_year == "" ~ "",
    start_year == ""                  ~ end_year,
    end_year == ""                    ~ start_year,
    start_year == end_year            ~ start_year,
    TRUE                              ~ paste(start_year, end_year, sep = "/")
  )
)
```

#### startDayOfYear
#### endDayOfYear
#### source
#### occurrenceRemarks
#### datasetID

### Post-processing

Remove the original columns:


```r
distribution %<>% select(
  -one_of(raw_colnames),
  -presence_be,
  -pathway_1, -pathway_2, -pathway_3, -pathway_4,
  -start_year, -end_year
)
```

Preview data:


```r
kable(head(distribution))
```



| id|locationID   |locality |countryCode |occurrenceStatus |establishmentMeans  |eventDate |
|--:|:------------|:--------|:-----------|:----------------|:-------------------|:---------|
|  1|ISO3166-2:BE |Belgium  |BE          |present          |escape:horticulture |1998/2016 |
|  2|ISO3166-2:BE |Belgium  |BE          |present          |escape:horticulture |2016      |
|  3|ISO3166-2:BE |Belgium  |BE          |present          |escape:horticulture |1680/2017 |
|  4|ISO3166-2:BE |Belgium  |BE          |present          |escape:food_bait    |2000/2017 |
|  5|ISO3166-2:BE |Belgium  |BE          |present          |escape:horticulture |1972/2015 |
|  6|ISO3166-2:BE |Belgium  |BE          |present          |escape:horticulture |2014/2015 |

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

