# Darwin Core mapping

Peter Desmet, Quentin Groom, Lien Reyserhove

2018-03-29

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
library(digest)    # To generate hashes
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
raw_data <- read_excel(path = raw_data_file) 
```

Clean data somewhat:


```r
raw_data %<>%
  # Remove empty rows
  remove_empty_rows() %>%
  # Have sensible (lowercase) column names
  clean_names()
```

We need to integrate the DwC term `taxonID` in each of the generated files (Taxon Core and Extensions).
For this reason, it is easier to generate `taxonID` in the raw file. 
First, we vectorize the digest function (The digest() function isn't vectorized. 
So if you pass in a vector, you get one value for the whole vector rather than a digest for each element of the vector):


```r
vdigest <- Vectorize(digest)
```

Generate `taxonID`:


```r
raw_data %<>% mutate(taxonID = paste("alien-plants-belgium", "taxon", vdigest (taxon, algo="md5"), sep=":"))
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



| raw_id|raw_taxon                                                  |raw_hybrid_formula |raw_synonym |raw_family    |raw_m_i |raw_fr |raw_mrr |raw_origin |raw_presence_fl |raw_presence_br |raw_presence_wa |raw_d_n |raw_v_i     |raw_taxonrank |raw_scientificnameid                             |raw_taxonID                                                 |
|------:|:----------------------------------------------------------|:------------------|:-----------|:-------------|:-------|:------|:-------|:----------|:---------------|:---------------|:---------------|:-------|:-----------|:-------------|:------------------------------------------------|:-----------------------------------------------------------|
|      1|Acanthus mollis L.                                         |NA                 |NA          |Acanthaceae   |D       |1998   |2016    |E AF       |X               |NA              |X               |Cas.    |Hort.       |species       |http://ipni.org/urn:lsid:ipni.org:names:44892-1  |alien-plants-belgium:taxon:509ddbbaa5ecbb8d91899905cfc9491c |
|      2|Acanthus spinosus L.                                       |NA                 |NA          |Acanthaceae   |D       |2016   |2017    |E AF AS-Te |X               |NA              |NA              |Cas.    |Hort.       |species       |http://ipni.org/urn:lsid:ipni.org:names:44920-1  |alien-plants-belgium:taxon:a65145fd1f24f081a1931f9874af48d9 |
|      3|Acorus calamus L.                                          |NA                 |NA          |Acoraceae     |D       |1680   |N       |AS-Te      |X               |X               |X               |Nat.    |Hort.       |species       |http://ipni.org/urn:lsid:ipni.org:names:84009-1  |alien-plants-belgium:taxon:574eaf931730ba162e0226a425247660 |
|      4|Actinidia deliciosa (Chevalier) C.S. Liang & A.R. Ferguson |NA                 |NA          |Actinidiaceae |D       |2000   |Ann.    |AS-Te      |X               |NA              |X               |Cas.    |Food refuse |species       |http://ipni.org/urn:lsid:ipni.org:names:913605-1 |alien-plants-belgium:taxon:5c33253debbe5777c0499b5c4d76b6e4 |
|      5|Sambucus canadensis L.                                     |NA                 |NA          |Adoxaceae     |D       |1972   |2017    |NAM        |X               |NA              |NA              |Cas.    |Hort.       |species       |http://ipni.org/urn:lsid:ipni.org:names:321978-2 |alien-plants-belgium:taxon:03206f4a769c6649658ab96839e8a016 |
|      6|Viburnum davidii Franch.                                   |NA                 |NA          |Adoxaceae     |D       |2014   |2015    |AS-Te      |X               |NA              |NA              |Cas.    |Hort.       |species       |http://ipni.org/urn:lsid:ipni.org:names:149642-1 |alien-plants-belgium:taxon:12212e50c4f6c9b79616e9d7f95a1cfb |

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
taxon %<>% mutate(datasetID = "https://doi.org/10.15468/wtda1m")
```

#### datasetName


```r
taxon %<>% mutate(datasetName = "Manual of the Alien Plants of Belgium")
```

#### references
#### taxonID


```r
taxon %<>% mutate(taxonID = raw_taxonID)
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



