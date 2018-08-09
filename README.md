# nz-lead-indicators
Understanding good lead indicators for the New Zealand economy

This repository aims to understand what would be good lead indicators for the New Zealand economy.  The original motivation was controversy about the ANZ business confidence index, but the issue is of broader interest.

The following official statistics are [available monthly](https://www.stats.govt.nz/release-calendar/), within a month of their reference period:

- Electronic card transactions
- Food price index
- Transport vehicle registrations
- International travel and migration
- Overseas merchandise trade
- Building consents issued
- Livestock slaughtering statistics

these make good candidates for lead indicators.  Other non-official statistics candidates are the monthly [ANZ business outlook](https://www.anz.co.nz/resources/a/b/ab0e67804cde543883beefc0c7ad410a/business-outlook-background-information.pdf?MOD=AJPERES), and the NZIER [Quarterly Survey of Business Opinion](https://nzier.org.nz/ABout%20QSBO/) (QBSO).

The OECD business confidence data is based on monthly interpolations of the NZIER QBSO, but is more readily available as a time series than either the ANZ and NZIER series, so I will probably use this as a stand-in for business confidence in general.

Proposed method is to use all the candidate leading indicators as explanatory variables in a regression and use the lasso or other methods to identify the most effective subset of variables; or at least to get some general comparisons of them.
