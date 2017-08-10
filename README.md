# Manual of the Alien Plants of Belgium

## Rationale

This repository contains the functionality to standardize the [Manual of the Alien Plants of Belgium](http://alienplantsbelgium.be/) to a [Darwin Core checklist](http://www.gbif.org/publishing-data/summary#datasetclasses) that can be harvested by [GBIF](http://www.gbif.org). It was developed for the [TrIAS project](http://trias-project.be).

## Results

* Description of the [Darwin Core mapping](src/dwc_mapping.md) (= a rendition of the [mapping script](src/dwc_mapping.R))
* Generated [Darwin Core files](data/processed)

## Repo structure

The repository structure is based on [cookiecutter-data-science](https://github.com/drivendata/cookiecutter-data-science). Files indicated with `GENERATED` should not be edited manually.

```
├── README.md         : Top-level description of the project and how to run it
├── LICENSE           : Project license
├── .gitignore        : Files and folders to be ignored by git
│
├── data
│   ├── raw           : Source data, input for mapping script
│   └── processed     : Output of mapping script GENERATED
│
└── src
    ├── dwc_mapping.R : Darwin Core mapping script, core functionality of this repository
    ├── dwc_mapping.md: Nicer rendition of mapping script, created by knitr::spin GENERATED
    └── src.Rproj     : RStudio project file
```

## Installation

### Run the code

1. Clone or fork the [repository](https://github.com/trias-project/alienplantsbelgium)
2. Open the RStudio project file: [src.Rproj](src/src.Rproj)
3. Install [any required packages](src/dwc_mapping.md#setup)
4. Run the code with `knitr::spin("dwc_mapping.R")`

### Adapt the code

1. Open [dwc_mapping.R](src/dwc_mapping.R) to adapt the Darwin Core mapping script. The code is structured so that it can be rendered as a Markdown ([see this blog post](http://deanattali.com/2015/03/24/knitrs-best-hidden-gem-spin/)):
    * Regular lines are code
    * Lines starting with `#'` are Markdown text
    * Lines starting with `#+` are code chunk options 
2. Use `knitr::spin("dwc_mapping.R")` to generate the [processed data files](data/processed) and the [Markdown rendition of the code](src/dwc_mapping.md) (as well as an ignored html version). Just running the code will generate the processed data files, but not the Markdown documentation and is therefore not recommended.

## Contributors

See [contributors on GitHub](https://github.com/trias-project/alienplantsbelgium/graphs/contributors).

## License

[MIT License](LICENSE)