|language |license                                           |rightsHolder         |datasetID                       |datasetName                           |taxonID                                                     |scientificNameID                                 |scientificName                                             |kingdom |family        |taxonRank |nomenclaturalCode |
|:--------|:-------------------------------------------------|:--------------------|:-------------------------------|:-------------------------------------|:-----------------------------------------------------------|:------------------------------------------------|:----------------------------------------------------------|:-------|:-------------|:---------|:-----------------|
|en       |http://creativecommons.org/publicdomain/zero/1.0/ |Botanic Garden Meise |https://doi.org/10.15468/wtda1m |Manual of the Alien Plants of Belgium |alien-plants-belgium:taxon:509ddbbaa5ecbb8d91899905cfc9491c |http://ipni.org/urn:lsid:ipni.org:names:44892-1  |Acanthus mollis L.                                         |Plantae |Acanthaceae   |species   |ICBN              |
|en       |http://creativecommons.org/publicdomain/zero/1.0/ |Botanic Garden Meise |https://doi.org/10.15468/wtda1m |Manual of the Alien Plants of Belgium |alien-plants-belgium:taxon:a65145fd1f24f081a1931f9874af48d9 |http://ipni.org/urn:lsid:ipni.org:names:44920-1  |Acanthus spinosus L.                                       |Plantae |Acanthaceae   |species   |ICBN              |
|en       |http://creativecommons.org/publicdomain/zero/1.0/ |Botanic Garden Meise |https://doi.org/10.15468/wtda1m |Manual of the Alien Plants of Belgium |alien-plants-belgium:taxon:574eaf931730ba162e0226a425247660 |http://ipni.org/urn:lsid:ipni.org:names:84009-1  |Acorus calamus L.                                          |Plantae |Acoraceae     |species   |ICBN              |
|en       |http://creativecommons.org/publicdomain/zero/1.0/ |Botanic Garden Meise |https://doi.org/10.15468/wtda1m |Manual of the Alien Plants of Belgium |alien-plants-belgium:taxon:5c33253debbe5777c0499b5c4d76b6e4 |http://ipni.org/urn:lsid:ipni.org:names:913605-1 |Actinidia deliciosa (Chevalier) C.S. Liang & A.R. Ferguson |Plantae |Actinidiaceae |species   |ICBN              |
|en       |http://creativecommons.org/publicdomain/zero/1.0/ |Botanic Garden Meise |https://doi.org/10.15468/wtda1m |Manual of the Alien Plants of Belgium |alien-plants-belgium:taxon:03206f4a769c6649658ab96839e8a016 |http://ipni.org/urn:lsid:ipni.org:names:321978-2 |Sambucus canadensis L.                                     |Plantae |Adoxaceae     |species   |ICBN              |
|en       |http://creativecommons.org/publicdomain/zero/1.0/ |Botanic Garden Meise |https://doi.org/10.15468/wtda1m |Manual of the Alien Plants of Belgium |alien-plants-belgium:taxon:12212e50c4f6c9b79616e9d7f95a1cfb |http://ipni.org/urn:lsid:ipni.org:names:149642-1 |Viburnum davidii Franch.                                   |Plantae |Adoxaceae     |species   |ICBN              |

Save to CSV:


```r
write.csv(taxon, file = dwc_taxon_file, na = "", row.names = FALSE, fileEncoding = "UTF-8")
```

## Create distribution extension

### Pre-processing


```r
distribution <- raw_data
```

Before we start mapping the distribution extensions, we focus on two terms: `occurrenceStatus` and  `eventDate`:

This is because:

1. Information on the occurrences is given for the **regions**, while date information is given for **Belgium** as a whole. Some transformations and clarifications are needed.
2. Some species have two values for `occurrenceStatus` and `eventDate`, i.e. species with the degree of naturalisation (`raw_d_n`) of extinct (`Ext.`) or extinct/casual (`Ext./Cas.`).
- Extinct: introduced taxa that once were naturalized (usually rather locally) but that have not been confirmed in recent times in their known localities. Only taxa that are certainly extinct are indicated as such.   
- Extinct/casual: Some of these extinct taxa are no longer considered as naturalized but still occur as casuals; such taxa are indicated as â€œExt./Cas.â€ (for instance _Tragopogon porrifolius_).

