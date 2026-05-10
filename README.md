# Audience Screen Engagement Tracker

## Overview

The **Audience Screen Engagement Tracker** was commissioned through the BFI Research and Statistics Fund, awarding National Lottery funding. The survey, conducted in partnership with YouGov, provides up-to-date behavioural, motivational, and attitudinal benchmark metrics on how audiences are engaging with screens and screen content, building on previous BFI audience research. Fieldwork took place during the second half of March 2025.

### Key Details
- **Fieldwork**: Second half of March 2025
- **Partner**: YouGov
- **Funder**: BFI Research and Statistics Fund (National Lottery)
- **Purpose**: Benchmark metrics on screen engagement trends across UK audiences

This repository contains all source code and data processing scripts for generating interactive HTML and static PDF reports from the survey data.

---

## Repository Structure

```
├── reports/                        # Report documents and analysis
│   ├── _metadata.yml               # Report-specific document metadata
│   └── small_screens_big_focus/    # Report folder
│       ├── index.qmd               # Main report (Quarto document)
│       └── R/                      # Data processing and visualization scripts
│           ├── data_prep.R         # Data loading and preparation
│           └── graphs.R            # Visualization generation
├── typst_output/                   # Typst templates for PDF output
│   ├── typst-template.typ
│   └── typst-show.typ
├── _quarto.yml                     # Quarto website configuration
├── _metadata.yml                   # Site-wide document metadata
├── renv/                           # R environment management (renv)
├── styles.scss / styles.css        # Website styling
├── index.qmd                       # Website landing page
├── about.qmd                       # About page
└── README.md                       # This file
```

---

