# COVID-19 Cases in Mexico — Automated Data Analysis Report

**Group 7 — DATA 550 Final Project**

## Team

| Name | Role | Responsibility |
|------|------|----------------|
| Juncheng Tong | Team Lead | Infrastructure (config, Makefile, utils, report); repo management |
| Lidong Yu | Coder A | Demographics and comorbidity profile analysis |
| Xiyuan Zhao | Coder B | COVID severity and healthcare utilization analysis |
| Yuqing Huang | Coder C | Clinical outcomes analysis (mortality, ICU, intubation) |

## Data

The dataset (`data/covid_sub.csv`) contains ~210,000 anonymized COVID-19 patient records from Mexico, including demographics, comorbidities, and clinical outcomes. Source: [Mexican government open data](https://datos.gob.mx/busca/dataset/informacion-referente-a-casos-covid-19-en-mexico).

## How to Build the Report

### 1. Synchronize the package environment

This project uses `renv` for reproducible package management.

```bash
make install
```

Or in R:

```r
renv::restore()
```

### 2. Generate the report

```bash
make          # runs all coder scripts + renders report
```

The final report will be at `report/final_report.html`.

You can also build individual components:

```bash
make coder_a  # demographics and comorbidity (Lidong Yu)
make coder_b  # severity and healthcare utilization (Xiyuan Zhao)
make coder_c  # clinical outcomes (Yuqing Huang)
make report   # render final HTML report (requires all coder outputs)
make clean    # remove all generated outputs
```

## Customizing the Report

Edit `config/config.yml` to change the scope of the analysis **without modifying any code**:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `data_file` | Path to input CSV | `"data/covid_sub.csv"` |
| `age_range` | Min and max age to include | `[0, 100]` |
| `sex_filter` | `"all"`, `"male"`, or `"female"` | `"all"` |
| `confirmed_only` | Restrict to confirmed COVID (classification 1-3) | `false` |
| `report_title` | Title of the rendered report | `"COVID-19 Cases in Mexico..."` |

Example: to analyze only elderly female confirmed cases, set:

```yaml
age_range: [60, 100]
sex_filter: "female"
confirmed_only: true
```

Then re-run `make clean && make`.

## Repository Structure

```
.
├── Makefile                          # Build automation
├── README.md                         # This file
├── renv.lock                         # Package versions
├── renv/                             # renv library
├── config/
│   └── config.yml                    # Report parameters
├── data/
│   └── covid_sub.csv                 # Raw data
├── code/
│   ├── utils.R                       # Shared helper functions
│   ├── coder_a_demographics.R        # Coder A script
│   ├── coder_b_severity.R            # Coder B script
│   ├── coder_c_outcomes.R            # Coder C script
│   └── render_report.R               # Report rendering script
├── output/
│   ├── coder_a/                      # Tables and figures from Coder A
│   ├── coder_b/                      # Tables and figures from Coder B
│   └── coder_c/                      # Tables and figures from Coder C
└── report/
    ├── final_report.Rmd              # Parameterized R Markdown report
    └── final_report.html             # Rendered report (generated)
```

## Tables and Figures

| Output | Script | Description |
|--------|--------|-------------|
| Table 1 | `coder_a_demographics.R` | Patient demographics summary |
| Figure 1 | `coder_a_demographics.R` | Age distribution histogram by sex |
| Figure 2 | `coder_a_demographics.R` | Comorbidity prevalence bar chart |
| Table 2 | `coder_b_severity.R` | COVID classification distribution |
| Figure 3 | `coder_b_severity.R` | Patient type by age group |
| Figure 4 | `coder_b_severity.R` | Medical unit type distribution |
| Table 3 | `coder_c_outcomes.R` | Outcome summary (died, intubated, ICU) |
| Figure 5 | `coder_c_outcomes.R` | Mortality rate by age group |
| Figure 6 | `coder_c_outcomes.R` | Outcomes by number of comorbidities |