For these species, we include the occurrenceStatus **within** the specified time frame (`eventDate` = first - most recent observation) and **after** the last observation (`eventDate` = most recent observation - current date).
The easiest way to do this is by:
1. Cleaning presence information and date information in `distribution`
2. Creating a separate dataframe `occurrenceStatus_ALO` (ALO = after last observation)
3. Map `occurrenceStatus` and `eventDate` from cleaned presence and date information in `distribution` (for `eventDate` = first - most recent observation)
4. Map `occurrenceStatus` and `eventDate` from cleaned presence and date information in `occurrenceStatus_ALO` (for `eventDate` = most recent observation - current date)
5. Bind both dataframes by row.
6. Map the other Darwin Core terms in the distribution extension

### Clean presence information: occurrenceStatus for regions and Belgium
The checklist contains minimal presence information (`X`,`?` or `NA`) for the three regions in Belgium: Flanders, Wallonia and the Brussels-Capital Region, contained in `raw_presence_fl`, `raw_presence_wa` and `raw_presence_br` respectively.
Information regarding the first/last recorded observation applies to the distribution in Belgium as a whole.
Both national and regional information is required in the checklist. In the `distribution.csv`, we will first provide `occurrenceStatus` and `eventDate`` on a **national level**, followed by specific information for the **regions**. 

For this, we use the following principles:

1. When a species is present in _only one region_, we can assume `eventDate` relates to that specific region. In this case, we can keep lines for Belgium and for the specific region populated with these variables (see #45).
2. When a species is present in _more than one_ region, it is impossible to extrapolate the date information for the regions. In this case, we decided to provide `occurrenceStatus` for the regional information, and specify dates only for Belgium.  
Thus, we need to specify when a species is present in only one of the regions.

We generate 4 new columns: `Flanders`, `Brussels`,`Wallonia` and `Belgium`. 
The content of these columns refers to the specific presence status of a species on a regional or national level.
`S` if present in a single region or in Belgium, `?` if presence uncertain, `NA` if absent and `M` if present in multiple regions.
This should look like this:


```r
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
```



|raw_presence_fl |raw_presence_br |raw_presence_wa |Flanders |Brussels |Wallonia |Belgium |
|:---------------|:---------------|:---------------|:--------|:--------|:--------|:-------|
|X               |NA              |NA              |S        |NA       |NA       |S       |
|NA              |X               |NA              |NA       |S        |NA       |S       |
|NA              |NA              |x               |NA       |NA       |S        |S       |
|X               |X               |NA              |M        |M        |NA       |S       |
|X               |NA              |X               |M        |NA       |M        |S       |
|NA              |X               |X               |NA       |M        |M        |S       |
|NA              |NA              |NA              |NA       |NA       |NA       |NA      |
|X               |?               |NA              |S        |?        |NA       |S       |
|X               |NA              |?               |S        |NA       |?        |S       |
|X               |X               |?               |M        |M        |?        |S       |

We translate this to the distribution extension:


```r
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
|?               |?               |?               |?        |?        |?        |?       |      21|
|?               |X               |?               |?        |?        |S        |S       |       1|
|X               |?               |X               |M        |M        |?        |S       |       5|
|X               |X               |X               |M        |M        |M        |S       |     496|
|X               |NA              |X               |M        |M        |NA       |S       |     627|
|X               |X               |NA              |M        |NA       |M        |S       |      72|
|NA              |X               |X               |NA       |M        |M        |S       |      24|
|NA              |NA              |NA              |NA       |NA       |NA       |NA      |       2|
|NA              |X               |NA              |NA       |NA       |S        |S       |      36|
|NA              |NA              |X               |NA       |S        |NA       |S       |     461|
|X               |?               |?               |S        |?        |?        |S       |       3|
|X               |NA              |?               |S        |?        |NA       |S       |       1|
|X               |NA              |NA              |S        |NA       |NA       |S       |     773|

