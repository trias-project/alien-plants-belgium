# Darwin Core mapping

Peter Desmet, Quentin Groom, Lien Reyserhove

2017-12-11

This document describes how we map the checklist data to Darwin Core.

## Setup




Set locale (so we use UTF-8 character encoding):


```r
# This works on Mac OS X, might not work on other OS
Sys.setlocale("LC_CTYPE", "en_US.UTF-8")
```

```
## [1] ""
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
```

Set file paths (all paths should be relative to this script):


```r
raw_data_file = "../data/raw/Checklist2.xlsx"
dwc_taxon_file = "../data/processed/taxon.csv"
dwc_distribution_file = "../data/processed/distribution.csv"
dwc_description_file = "../data/processed/description.csv"
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

### Pre-processing


```r
taxon <- raw_data
```

### Term mapping

Map the source data to [Darwin Core Taxon](http://rs.gbif.org/core/dwc_taxon_2015-04-24.xml):

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



|language |license                                           |rightsHolder         |datasetID |datasetName                           | taxonID|scientificNameID                                 |scientificName                                             |kingdom |family        |taxonRank |nomenclaturalCode |
|:--------|:-------------------------------------------------|:--------------------|:---------|:-------------------------------------|-------:|:------------------------------------------------|:----------------------------------------------------------|:-------|:-------------|:---------|:-----------------|
|en       |http://creativecommons.org/publicdomain/zero/1.0/ |Botanic Garden Meise |          |Manual of the Alien Plants of Belgium |       1|http://ipni.org/urn:lsid:ipni.org:names:44892-1  |Acanthus mollis L.                                         |Plantae |Acanthaceae   |species   |ICBN              |
|en       |http://creativecommons.org/publicdomain/zero/1.0/ |Botanic Garden Meise |          |Manual of the Alien Plants of Belgium |       2|http://ipni.org/urn:lsid:ipni.org:names:44920-1  |Acanthus spinosus L.                                       |Plantae |Acanthaceae   |species   |ICBN              |
|en       |http://creativecommons.org/publicdomain/zero/1.0/ |Botanic Garden Meise |          |Manual of the Alien Plants of Belgium |       3|http://ipni.org/urn:lsid:ipni.org:names:84009-1  |Acorus calamus L.                                          |Plantae |Acoraceae     |species   |ICBN              |
|en       |http://creativecommons.org/publicdomain/zero/1.0/ |Botanic Garden Meise |          |Manual of the Alien Plants of Belgium |       4|http://ipni.org/urn:lsid:ipni.org:names:913605-1 |Actinidia deliciosa (Chevalier) C.S. Liang & A.R. Ferguson |Plantae |Actinidiaceae |species   |ICBN              |
|en       |http://creativecommons.org/publicdomain/zero/1.0/ |Botanic Garden Meise |          |Manual of the Alien Plants of Belgium |       5|http://ipni.org/urn:lsid:ipni.org:names:321978-2 |Sambucus canadensis L.                                     |Plantae |Adoxaceae     |species   |ICBN              |
|en       |http://creativecommons.org/publicdomain/zero/1.0/ |Botanic Garden Meise |          |Manual of the Alien Plants of Belgium |       6|http://ipni.org/urn:lsid:ipni.org:names:149642-1 |Viburnum davidii Franch.                                   |Plantae |Adoxaceae     |species   |ICBN              |

Save to CSV:


```r
write.csv(taxon, file = dwc_taxon_file, na = "", row.names = FALSE, fileEncoding = "UTF-8")
```

## Create distribution extension

### Pre-processing


```r
distribution <- raw_data
```

The checklist contains minimal presence information (`X`,`?` or `NA`) for the three regions in Belgium (Flanders, Wallonia and the Brussels-Capital Region).
Both national and regional information is required in the checklist. In the `distribution.csv`, we first provide the information on a national level for pathway, status and dates; followed by specific information for the regions. 
However, information regarding pathway, status, first and last recorded observation applies to the distribution in Belgium as a whole.
It is impossible to extrapolate this information for the regions, unless the species is present in only one region.
In this case, we can assume pathway, status and date relate to that region and so we can keep lines for Belgium and for the specific region populated for all DwC terms (see #45)
When a species is present in more than one region, we decided to only provide occurrenceStatus for the regional information, and specify all other information regarding pathway and dates only for Belgium
Thus, we need to specify when a species is present in only one of the regions.
We generate 4 new columns: `Flanders`, `Brussels`,`Wallonia` and `Belgium`. 
The content of these columns refers to the specific occurrence of a species on a regional or national level.
`X` if present, `?` if presence unknown, `NA` if absent and `S` if **exclusively present in that specific region**


```r
distribution %<>% 
  mutate(Flanders = case_when(
    raw_presence_fl == "X" & (is.na(raw_presence_br) | raw_presence_br == "?") & (is.na(raw_presence_wa) | raw_presence_wa == "?") ~ "S",
    TRUE ~ raw_presence_fl)) %>%
  mutate(Brussels = case_when(
    (is.na(raw_presence_fl) | raw_presence_fl == "?") & raw_presence_br == "X" & (is.na(raw_presence_wa) | raw_presence_wa == "?") ~ "S",
    TRUE ~ raw_presence_br)) %>%
  mutate(Wallonia = case_when(
    (is.na(raw_presence_fl) | raw_presence_fl == "?") & (is.na(raw_presence_br) | raw_presence_br == "?") & raw_presence_wa == "X" ~ "S",
    TRUE ~ raw_presence_wa))%<>%
  mutate(Belgium = case_when(
    raw_presence_fl == "X" | raw_presence_br == "X" | raw_presence_wa == "X" ~ "X", # One is "X"
    raw_presence_fl == "?" | raw_presence_br == "?" | raw_presence_wa == "?" ~ "?" # One is "?"
  ))
