# nz-lead-indicators

## Data provenance

`./data/data-provenance.md`

When the project has been run folder contains the following data:


|  File         | Source            |  Description | How downloaded |
|---------------|-------------------|--------------|------|
|`DP_LIVE_01082018094138947.csv` | NZIER via OECD | Business confidence | Manual from https://data.oecd.org/leadind/business-confidence-index-bci.htm |
|`SNE445001_20180801_075329_92.csv` | Stats NZ | Quarterly GDP, production measure, chain volume | Manual from http://archive.stats.govt.nz/infoshare/?url=/infoshare/ |
| `ect-latest.csv` | Stats NZ | Electronic Card Transactions (monthly) | `./grooming/08-electronic-card-transactions.R` |
| `Building consents by region (Quarterly).csv` | Stats NZ | Building consents | `./grooming/09-building-consents.R` |
| `food-price-index-DATE-index-numbers-csv-tables.csv` | Stats NZ | Food price index | `./grooming/10-food-price-index.R` |
| `ITM330702_20180809_062851_36.csv`| Stats NZ | Total visitor arrivals | Manual from Infoshare |
| `TPT052602_20180809_093759_53.csv` | Stats NZ | Vehicles registered (cars and commercial) | Manual from Infoshare|
| `EXP476601_20180809_095811_58.csv` | Stats NZ | Merchandise goods exports | Manual from Infoshare |
| `hb1-monthly.xlsx` and `hb1-monthly-1973-1998.xlsx` | Reserve Bank of NZ | exchange rates | `./grooming/20-trade-weighted-index.R`|
| `LSS154702_20180810_120736_86.csv` | Stats NZ | Livestock slaughted | Manual from Infoshare |
| `ind_data.rda` | Built in this project | Consolidated dataset, in three tibbles | `./integrate.R` |


Only manually downloaded datasets are included in the Git repository; other datasets (eg electronic card transactions) are dynamically downloaded by the relevant scripts in `./grooming/`