## Required Software
1. **R** (≥4.5.3) - Download from [CRAN](https://cran.r-project.org/)
2. **Quarto** - Download from [quarto.org](https://quarto.org/docs/get-started/)
3. **Typst** - For PDF generation via Typst format (optional, if rendering to PDF)

---

## Setup & Installation

### 1. Clone the Repository
```bash
git clone https://github.com/BFI-RSU/aset.git
cd aset
```

### 2. Restore R Environment with renv

This project uses **renv** for reproducible R dependency management. All required packages and versions are locked in `renv.lock`.

```bash
# Open R in the project directory
R

# In R console, restore the environment:
renv::restore()

# Exit R
q()
```

This will install all required packages (readxl, dplyr, tidyr, ggplot2, plotly, quarto-bound packages, etc.) to the local `renv/` directory.

**Note**: The renv environment is isolated to this project and will not affect your system-wide R installation.

### 3. Verify Installation

To verify the setup worked correctly:
```bash
# Test R environment
R -e "library(readxl); library(dplyr); cat('Environment restored successfully!\n')"

# Verify Quarto
quarto --version

# Check available Quarto engines
quarto check
```

---

## Data

### Source Data
- **File**: Save to `data/small_screen_data_final.xlsx`
- **Format**: Excel workbook with multiple sheets
- **Contents**: Survey responses aggregated by demographic groups (age, screen type, content preferences, etc.)

### Data Preparation
Data processing is handled by R scripts in `reports/small_screens_big_focus/R/`:
- **data_prep.R**: Loads survey data from Excel, performs data cleaning and transformation (e.g., pivoting age group data)
- **graphs.R**: Generates visualizations from prepared data

These scripts are sourced by the main Quarto report document.

---

## Running Reports

### Generate HTML Report (Interactive)
```bash
quarto render reports/small_screens_big_focus/index.qmd --to html
```

Output: `_site/reports/small_screens_big_focus/index.html`

### Generate PDF Report (via Typst)
```bash
quarto render reports/small_screens_big_focus/index.qmd --to typst
```

Output: `_site/reports/small_screens_big_focus/index.pdf`

### Render Website (All Outputs)
```bash
quarto render
```

This renders the entire website, including all reports and landing pages to `_site/`.

### Preview Website in Browser
```bash
quarto preview
```

This launches a local preview server. File changes may require re-running `quarto preview`.

---

## Output Formats

### HTML (Interactive)
- **Format**: Interactive HTML website
- **Features**: Responsive design, search functionality, table of contents, interactive plots (Plotly)
- **Location**: `_site/reports/`
- **Best for**: Web viewing, exploration, sharing online

### PDF (Typst)
- **Format**: Static PDF with BFI branding
- **Features**: Professional layout with logos, page numbers, footer links
- **Location**: Generated from Typst source
- **Best for**: Printing, archival, formal distribution

### Website
- **Format**: Quarto website with multiple pages
- **Pages**:
  - **Reports** (`index.qmd`): Landing page with report listings
  - **About** (`about.qmd`): Project background and attribution
  - **Individual Reports**: Under `_site/reports/`
- **Styling**: Custom SCSS/CSS with BFI brand colours (#e50076)

---

## Reproducibility

### Ensuring Reproducibility
This repository follows best practices for research reproducibility:

1. **Locked Dependencies**: `renv.lock` ensures everyone uses identical package versions
2. **Versioned R**: Project configured for R 4.5.3
3. **Source Data Available**: See bfi.org.uk/industry-data-insights
4. **Documented Workflows**: R scripts and Quarto documents include comments explaining transformations
5. **Quarto Documents**: Combine data processing, analysis, and reporting in single, executable documents
6. **Git Version Control**: All changes tracked with full history

### Reproducing Results
To fully reproduce all outputs from scratch:

```bash
# 1. Restore environment
R -e "renv::restore()"

# 2. Render all reports
quarto render

# 3. Outputs available in _site/ directory
```

All analysis outputs (HTML, PDF, website) will be regenerated from the source data and code.

**Note**: Public users will need to download the source data from bfi.org.uk/industry-data-insights. To use the scripts in this repository without modification, the downloaded `.ods` file will need to be cleaned to remove titles and notations on each tab, tabs will need to be renamed, and the cleaned file converted to `.xlsx` format.

---

## Key Scripts

### `reports/small_screens_big_focus/R/data_prep.R`
Loads and transforms survey data:
- Reads data from `data/small_screen_data_final.xlsx`
- Performs data cleaning and validation
- Pivots demographic group columns to long format
- Creates processed datasets for visualization

### `reports/small_screens_big_focus/R/graphs.R`
Generates visualizations:
- Creates ggplot2 and Plotly charts
- Formats figures for web and print
- Handles colour schemes and accessibility

### `reports/small_screens_big_focus/index.qmd`
Main report document:
- Combines narrative text, data analysis, and visualizations
- Executes R code to generate dynamic content
- Supports rendering to both HTML and Typst (PDF) formats

---

## Configuration Files

- **`_quarto.yml`**: Website-level Quarto configuration (title, navbar, theme, CSS)
- **`_metadata.yml`**: Default document metadata (layout, page banner)
- **`reports/_metadata.yml`**: Report-specific metadata
- **`renv.lock`**: Locked R package versions and dependencies
- **`styles.scss`**: Custom SCSS styling (compiled to CSS)

---

## Troubleshooting

### Issue: renv restore fails
```bash
# Clear renv cache and retry
R -e "renv::clean()"
R -e "renv::restore()"
```

### Issue: Packages not found when rendering
Ensure renv environment is activated:
```bash
# Check active R library path
R -e ".libPaths()"

# Should show renv/library/... paths first
```

### Issue: Quarto render fails
```bash
# Verify Quarto installation and configuration
quarto check

# Check for missing R packages
R -e "renv::status()"
R -e "renv::restore()"
```

---

## Contributing

To contribute improvements, bug fixes, or enhancements:

1. Create a new branch from `main`
2. Make your changes
3. Test by running `quarto render` to ensure all outputs build successfully
4. Submit a pull request with clear description of changes

---

## Citation

If you use data or findings from this research, please cite as:

> British Film Institute (BFI). (2026). Audience Screen Engagement Tracker. Retrieved from https://github.com/BFI-RSU/aset

---

## License

[License information to come]

---

## Contact & Attribution

- **Researchers**: Paul McEvoy and Brian Tarran
- **Funder**: BFI Research and Statistics Fund (National Lottery)
- **Partner**: YouGov
- **Organization**: British Film Institute Research and Statistics Unit
- **Website**: [bfi.org.uk/industry-data-insights](https://www.bfi.org.uk/industry-data-insights)

For questions or inquiries, please contact the [rsu-enquiries@bfi.org.uk](mailto:rsu-enquiries@bfi.org.uk).