```

Summary of the previous action:


```r
distribution %>% select (raw_presence_fl, raw_presence_br, raw_presence_wa, Flanders, Wallonia, Brussels, Belgium) %>%
  group_by_all() %>%
  summarize(records = n()) %>%
  arrange(Flanders, Wallonia, Brussels) %>%
  kable()
```



|raw_presence_fl |raw_presence_br |raw_presence_wa |Flanders |Wallonia |Brussels |Belgium | records|
|:---------------|:---------------|:---------------|:--------|:--------|:--------|:-------|-------:|
|?               |?               |?               |?        |?        |?        |?       |      22|
|?               |X               |?               |?        |?        |S        |X       |       1|
|X               |?               |?               |S        |?        |?        |X       |       2|
|X               |NA              |?               |S        |?        |NA       |X       |       1|
|X               |NA              |NA              |S        |NA       |NA       |X       |     767|
|X               |?               |X               |X        |X        |?        |X       |       5|
|X               |X               |X               |X        |X        |X        |X       |     486|
|X               |NA              |X               |X        |X        |NA       |X       |     616|
|X               |X               |NA              |X        |NA       |X        |X       |      69|
|NA              |NA              |X               |NA       |S        |NA       |X       |     469|
|NA              |X               |X               |NA       |X        |X        |X       |      24|
|NA              |X               |NA              |NA       |NA       |S        |X       |      36|
|NA              |NA              |NA              |NA       |NA       |NA       |NA      |       2|

From wide to long table (i.e. create a `key` and `value` column)


```r
distribution %<>% gather(
  key, value,
  Flanders, Wallonia, Brussels, Belgium,
  na.rm = TRUE, # Also removes records for which there is no pathway_1
  convert = FALSE
) 
```

Rename `key` and `value`


```r
distribution %<>% rename ("location" = "key", "presence" = "value")
```

### Term mapping

Map the source data to [Species Distribution](http://rs.gbif.org/extension/gbif/1.0/distribution.xml):
#### id


```r
distribution %<>% mutate(id = raw_id)
```

#### locationID


```r
distribution %<>% mutate(locationID = case_when (
  location == "Belgium" ~ "ISO_3166-2:BE",
  location == "Flanders" ~ "ISO_3166-2:BE-VLG",
  location == "Wallonia" ~ "ISO_3166-2:BE-WAL",
  location == "Brussels" ~ "ISO_3166-2:BE-BRU"))
```

#### locality


```r
distribution %<>% mutate(locality = case_when (
  location == "Belgium" ~ "Belgium",
  location == "Flanders" ~ "Flemish Region",
  location == "Wallonia" ~ "Walloon Region",
  location == "Brussels" ~ "Brussels-Capital Region"))
```

#### countryCode


```r
distribution %<>% mutate(countryCode = "BE")
```

#### lifeStage
#### occurrenceStatus

Map values using [IUCN definitions](http://www.iucnredlist.org/technical-documents/red-list-training/iucnspatialresources):


```r
distribution %<>% mutate(occurrenceStatus = recode(presence,
                                                   "X" = "present",
                                                   "S" = "present",
                                                   "?" = "unknown",
                                                   .default = "",
                                                   .missing = "absent"
))
```

overview of `occurrenceStatus` for each location x presence combination


```r
distribution %>% select (location, presence, occurrenceStatus) %>%
  group_by_all() %>%
  summarize(records = n()) %>% 
  kable()
