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

Only manually downloaded datasets are included in the Git repository; other datasets (eg electronic card transactions) are dynamically downloaded by the relevant scripts in `./grooming/`