One line should represent the presence information of a species in one region or Belgium. We need to transform `raw_data` from a wide to a long table (i.e. create a `key` and `value` column)


```r
distribution %<>% gather(
  key, value,
  Flanders, Wallonia, Brussels, Belgium,
  convert = FALSE
) 
```

Rename `key` and `value`


```r
distribution %<>% rename ("location" = "key", "presence" = "value")
```

Remove species for which we lack presence information (i.e. `presence` = `NA``)


```r
distribution %<>% filter (!presence == "NA")
```

### Clean date information
Create `start_year` from `raw_fr` 


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
|N         |2018           |
|N?        |2018           |

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

### Generate `occurrenceStatus_ALO`


```r
occurrenceStatus_ALO <- distribution %>% filter(raw_d_n == "Ext." | raw_d_n == "Ext./Cas.")
```

### Map occurrenceStatus and eventDate for `distribution`:
Map `occurrenceStaus` using [IUCN definitions](http://www.iucnredlist.org/technical-documents/red-list-training/iucnspatialresources):


```r
distribution %<>% mutate(occurrenceStatus = recode(presence,
                                                       "S" = "present",
                                                       "M" = "present",
                                                       "?" = "presence uncertain",
                                                       .default = ""))
```

Overview of `occurrenceStatus` for each location x presence combination


```r
distribution %>% select (location, presence, occurrenceStatus) %>%
  group_by_all() %>%
  summarize(records = n()) %>% 
  kable()
```



|location |presence |occurrenceStatus   | records|
|:--------|:--------|:------------------|-------:|
|Belgium  |?        |presence uncertain |      21|
|Belgium  |S        |present            |    2499|
|Brussels |?        |presence uncertain |      29|
|Brussels |M        |present            |     592|
|Brussels |S        |present            |      37|
|Flanders |?        |presence uncertain |      22|
|Flanders |M        |present            |    1200|
|Flanders |S        |present            |     777|
|Wallonia |?        |presence uncertain |      26|
|Wallonia |M        |present            |    1152|
|Wallonia |S        |present            |     461|

Populate `eventDate` only when `presence` = `S`.


```r
distribution %<>% mutate (eventDate = case_when(
  presence == "S" ~ Date,
  TRUE ~ ""))
```

### Map `occurrenceStatus` and `eventDate` for `occurrenceStatus_ALO`:


```r
occurrenceStatus_ALO %<>% mutate(occurrenceStatus = case_when(
  raw_d_n == "Ext." ~ "absent",
  raw_d_n == "Ext./Cas." ~ "present"))

occurrenceStatus_ALO %<>% mutate(eventDate = case_when(
  presence == "S" ~ paste(end_year, current_year, sep = "/")))
```

### Bind `occurrenceStatus_ALO` and `distribution` by rows:


```r
distribution %<>% bind_rows(occurrenceStatus_ALO)
```

### Term mapping

Map the source data to [Species Distribution](http://rs.gbif.org/extension/gbif/1.0/distribution.xml):
#### taxonID


```r
distribution %<>% mutate(taxonID = raw_taxonID)
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
#### threatStatus
#### establishmentMeans


```r
distribution %<>% mutate (establishmentMeans = "introduced")
```

#### appendixCITES
#### startDayOfYear
#### endDayOfYear
#### source
#### occurrenceRemarks
#### datasetID
### Post-processing

Remove the original columns:


```r
distribution %<>% select(
  -starts_with("raw_"),
  -location,-presence,
  -start_year, -end_year, - Date
)
```

Rearrange columns (order as specified in [Species Distribution](http://rs.gbif.org/extension/gbif/1.0/distribution.xml))


```r
distribution %<>% select(taxonID, locationID, locality, countryCode, occurrenceStatus, establishmentMeans, eventDate)
```

Sort on `taxonID`:


```r
distribution %<>% arrange(taxonID)
```

Preview data:


```r
kable(head(distribution))
```



|taxonID                                                     |locationID        |locality                |countryCode |occurrenceStatus |establishmentMeans |eventDate |
|:-----------------------------------------------------------|:-----------------|:-----------------------|:-----------|:----------------|:------------------|:---------|
|alien-plants-belgium:taxon:0005624db3a63ca28d63626bbe47e520 |ISO_3166-2:BE-VLG |Flemish Region          |BE          |present          |introduced         |          |
|alien-plants-belgium:taxon:0005624db3a63ca28d63626bbe47e520 |ISO_3166-2:BE-WAL |Walloon Region          |BE          |present          |introduced         |          |
|alien-plants-belgium:taxon:0005624db3a63ca28d63626bbe47e520 |ISO_3166-2:BE-BRU |Brussels-Capital Region |BE          |present          |introduced         |          |
|alien-plants-belgium:taxon:0005624db3a63ca28d63626bbe47e520 |ISO_3166-2:BE     |Belgium                 |BE          |present          |introduced         |1944/2017 |
|alien-plants-belgium:taxon:0046a7ee2325ad057382bd9fd726cef9 |ISO_3166-2:BE-VLG |Flemish Region          |BE          |present          |introduced         |          |
|alien-plants-belgium:taxon:0046a7ee2325ad057382bd9fd726cef9 |ISO_3166-2:BE-WAL |Walloon Region          |BE          |present          |introduced         |          |

Save to CSV:


```r
write.csv(distribution, file = dwc_distribution_file, na = "", row.names = FALSE, fileEncoding = "UTF-8")
```

## Create description extension

In the description extension we want to include **invasion stage** (`raw_d_n`), **native range** (`raw_origin`) and **pathway** (`raw_v_i``) information. We'll create a separate data frame for all and then combine these with union.

### Pre-processing

#### Invasion stage

Create new data frame:


```r
invasion_stage <- raw_data
```

The information for invasion stage is contained in `raw_d_n`:


```r
invasion_stage %>%
  select(raw_d_n) %>%
  group_by_all() %>%
  summarize(records = n()) %>%
  kable()
```



|raw_d_n   | records|
|:---------|-------:|
|Cas.      |    1825|
|Cas.?     |      50|
|Ext.      |      15|
|Ext./Cas. |       4|
|Ext.?     |       4|
|Inv.      |      64|
|Nat.      |     460|
|Nat.?     |      99|
|NA        |       1|

 Clean the data:


```r
invasion_stage %<>% mutate(description = recode(raw_d_n,
  "Ext.?" = "Ext.",
  "Cas.?" = "Cas.",
  "Nat.?" = "Nat.",
  .missing = ""))
```

We decided to use the unified framework for biological invasions of [Blackburn et al. 2011](http://doc.rero.ch/record/24725/files/bach_puf.pdf) for `invasion stage`.
`casual`, `naturalized` and `invasive` are terms included in this framework. However, we decided to discard the terms `naturalized` and `invasive` listed in Blackburn et al. (see trias-project/alien-fishes-checklist#6 (comment)). 
So, `naturalized` and `invasive` are replaced by `established`.
For extinct (introduced taxa that once were naturalized but that have not been confirmed in recent times) and extinct/casual species (taxa are no longer considered as naturalized but still occur as casuals), we map the most recent invasion stage (i.e. "extinct" and "casual" respectively):


```r
invasion_stage %<>% mutate(description = recode(description,
  "Cas." = "casual",
  "Inv." = "established",
  "Nat." = "established",
  "Ext." = "extinct",
  "Ext./Cas." = "casual"))
```

Show mapped values:


```r
invasion_stage %>%
  select(raw_d_n, description) %>%
  group_by_all() %>%
  summarize(records = n()) %>%
  kable()
```



|raw_d_n   |description | records|
|:---------|:-----------|-------:|
|Cas.      |casual      |    1825|
|Cas.?     |casual      |      50|
|Ext.      |extinct     |      15|
|Ext./Cas. |casual      |       4|
|Ext.?     |extinct     |       4|
|Inv.      |established |      64|
|Nat.      |established |     460|
|Nat.?     |established |      99|
|NA        |            |       1|

Create a `type` field to indicate the type of description:


```r
invasion_stage %<>% mutate(type = "invasion stage")
```

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



|value |mapped_value                | records|
|:-----|:---------------------------|-------:|
|      |                            |       1|
|AF    |Africa (WGSRPD:2)           |     641|
|AM    |pan-American                |      94|
|AS    |Asia                        |      71|
|AS-Te |temperate Asia (WGSRPD:3)   |    1057|
|AS-Tr |tropical Asia (WGSRPD:4)    |      12|
|AUS   |Australasia (WGSRPD:5)      |     117|
|Cult. |cultivated origin           |      93|
|E     |Europe (WGSRPD:1)           |    1124|
|Hybr. |hybrid origin               |      69|
|NAM   |Northern America (WGSRPD:7) |     366|
|SAM   |Southern America (WGSRPD:8) |     158|
|Trop. |Pantropical                 |      37|

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



| raw_id|raw_taxon            |raw_hybrid_formula |raw_synonym |raw_family  |raw_m_i |raw_fr |raw_mrr |raw_origin |raw_presence_fl |raw_presence_br |raw_presence_wa |raw_d_n |raw_v_i |raw_taxonrank |raw_scientificnameid                            |raw_taxonID                                                 |description               |type         |
|------:|:--------------------|:------------------|:-----------|:-----------|:-------|:------|:-------|:----------|:---------------|:---------------|:---------------|:-------|:-------|:-------------|:-----------------------------------------------|:-----------------------------------------------------------|:-------------------------|:------------|
|      1|Acanthus mollis L.   |NA                 |NA          |Acanthaceae |D       |1998   |2016    |E AF       |X               |NA              |X               |Cas.    |Hort.   |species       |http://ipni.org/urn:lsid:ipni.org:names:44892-1 |alien-plants-belgium:taxon:509ddbbaa5ecbb8d91899905cfc9491c |Europe (WGSRPD:1)         |native range |
|      1|Acanthus mollis L.   |NA                 |NA          |Acanthaceae |D       |1998   |2016    |E AF       |X               |NA              |X               |Cas.    |Hort.   |species       |http://ipni.org/urn:lsid:ipni.org:names:44892-1 |alien-plants-belgium:taxon:509ddbbaa5ecbb8d91899905cfc9491c |Africa (WGSRPD:2)         |native range |
|      2|Acanthus spinosus L. |NA                 |NA          |Acanthaceae |D       |2016   |2017    |E AF AS-Te |X               |NA              |NA              |Cas.    |Hort.   |species       |http://ipni.org/urn:lsid:ipni.org:names:44920-1 |alien-plants-belgium:taxon:a65145fd1f24f081a1931f9874af48d9 |Europe (WGSRPD:1)         |native range |
|      2|Acanthus spinosus L. |NA                 |NA          |Acanthaceae |D       |2016   |2017    |E AF AS-Te |X               |NA              |NA              |Cas.    |Hort.   |species       |http://ipni.org/urn:lsid:ipni.org:names:44920-1 |alien-plants-belgium:taxon:a65145fd1f24f081a1931f9874af48d9 |Africa (WGSRPD:2)         |native range |
|      2|Acanthus spinosus L. |NA                 |NA          |Acanthaceae |D       |2016   |2017    |E AF AS-Te |X               |NA              |NA              |Cas.    |Hort.   |species       |http://ipni.org/urn:lsid:ipni.org:names:44920-1 |alien-plants-belgium:taxon:a65145fd1f24f081a1931f9874af48d9 |temperate Asia (WGSRPD:3) |native range |
|      3|Acorus calamus L.    |NA                 |NA          |Acoraceae   |D       |1680   |N       |AS-Te      |X               |X               |X               |Nat.    |Hort.   |species       |http://ipni.org/urn:lsid:ipni.org:names:84009-1 |alien-plants-belgium:taxon:574eaf931730ba162e0226a425247660 |temperate Asia (WGSRPD:3) |native range |

#### Pathway (pathway of introduction) 


```r
pathway_desc <- raw_data
```

`pathway_desc` (pathway description) information is based on `raw_v_i`, which contains a list of introduction pathways (e.g. `Agric., wool`). We'll separate, clean, map and combine these values.

Create `pathway` from `raw_v_i`:


```r
pathway_desc %<>% mutate(pathway = raw_v_i)
```

Separate `pathway` on `,` in 4 columns:


```r
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
```

Gather pathways in a key and value column:


```r
pathway_desc %<>% gather(
  key, value,
  pathway_1, pathway_2, pathway_3, pathway_4,
  na.rm = TRUE, # Also removes records for which there is no pathway_1
  convert = FALSE
)
```

Sort on `taxonID` to see pathways in context for each record:


```r
pathway_desc %<>% arrange(raw_taxonID)
```

Show unique values:


```r
pathway_desc %>%
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
|seeds?           |
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
pathway_desc %<>% mutate(
  value = str_replace_all(value, "\\?|â€¦|\\.{3}", ""), # Strip ?, â€¦, ...
  value = str_to_lower(value), # Convert to lowercase
  value = str_trim(value) # Clean whitespace
)
```

Map values to the CBD standard::


```r
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
```

Add prefix `cbd_2014_pathway` in case there is a match with the CBD standard:


```r
pathway_desc %<>% mutate(mapped_value = case_when(
  cbd_stand != "" ~ paste ("cbd_2014_pathway", cbd_stand, sep = ":"),
  TRUE ~ ""))
```

Show mapped values:


```r
pathway_desc %>%
  select(value, mapped_value) %>%
  group_by(value, mapped_value) %>%
  summarize(records = n()) %>%
  arrange(value) %>%
  kable()
```



|value           |mapped_value                                  | records|
|:---------------|:---------------------------------------------|-------:|
|                |                                              |     165|
|…               |                                              |     380|
|agric.          |cbd_2014_pathway:escape_agriculture           |      86|
|bird seed       |cbd_2014_pathway:contaminant_seed             |       1|
|birdseed        |cbd_2014_pathway:contaminant_seed             |      31|
|bulbs           |                                              |       1|
|coconut mats    |cbd_2014_pathway:contaminant_seed             |       1|
|etc.            |                                              |       1|
|fish            |                                              |       3|
|food refuse     |cbd_2014_pathway:escape_food_bait             |      23|
|grain           |cbd_2014_pathway:contaminant_seed             |     543|
|grain (rice)    |cbd_2014_pathway:contaminant_seed             |       3|
|grass seed      |cbd_2014_pathway:contaminant_seed             |       8|
|hay             |                                              |       1|
|hort            |cbd_2014_pathway:escape_horticulture          |       2|
|hort.           |cbd_2014_pathway:escape_horticulture          |    1106|
|hybridization   |                                              |      50|
|military troops |                                              |       9|
|nurseries       |cbd_2014_pathway:contaminant_nursery          |      21|
|ore             |cbd_2014_pathway:contaminant_habitat_material |      94|
|pines           |cbd_2014_pathway:contaminant_on_plants        |       4|
|rice            |                                              |       1|
|salt            |                                              |       2|
|seeds           |cbd_2014_pathway:contaminant_seed             |      64|
|timber          |cbd_2014_pathway:contaminant_timber           |      10|
|tourists        |cbd_2014_pathway:stowaway_people_luggage      |      10|
|traffic         |                                              |       4|
|urban weed      |cbd_2014_pathway:stowaway                     |      10|
|waterfowl       |cbd_2014_pathway:contaminant_on_animals       |      14|
|wool            |cbd_2014_pathway:contaminant_on_animals       |     566|
|wool alien      |cbd_2014_pathway:contaminant_on_animals       |       1|

Drop `key`,`value` and `cbd_stand` column:


```r
pathway_desc %<>% select(-key, -value, -cbd_stand)
```

Change column name `mapped_value` to `description`:


```r
pathway_desc %<>%  rename(description = mapped_value)
```

Create a `type` field to indicate the type of description:


```r
pathway_desc %<>% mutate (type = "pathway")
```

Show pathway descriptions:


```r
pathway_desc %>% 
  select(description) %>% 
  group_by(description) %>% 
  summarize(records = n()) %>% 
  kable()
```



|description                                   | records|
|:---------------------------------------------|-------:|
|                                              |     617|
|cbd_2014_pathway:contaminant_habitat_material |      94|
|cbd_2014_pathway:contaminant_nursery          |      21|
|cbd_2014_pathway:contaminant_on_animals       |     581|
|cbd_2014_pathway:contaminant_on_plants        |       4|
|cbd_2014_pathway:contaminant_seed             |     651|
|cbd_2014_pathway:contaminant_timber           |      10|
|cbd_2014_pathway:escape_agriculture           |      86|
|cbd_2014_pathway:escape_food_bait             |      23|
|cbd_2014_pathway:escape_horticulture          |    1108|
|cbd_2014_pathway:stowaway                     |      10|
|cbd_2014_pathway:stowaway_people_luggage      |      10|

Keep only non-empty descriptions:


```r
pathway_desc %<>% filter(!is.na(description) & description != "")
```

#### Union invasion stage, native range and pathway:


```r
description_ext <- bind_rows(invasion_stage, native_range, pathway_desc)
```

### Term mapping

Map the source data to [Taxon Description](http://rs.gbif.org/extension/gbif/1.0/description.xml):

#### id


```r
description_ext %<>% mutate(taxonID = raw_taxonID)
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

Move `taxonID` to the first position:


```r
description_ext %<>% select(taxonID, everything())
```

Sort on `taxonID`:


```r
description_ext %<>% arrange(taxonID)
```

Preview data:


```r
kable(head(description_ext, 10))
```



|taxonID                                                     |description                          |type           |language |
|:-----------------------------------------------------------|:------------------------------------|:--------------|:--------|
|alien-plants-belgium:taxon:0005624db3a63ca28d63626bbe47e520 |casual                               |invasion stage |en       |
|alien-plants-belgium:taxon:0005624db3a63ca28d63626bbe47e520 |temperate Asia (WGSRPD:3)            |native range   |en       |
|alien-plants-belgium:taxon:0005624db3a63ca28d63626bbe47e520 |cbd_2014_pathway:escape_horticulture |pathway        |en       |
|alien-plants-belgium:taxon:0046a7ee2325ad057382bd9fd726cef9 |casual                               |invasion stage |en       |
|alien-plants-belgium:taxon:0046a7ee2325ad057382bd9fd726cef9 |temperate Asia (WGSRPD:3)            |native range   |en       |
|alien-plants-belgium:taxon:0046a7ee2325ad057382bd9fd726cef9 |cbd_2014_pathway:escape_horticulture |pathway        |en       |
|alien-plants-belgium:taxon:004f8d63026942a6baf80b67b6d40b98 |casual                               |invasion stage |en       |
|alien-plants-belgium:taxon:004f8d63026942a6baf80b67b6d40b98 |Northern America (WGSRPD:7)          |native range   |en       |
|alien-plants-belgium:taxon:004f8d63026942a6baf80b67b6d40b98 |cbd_2014_pathway:escape_horticulture |pathway        |en       |
|alien-plants-belgium:taxon:0057c474d19804c969845b5697f69148 |established                          |invasion stage |en       |

Save to CSV:


```r
write.csv(description_ext, file = dwc_description_file, na = "", row.names = FALSE, fileEncoding = "UTF-8")
```

## Summary

### Number of records

* Source file: 2522
* Taxon core: 2522
* Distribution extension: 6869
* Description extension: 8959

### Taxon core

Number of duplicates: 0 (should be 0)

The following numbers are expected to be the same:

* Number of records: 2522
* Number of distinct `taxonID`: 2522
* Number of distinct `scientificName`: 2522
* Number of distinct `scientificNameID`: 1707 (can contain NAs)
* Number of distinct `scientificNameID` and `NA`: 2522

Number of unique families: 154