```



|location |presence |occurrenceStatus | records|
|:--------|:--------|:----------------|-------:|
|Belgium  |?        |unknown          |      22|
|Belgium  |X        |present          |    2476|
|Brussels |?        |unknown          |      29|
|Brussels |S        |present          |      37|
|Brussels |X        |present          |     579|
|Flanders |?        |unknown          |      23|
|Flanders |S        |present          |     770|
|Flanders |X        |present          |    1176|
|Wallonia |?        |unknown          |      26|
|Wallonia |S        |present          |     469|
|Wallonia |X        |present          |    1131|

#### threatStatus
#### establishmentMeans

`establishmentMeans` is based on `raw_v_i`, which contains a list of introductions pathways (e.g. `Agric., wool`). We'll separate, clean, map and combine these values.

Create `pathway` from `raw_v_i`:


```r
distribution %<>% mutate(pathway = raw_v_i)
```

Separate `pathway` on `,` in 4 columns:


```r
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
```

Gather pathways in a key and value column:


```r
distribution %<>% gather(
  key, value,
  pathway_1, pathway_2, pathway_3, pathway_4,
  na.rm = TRUE, # Also removes records for which there is no pathway_1
  convert = FALSE
)
```

Sort on `id` to see pathways in context for each record:


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
|?                |
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

Clean values:


```r
distribution %<>% mutate(
  value = str_replace_all(value, "\\?|â€¦|\\.{3}", ""), # Strip ?, â€¦, ...
  value = str_to_lower(value), # Convert to lowercase
  value = str_trim(value) # Clean whitespace
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
  .default = "",
  .missing = "" # As result of stripping, records with no pathway already removed by gather()
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
|                |                             |     399|
|…               |                             |    1261|
|agric.          |escape:agriculture           |     300|
|bird seed       |contaminant:seed             |       2|
|birdseed        |contaminant:seed             |      90|
|bulbs           |                             |       2|
|coconut mats    |contaminant:seed             |       2|
|etc.            |                             |       3|
|fish            |                             |       6|
|food refuse     |escape:food_bait             |      59|
|grain           |contaminant:seed             |    1589|
|grain (rice)    |contaminant:seed             |       7|
|grass seed      |contaminant:seed             |      19|
|hay             |                             |       4|
|hort            |escape:horticulture          |       6|
|hort.           |escape:horticulture          |    2941|
|hybridization   |                             |     125|
|military troops |                             |      22|
|nurseries       |contaminant:nursery          |      54|
|ore             |contaminant:habitat_material |     282|
|pines           |contaminant:on_plants        |      11|
|rice            |                             |       2|
|salt            |                             |       6|
|seeds           |contaminant:seed             |     185|
|timber          |contaminant:timber           |      29|
|tourists        |stowaway:people_luggage      |      24|
|traffic         |                             |      12|
|urban weed      |stowaway                     |      30|
|waterfowl       |contaminant:on_animals       |      44|
|wool            |contaminant:on_animals       |    1550|
|wool alien      |contaminant:on_animals       |       2|

Drop `value` column:


```r
distribution %<>% select(-value)
```

Convert empty values to `NA` (important to be able to remove them after paste):


```r
distribution %<>% mutate(mapped_value = na_if(mapped_value, ""))
```

Since our pathway controlled vocabulary is not allowed by GBIF in `establishmentMeans` (see <https://github.com/trias-project/alien-plants-belgium/issues/35>), we'll also add it to the Description extension. Rather than cleaning it all over again there, we save it here:


```r
pathway <- distribution %>% select(
    one_of(raw_colnames), # Add raw columns
    mapped_value)
```

Spread values back to columns:


```r
distribution %<>% spread(key, mapped_value)
```

Create `pathway` columns where these values are concatentated with ` | `:


```r
distribution %<>% mutate(pathway = 
                           paste(pathway_1, pathway_2, pathway_3, pathway_4, sep = " | ")              
)
```

Annoyingly the `paste()` function does not provide an `rm.na` parameter, so `NA` values will be included as ` | NA`. We can strip those out like this:


```r
distribution %<>% mutate(
  pathway = str_replace_all(pathway, " \\| NA", ""), # Remove ' | NA'
  pathway = recode(pathway, "NA" = "") # Remove NA at start of string
)
```

Only populate `establishmentMeans` when `presence` = `X` for `location`= `Belgium`, OR when `presence` = `S` for the regions.


```r
distribution %<>% mutate (establishmentMeans = case_when(
  presence == "X" & location == "Belgium" ~ pathway,
  presence == "S" ~ pathway,
  TRUE ~ ""))
```

Show mapping of `establishmentMeans`


```r
distribution %>% select (location, presence, establishmentMeans) %>%
  group_by_all() %>%
  summarize(records = n()) %>%
  kable()
```



|location |presence |establishmentMeans                                                                 | records|
|:--------|:--------|:----------------------------------------------------------------------------------|-------:|
|Belgium  |?        |                                                                                   |      22|
|Belgium  |X        |                                                                                   |     201|
|Belgium  |X        |contaminant:habitat_material                                                       |      69|
|Belgium  |X        |contaminant:habitat_material &#124; contaminant:on_animals                         |       4|
|Belgium  |X        |contaminant:habitat_material &#124; contaminant:seed                               |       2|
|Belgium  |X        |contaminant:habitat_material &#124; contaminant:seed &#124; contaminant:on_animals |       2|
|Belgium  |X        |contaminant:habitat_material &#124; escape:horticulture                            |       2|
|Belgium  |X        |contaminant:nursery                                                                |      19|
|Belgium  |X        |contaminant:on_animals                                                             |     345|
|Belgium  |X        |contaminant:on_animals &#124; contaminant:habitat_material                         |       4|
|Belgium  |X        |contaminant:on_animals &#124; contaminant:on_animals                               |       1|
|Belgium  |X        |contaminant:on_animals &#124; contaminant:seed                                     |      51|
|Belgium  |X        |contaminant:on_animals &#124; escape:horticulture                                  |       2|
|Belgium  |X        |contaminant:on_animals &#124; stowaway                                             |       1|
|Belgium  |X        |contaminant:on_animals &#124; stowaway:people_luggage                              |       1|
|Belgium  |X        |contaminant:on_plants                                                              |       4|
|Belgium  |X        |contaminant:seed                                                                   |     379|
|Belgium  |X        |contaminant:seed &#124; contaminant:habitat_material                               |       4|
|Belgium  |X        |contaminant:seed &#124; contaminant:habitat_material &#124; contaminant:on_animals |       1|
|Belgium  |X        |contaminant:seed &#124; contaminant:on_animals                                     |     146|
|Belgium  |X        |contaminant:seed &#124; contaminant:on_animals &#124; contaminant:habitat_material |       2|
|Belgium  |X        |contaminant:seed &#124; contaminant:on_animals &#124; contaminant:seed             |       2|
|Belgium  |X        |contaminant:seed &#124; contaminant:on_animals &#124; escape:horticulture          |       1|
|Belgium  |X        |contaminant:seed &#124; contaminant:seed                                           |      16|
|Belgium  |X        |contaminant:seed &#124; contaminant:seed &#124; contaminant:habitat_material       |       1|
|Belgium  |X        |contaminant:seed &#124; contaminant:seed &#124; contaminant:on_animals             |       1|
|Belgium  |X        |contaminant:seed &#124; escape:horticulture                                        |       8|
|Belgium  |X        |contaminant:seed &#124; stowaway:people_luggage                                    |       1|
|Belgium  |X        |contaminant:timber                                                                 |       9|
|Belgium  |X        |escape:agriculture                                                                 |      77|
|Belgium  |X        |escape:agriculture &#124; contaminant:on_animals                                   |       2|
|Belgium  |X        |escape:agriculture &#124; contaminant:seed                                         |       1|
|Belgium  |X        |escape:agriculture &#124; escape:horticulture                                      |       1|
|Belgium  |X        |escape:food_bait                                                                   |      20|
|Belgium  |X        |escape:food_bait &#124; contaminant:on_animals                                     |       1|
|Belgium  |X        |escape:horticulture                                                                |    1054|
|Belgium  |X        |escape:horticulture &#124; contaminant:habitat_material                            |       2|
|Belgium  |X        |escape:horticulture &#124; contaminant:on_animals                                  |       4|
|Belgium  |X        |escape:horticulture &#124; contaminant:on_animals &#124; contaminant:seed          |       2|
|Belgium  |X        |escape:horticulture &#124; contaminant:seed                                        |       7|
|Belgium  |X        |escape:horticulture &#124; contaminant:seed &#124; contaminant:on_animals          |       2|
|Belgium  |X        |escape:horticulture &#124; contaminant:timber                                      |       1|
|Belgium  |X        |escape:horticulture &#124; escape:agriculture                                      |       3|
|Belgium  |X        |stowaway                                                                           |       7|
|Belgium  |X        |stowaway &#124; contaminant:nursery                                                |       1|
|Belgium  |X        |stowaway &#124; contaminant:on_animals                                             |       1|
|Belgium  |X        |stowaway:people_luggage                                                            |       6|
|Belgium  |X        |stowaway:people_luggage &#124; contaminant:on_animals                              |       2|
|Brussels |?        |                                                                                   |      29|
|Brussels |S        |                                                                                   |      14|
|Brussels |S        |contaminant:seed                                                                   |       3|
|Brussels |S        |escape:agriculture                                                                 |       1|
|Brussels |S        |escape:horticulture                                                                |      19|
|Brussels |X        |                                                                                   |     579|
|Flanders |?        |                                                                                   |      23|
|Flanders |S        |                                                                                   |      82|
|Flanders |S        |contaminant:habitat_material                                                       |      19|
|Flanders |S        |contaminant:nursery                                                                |      10|
|Flanders |S        |contaminant:on_animals                                                             |       8|
|Flanders |S        |contaminant:on_plants                                                              |       1|
|Flanders |S        |contaminant:seed                                                                   |     194|
|Flanders |S        |contaminant:seed &#124; contaminant:seed                                           |       2|
|Flanders |S        |contaminant:seed &#124; stowaway:people_luggage                                    |       1|
|Flanders |S        |contaminant:timber                                                                 |       2|
|Flanders |S        |escape:agriculture                                                                 |       6|
|Flanders |S        |escape:food_bait                                                                   |       9|
|Flanders |S        |escape:horticulture                                                                |     423|
|Flanders |S        |escape:horticulture &#124; contaminant:habitat_material                            |       1|
|Flanders |S        |escape:horticulture &#124; contaminant:seed                                        |       1|
|Flanders |S        |stowaway                                                                           |       3|
|Flanders |S        |stowaway:people_luggage                                                            |       6|
|Flanders |X        |                                                                                   |    1175|
|Wallonia |?        |                                                                                   |      26|
|Wallonia |S        |                                                                                   |      52|
|Wallonia |S        |contaminant:habitat_material                                                       |      11|
|Wallonia |S        |contaminant:on_animals                                                             |     254|
|Wallonia |S        |contaminant:on_animals &#124; contaminant:seed                                     |       4|
|Wallonia |S        |contaminant:on_animals &#124; escape:horticulture                                  |       1|
|Wallonia |S        |contaminant:seed                                                                   |      32|
|Wallonia |S        |contaminant:seed &#124; contaminant:seed                                           |       2|
|Wallonia |S        |contaminant:timber                                                                 |       2|
|Wallonia |S        |escape:agriculture                                                                 |       1|
|Wallonia |S        |escape:food_bait                                                                   |       1|
|Wallonia |S        |escape:horticulture                                                                |     108|
|Wallonia |S        |escape:horticulture &#124; contaminant:seed                                        |       1|
|Wallonia |X        |                                                                                   |    1130|

#### appendixCITES
#### eventDate

Create `start_year` from `raw_fr` (first record):


```r
distribution %<>% mutate(start_year = raw_fr)
```

Clean values:


```r
distribution %<>% mutate(start_year = 
  str_replace_all(start_year, "(\\?|ca. |<|>)", "") # Strip ?, ca., < and >
)
```

Create `end_year` from `raw_mrr` (most recent record):


```r
distribution %<>% mutate(end_year = raw_mrr)
```

Clean values:


```r
distribution %<>% mutate(end_year = 
  str_replace_all(end_year, "(\\?|ca. |<|>)", "") # Strip ?, ca., < and >
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

Combine `start_year` and `end_year` in an ranged `Date` (ISO 8601 format). If any those two dates is empty or the same, we use a single year, as a statement when it was seen once (either as a first record or a most recent record):


```r
distribution %<>% mutate(Date = 
                           case_when(
                             start_year == "" & end_year == "" ~ "",
                             start_year == ""                  ~ end_year,
                             end_year == ""                    ~ start_year,
                             start_year == end_year            ~ start_year,
                             TRUE                              ~ paste(start_year, end_year, sep = "/")
                           )
)
```

Populate `eventDate` only when `presence` = `X` for `location`= `Belgium`, OR when `presence` = `S` for the regions.


```r
distribution %<>% mutate (eventDate = case_when(
  presence == "X" & location == "Belgium" ~ Date,
  presence == "S" ~ Date,
  TRUE ~ ""))
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
  -location,-presence,
  -pathway_1, -pathway_2, -pathway_3, -pathway_4, -pathway,
  -start_year, -end_year, - Date
)
```

Sort on `id`:


```r
distribution %<>% arrange(id)
```

Preview data:


```r
kable(head(distribution))
```



| id|locationID        |locality       |countryCode |occurrenceStatus |establishmentMeans  |eventDate |
|--:|:-----------------|:--------------|:-----------|:----------------|:-------------------|:---------|
|  1|ISO_3166-2:BE-VLG |Flemish Region |BE          |present          |                    |          |
|  1|ISO_3166-2:BE-WAL |Walloon Region |BE          |present          |                    |          |
|  1|ISO_3166-2:BE     |Belgium        |BE          |present          |escape:horticulture |1998/2016 |
|  2|ISO_3166-2:BE-VLG |Flemish Region |BE          |present          |escape:horticulture |2016      |
|  2|ISO_3166-2:BE     |Belgium        |BE          |present          |escape:horticulture |2016      |
|  3|ISO_3166-2:BE-VLG |Flemish Region |BE          |present          |                    |          |

Save to CSV:


```r
write.csv(distribution, file = dwc_distribution_file, na = "", row.names = FALSE, fileEncoding = "UTF-8")
```

## Create description extension

In the description extension we want to include **origin** (`raw_d_n`) and **native range** (`raw_origin`) information. We'll create a separate data frame for both and then combine these with union.

### Pre-processing

#### Origin

`origin` describes if a species is native in a distribution or not. Since Darwin Core has no `origin` field yet as suggested in [ias-dwc-proposal](https://github.com/qgroom/ias-dwc-proposal/blob/master/proposal.md#origin-new-term), we'll add this information in the description extension.

Create new data frame:


```r
origin <- raw_data
```

Create `description` from `raw_d_n`:


```r
origin %<>% mutate(description = raw_d_n)
```

Create a `type` field to indicate the type of description:


```r
origin %<>% mutate(type = "origin")
```

Clean values:


```r
origin %<>% mutate(description = 
  str_replace_all(description, "\\?", ""), # Strip ?
  description = str_trim(description) # Clean whitespace
)
```

Map values using [this vocabulary](https://github.com/qgroom/ias-dwc-proposal/blob/master/vocabulary/origin.tsv):


```r
origin %<>% mutate(description = recode(description,
  "Cas." = "vagrant",
  "Nat." = "introduced",
  "Ext." = "",
  "Inv." = "",
  "Ext./Cas." = "",
  .default = "",
  .missing = ""
))
```

Show mapped values:


```r
origin %>%
  select(raw_d_n, description) %>%
  group_by(raw_d_n, description) %>%
  summarize(records = n()) %>%
  arrange(raw_d_n) %>%
  kable()
```



|raw_d_n   |description | records|
|:---------|:-----------|-------:|
|Cas.      |vagrant     |    1808|
|Cas.?     |vagrant     |      50|
|Ext.      |            |      15|
|Ext./Cas. |            |       4|
|Ext.?     |            |       4|
|Inv.      |            |      64|
|Nat.      |introduced  |     453|
|Nat.?     |introduced  |     101|
|NA        |            |       1|

Keep only non-empty descriptions:


```r
origin %<>% filter(!is.na(description) & description != "")
```

Preview data:


```r
kable(head(origin))
```



| raw_id|raw_taxon                                                  |raw_hybrid_formula |raw_synonym |raw_family    |raw_m_i |raw_fr |raw_mrr |raw_origin |raw_presence_fl |raw_presence_br |raw_presence_wa |raw_d_n |raw_v_i     |raw_taxonrank |raw_scientificnameid                             |description |type   |
|------:|:----------------------------------------------------------|:------------------|:-----------|:-------------|:-------|:------|:-------|:----------|:---------------|:---------------|:---------------|:-------|:-----------|:-------------|:------------------------------------------------|:-----------|:------|
|      1|Acanthus mollis L.                                         |NA                 |NA          |Acanthaceae   |D       |1998   |2016    |E AF       |X               |NA              |X               |Cas.    |Hort.       |species       |http://ipni.org/urn:lsid:ipni.org:names:44892-1  |vagrant     |origin |
|      2|Acanthus spinosus L.                                       |NA                 |NA          |Acanthaceae   |D       |2016   |2016    |E AF AS-Te |X               |NA              |NA              |Cas.    |Hort.       |species       |http://ipni.org/urn:lsid:ipni.org:names:44920-1  |vagrant     |origin |
|      3|Acorus calamus L.                                          |NA                 |NA          |Acoraceae     |D       |1680   |N       |AS-Te      |X               |X               |X               |Nat.    |Hort.       |species       |http://ipni.org/urn:lsid:ipni.org:names:84009-1  |introduced  |origin |
|      4|Actinidia deliciosa (Chevalier) C.S. Liang & A.R. Ferguson |NA                 |NA          |Actinidiaceae |D       |2000   |Ann.    |AS-Te      |X               |NA              |X               |Cas.    |Food refuse |species       |http://ipni.org/urn:lsid:ipni.org:names:913605-1 |vagrant     |origin |
|      5|Sambucus canadensis L.                                     |NA                 |NA          |Adoxaceae     |D       |1972   |2015    |NAM        |X               |NA              |NA              |Cas.    |Hort.       |species       |http://ipni.org/urn:lsid:ipni.org:names:321978-2 |vagrant     |origin |
|      6|Viburnum davidii Franch.                                   |NA                 |NA          |Adoxaceae     |D       |2014   |2015    |AS-Te      |X               |NA              |NA              |Cas.    |Hort.       |species       |http://ipni.org/urn:lsid:ipni.org:names:149642-1 |vagrant     |origin |

#### Native range

`raw_origin` contains native range information (e.g. `E AS-Te NAM`). We'll separate, clean, map and combine these values.

Create new data frame:


```r
native_range <- raw_data
```

Create `description` from `raw_origin`:


```r
native_range %<>% mutate(description = raw_origin)
```

Separate `description` on space in 4 columns:


```r
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
```

Gather native ranges in a key and value column:


```r
native_range %<>% gather(
  key, value,
  native_range_1, native_range_2, native_range_3, native_range_4,
  na.rm = TRUE, # Also removes records for which there is no native_range_1
  convert = FALSE
)
```

Sort on ID to see pathways in context for each record:


```r
native_range %<>% arrange(raw_id)
```

Clean values:


```r
native_range %<>% mutate(
  value = str_replace_all(value, "\\?", ""), # Strip ?
  value = str_trim(value) # Clean whitespace
)
```

Map values:


```r
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
```

Show mapped values:


```r
native_range %>%
  select(value, mapped_value) %>%
  group_by(value, mapped_value) %>%
  summarize(records = n()) %>%
  arrange(value) %>%
  kable()
```



|value |mapped_value      | records|
|:-----|:-----------------|-------:|
|      |                  |       1|
|AF    |Africa            |     636|
|AM    |pan-American      |      93|
|AS    |Asia              |      71|
|AS-Te |temperate Asia    |    1050|
|AS-Tr |tropical Asia     |      12|
|AUS   |Australasia       |     117|
|Cult. |cultivated origin |      90|
|E     |Europe            |    1122|
|Hybr. |hybrid origin     |      67|
|NAM   |Northern America  |     362|
|SAM   |Southern America  |     157|
|Trop. |Pantropical       |      37|

Drop `key` and `value` column and rename `mapped value`:


```r
native_range %<>% select(-key, -value)
native_range %<>% rename(description = mapped_value)
```

Keep only non-empty descriptions:


```r
native_range %<>% filter(!is.na(description) & description != "")
```

Create a `type` field to indicate the type of description:


```r
native_range %<>% mutate(type = "native range")
```

Preview data:


```r
kable(head(native_range))
```



| raw_id|raw_taxon            |raw_hybrid_formula |raw_synonym |raw_family  |raw_m_i |raw_fr |raw_mrr |raw_origin |raw_presence_fl |raw_presence_br |raw_presence_wa |raw_d_n |raw_v_i |raw_taxonrank |raw_scientificnameid                            |description    |type         |
|------:|:--------------------|:------------------|:-----------|:-----------|:-------|:------|:-------|:----------|:---------------|:---------------|:---------------|:-------|:-------|:-------------|:-----------------------------------------------|:--------------|:------------|
|      1|Acanthus mollis L.   |NA                 |NA          |Acanthaceae |D       |1998   |2016    |E AF       |X               |NA              |X               |Cas.    |Hort.   |species       |http://ipni.org/urn:lsid:ipni.org:names:44892-1 |Europe         |native range |
|      1|Acanthus mollis L.   |NA                 |NA          |Acanthaceae |D       |1998   |2016    |E AF       |X               |NA              |X               |Cas.    |Hort.   |species       |http://ipni.org/urn:lsid:ipni.org:names:44892-1 |Africa         |native range |
|      2|Acanthus spinosus L. |NA                 |NA          |Acanthaceae |D       |2016   |2016    |E AF AS-Te |X               |NA              |NA              |Cas.    |Hort.   |species       |http://ipni.org/urn:lsid:ipni.org:names:44920-1 |Europe         |native range |
|      2|Acanthus spinosus L. |NA                 |NA          |Acanthaceae |D       |2016   |2016    |E AF AS-Te |X               |NA              |NA              |Cas.    |Hort.   |species       |http://ipni.org/urn:lsid:ipni.org:names:44920-1 |Africa         |native range |
|      2|Acanthus spinosus L. |NA                 |NA          |Acanthaceae |D       |2016   |2016    |E AF AS-Te |X               |NA              |NA              |Cas.    |Hort.   |species       |http://ipni.org/urn:lsid:ipni.org:names:44920-1 |temperate Asia |native range |
|      3|Acorus calamus L.    |NA                 |NA          |Acoraceae   |D       |1680   |N       |AS-Te      |X               |X               |X               |Nat.    |Hort.   |species       |http://ipni.org/urn:lsid:ipni.org:names:84009-1 |temperate Asia |native range |

#### Pathway (pathway of introduction) 

Pathway information was already generated for `establishmentMeans` in the Distribution extension and saved in a dataframe `pathway`. It contains one record per pathway (with potentially more than one pathway per taxon).
Change column name `mapped_value` to `description`:


```r
pathway %<>%  rename(description = mapped_value)
```

Create a `type` field to indicate the type of description:


```r
pathway %<>% mutate (type = "pathway")
```

Show pathway descriptions:


```r
pathway %>% 
  select(description) %>% 
  group_by(description) %>% 
  summarize(records = n()) %>% 
  kable()
```



|description                  | records|
|:----------------------------|-------:|
|contaminant:habitat_material |     282|
|contaminant:nursery          |      54|
|contaminant:on_animals       |    1596|
|contaminant:on_plants        |      11|
|contaminant:seed             |    1894|
|contaminant:timber           |      29|
|escape:agriculture           |     300|
|escape:food_bait             |      59|
|escape:horticulture          |    2947|
|stowaway                     |      30|
|stowaway:people_luggage      |      24|
|NA                           |    1842|

Keep only non-empty descriptions:


```r
pathway %<>% filter(!is.na(description) & description != "")
```

#### Union origin, native range and pathway:


```r
description_ext <- bind_rows(origin, native_range, pathway)
```

### Term mapping

Map the source data to [Taxon Description](http://rs.gbif.org/extension/gbif/1.0/description.xml):

#### id


```r
description_ext %<>% mutate(id = raw_id)
```

#### description


```r
description_ext %<>% mutate(description = description)
```

#### type


```r
description_ext %<>% mutate(type = type)
```

#### source
#### language


```r
description_ext %<>% mutate(language = "en")
```

#### created
#### creator
#### contributor
#### audience
#### license
#### rightsHolder
#### datasetID
### Post-processing

Remove the original columns:


```r
description_ext %<>% select(
  -one_of(raw_colnames)
)
```

Move `id` to the first position:


```r
description_ext %<>% select(id, everything())
```

Sort on `id`:


```r
description_ext %<>% arrange(id)
```

Preview data:


```r
kable(head(description_ext, 10))
```



| id|description         |type         |language |
|--:|:-------------------|:------------|:--------|
|  1|vagrant             |origin       |en       |
|  1|Europe              |native range |en       |
|  1|Africa              |native range |en       |
|  1|escape:horticulture |pathway      |en       |
|  1|escape:horticulture |pathway      |en       |
|  1|escape:horticulture |pathway      |en       |
|  2|vagrant             |origin       |en       |
|  2|Europe              |native range |en       |
|  2|Africa              |native range |en       |
|  2|temperate Asia      |native range |en       |

Save to CSV:


```r
write.csv(description_ext, file = dwc_description_file, na = "", row.names = FALSE, fileEncoding = "UTF-8")
```

## Summary

### Number of records

* Source file: 2500
* Taxon core: 2500
* Distribution extension: 6731
* Description extension: 13452

### Taxon core

Number of duplicates: 0 (should be 0)

The following numbers are expected to be the same:

* Number of records: 2500
* Number of distinct `taxonID`: 2500
* Number of distinct `scientificName`: 2500
* Number of distinct `scientificNameID`: 1707 (can contain NAs)
* Number of distinct `scientificNameID` and `NA`: 2500

Number of unique families: 152
