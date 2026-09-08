# Data Source and Reproduction Guide

This directory documents the source, analytical scope, data grain, preparation workflow, and refresh requirements for the **DataCo Supply Chain & E-commerce Analytics** portfolio project.

> Raw source files are intentionally not redistributed in this repository. Download the dataset from an authorized source and follow the steps below to reproduce the analytical environment.

## 1. Dataset

**Dataset name:** DataCo SMART Supply Chain for Big Data Analysis  
**Authors:** Fabian Constante, Fernando Silva, and António Pereira  
**Published:** 2019  
**Version:** 5  
**DOI:** [10.17632/8gx2fvg2k6.5](https://doi.org/10.17632/8gx2fvg2k6.5)  
**Primary source:** [Mendeley Data](https://data.mendeley.com/datasets/8gx2fvg2k6/5)  
**Alternative access:** [Kaggle dataset page](https://www.kaggle.com/datasets/shashwatwork/dataco-smart-supply-chain-for-big-data-analysis)

The project uses the main structured supply-chain file, commonly distributed as `DataCoSupplyChainDataset.csv`. The dataset contains order, order-item, customer, product, geography, sales, profit, shipping, and delivery fields.

The repository license, if present, applies only to the original code and documentation created for this project. Dataset ownership and redistribution terms remain with the original data provider.

## 2. Reporting Scope

The observed reporting period is:

| Item | Value |
|---|---|
| First order date | 2015-01-01 |
| Last order date | 2018-01-31 |
| Observed calendar months | 37 |
| Main reporting scope | Excludes `CANCELED` and `SUSPECTED_FRAUD` orders |
| Audit scope | Includes all order statuses |

The main reporting scope is referred to as **Scope B** throughout the project. The all-status audit population is referred to as **Scope A**.

Scope B is a reporting decision and must not be described as a set of “completed orders.” Order statuses other than `CANCELED` and `SUSPECTED_FRAUD` may still represent different operational states.

January 2018 is treated as a boundary period. Its apparent movement should not be interpreted as a complete-month increase or decline without confirming data completeness.

## 3. Analytical Grain

The raw dataset is stored at **order-item grain**:

> One row represents one product line within an order.

An order containing three products may therefore appear on three rows. Counting raw rows would count order items, not distinct orders.

To preserve correct calculations, the project creates two analytical layers:

| Analytical layer | Grain | Primary use |
|---|---|---|
| Order-level view | One row per `order_id` | Orders, customers, average order value, shipping, and delivery metrics |
| Order-item-level view | One row per `order_item_id` | Product, category, units, sales, discount, and profit analysis |

The Power BI model follows the same design:

- `FactOrder` stores order-level measures.
- `FactOrderItem` stores order-item-level measures.
- Shared dimensions filter the fact tables through one-to-many, single-direction relationships where applicable.
- The two fact tables are not directly related.

## 4. Validated Scope B Baseline

The following no-filter values are used to reconcile PostgreSQL results with Power BI:

| KPI | Expected value |
|---|---:|
| Total Orders | 62,897 |
| Total Customers | 20,261 |
| Net Sales | 31,644,664.75 |
| Total Profit | 3,806,420.63 |
| Profit Margin | 12.03% |
| Average Order Value | 503.12 |
| Late Orders | 36,048 |
| Evaluable Delivery Orders | 62,897 |
| Late Delivery Rate | 57.31% |
| Last Data Date | 2018-01-31 |

`Net Sales` and `Profit` are analytical fields derived from the supplied dataset. Because the source does not specify a verified currency, this project does not label monetary values as USD or any other currency.

Profit Margin is calculated as:

```text
SUM(Profit) / SUM(Net Sales)
```

It is not calculated by averaging row-level profit margins.

## 5. Required Software

To reproduce the project, install:

- PostgreSQL.
- pgAdmin 4 or another PostgreSQL client.
- Microsoft Power BI Desktop.
- A spreadsheet or text editor capable of inspecting CSV files.
- Git or GitHub Desktop, if the repository will be cloned and versioned locally.

No specific PostgreSQL database name is required. The SQL scripts depend on the table, column, view, and schema identifiers defined inside the project files.

## 6. Repository Files

Run and review the SQL files in the following logical order:

| Order | File | Purpose |
|---:|---|---|
| 1 | `01_profiling_and_grain.sql` | Profiles the source and validates row grain, identifiers, and key relationships |
| 2 | `02_data_quality_checks.sql` | Checks missing values, duplicates, dates, categories, and abnormal values |
| 3 | `03_financial_validation.sql` | Validates sales, discount, profit, and related financial fields |
| 4 | `04_cleaning_transformation.sql` | Applies documented cleaning and transformation rules |
| 5 | `05_create_analysis_views.sql` | Creates order-level and order-item-level analytical views |
| 6 | `06_business_analysis_sales_product.sql` | Analyzes sales, time, category, product, profitability, and concentration |
| 7 | `07_business_analysis_customer_market_delivery.sql` | Analyzes customers, segments, markets, regions, shipping modes, and delivery |
| 8 | `08_final_validation_and_dashboard_dataset.sql` | Performs final reconciliation and prepares dashboard-facing outputs, when included |

If file 8 is not present in the repository, use the final validation queries documented in the existing SQL and quality-assurance files. Do not create an empty script solely to preserve numbering.

## 7. Reproduction Workflow

### Step 1 — Download and inspect the source

1. Download the dataset from Mendeley Data or the linked Kaggle page.
2. Locate `DataCoSupplyChainDataset.csv`.
3. Keep an unchanged copy of the downloaded file outside the repository.
4. Confirm that the file opens correctly and that the header row is present.
5. Preserve the original column names until the transformation rules are applied.

Expected output: an unchanged local copy of the source CSV.

### Step 2 — Create a PostgreSQL database

Create a local PostgreSQL database using pgAdmin 4 or another PostgreSQL client. The database name is a local configuration choice; for example:

```text
dataco_analytics
```

Record the PostgreSQL server, port, database, and schema used locally. Do not commit passwords, tokens, or connection strings containing credentials.

Expected output: an empty PostgreSQL database available for the project.

### Step 3 — Create and load the source table

Use the table definition and identifiers expected by the SQL scripts. Import the CSV through pgAdmin 4 as follows:

1. Create the source table with columns that match the source file and the data types established during profiling.
2. In pgAdmin 4, right-click the source table.
3. Select **Import/Export Data**.
4. Choose **Import**.
5. Select `DataCoSupplyChainDataset.csv`.
6. Set the format to `csv`.
7. Enable **Header**.
8. Confirm the delimiter and text encoding used by the downloaded file.
9. Complete the import.
10. Compare the imported row count with the source file before continuing.

If the repository contains a dedicated table-creation or loading script, use that script instead and follow its documented order.

Expected output: a populated raw source table whose row count and columns match the downloaded file.

### Step 4 — Run profiling and quality checks

Run:

```text
sql/01_profiling_and_grain.sql
sql/02_data_quality_checks.sql
sql/03_financial_validation.sql
```

Review the result sets rather than treating these files as unattended setup scripts. They contain diagnostic queries used to confirm grain, keys, data quality, dates, and financial logic.

Expected output: documented evidence that the source structure and analytical assumptions are understood before transformation.

### Step 5 — Apply transformations and create analytical views

Run:

```text
sql/04_cleaning_transformation.sql
sql/05_create_analysis_views.sql
```

The final views should provide separate order-level and order-item-level datasets. The project uses the Scope B variants of these layers for its main reporting results and retains the all-status variants for audit and sensitivity analysis.

Before proceeding, confirm that:

- the order-level output contains one row per `order_id`;
- the order-item-level output contains one row per `order_item_id`;
- `CANCELED` and `SUSPECTED_FRAUD` are excluded only from the Scope B outputs;
- aggregate Net Sales and Profit reconcile across the appropriate analytical layers.

Expected output: validated analytical views ready for business analysis and Power BI.

### Step 6 — Run business analysis

Run:

```text
sql/06_business_analysis_sales_product.sql
sql/07_business_analysis_customer_market_delivery.sql
```

If provided, finish with:

```text
sql/08_final_validation_and_dashboard_dataset.sql
```

Compare the final no-filter results with the validated baseline in Section 4. Investigate any mismatch before opening or refreshing the Power BI report.

Expected output: reproducible KPI results and analysis tables supporting the documented findings.

### Step 7 — Connect Power BI

1. Open the project `.pbix` file in Power BI Desktop.
2. Select **Home → Transform data → Data source settings**.
3. Select the PostgreSQL source and choose **Change Source**.
4. Enter the local PostgreSQL server and database.
5. Authenticate using the local PostgreSQL credentials.
6. Confirm that each Power Query references an existing analytical view.
7. Select **Close & Apply**.
8. Refresh the model.
9. Clear optional report filters.
10. Compare the report with the Scope B baseline in Section 4 or the hidden `00_QA` page, when available.

Expected output: a refreshed Power BI model that reproduces the validated Scope B baseline.

## 8. Validation Checklist

Before accepting the reproduced output, confirm:

- [ ] The raw table row count matches the downloaded source file.
- [ ] `order_item_id` is unique at the order-item layer.
- [ ] `order_id` is unique at the order layer.
- [ ] Scope B excludes only `CANCELED` and `SUSPECTED_FRAUD`.
- [ ] Total Orders equals 62,897 with no optional filters.
- [ ] Total Customers equals 20,261 with no optional filters.
- [ ] Net Sales equals 31,644,664.75 with no optional filters.
- [ ] Total Profit equals 3,806,420.63 with no optional filters.
- [ ] Late Orders equals 36,048 with no optional filters.
- [ ] Late Delivery Rate equals 57.31% with no optional filters.
- [ ] The last observed order date is 2018-01-31.
- [ ] Product and category metrics use the order-item layer.
- [ ] Order, customer, and delivery metrics use the order layer.
- [ ] Power BI and PostgreSQL return the same baseline values.

## 9. Data Access and Redistribution

The raw dataset is not included in this repository. Obtain it directly from the original source and review the source terms before using or redistributing it.

The Power BI file may contain imported data and connection metadata. Its inclusion in a public repository should therefore be evaluated separately from the decision to exclude the raw CSV.

Credentials and machine-specific connection details must remain outside version control. A public project should contain only the source links, documented setup steps, SQL scripts, screenshots, and files that are appropriate to share.

## 10. Known Limitations

- The dataset is historical and ends on 2018-01-31.
- January 2018 may be a boundary period rather than a comparable complete month.
- No verified currency is supplied for the monetary fields.
- Net Sales and Profit are analytical dataset fields, not audited accounting values.
- No official service-level target was provided for delivery performance.
- Delivery patterns indicate associations and investigation priorities; they do not establish root causes.
- Repeat purchasing within the observed period does not by itself measure customer loyalty or Customer Lifetime Value.
- Carrier, warehouse, route, inventory, return, acquisition, and detailed cost data would be required for deeper operational or causal analysis.

## 11. Citation

When referencing the dataset, use the citation supplied by the source:

> Constante, Fabian; Silva, Fernando; Pereira, António (2019), “DataCo SMART Supply Chain for Big Data Analysis,” Mendeley Data, V5, doi: 10.17632/8gx2fvg2k6.5.

## 12. Related Project Documentation

- [`../README.md`](../README.md) — project overview, dashboard previews, findings, and recommendations.
- [`../docs/01_data_understanding.md`](../docs/01_data_understanding.md) — source structure and business interpretation.
- [`../docs/02_data_quality_report.md`](../docs/02_data_quality_report.md) — detailed data-quality findings.
- [`../docs/03_financial_field_validation.md`](../docs/03_financial_field_validation.md) — validation of sales, discount, and profit fields.
- [`../docs/04_kpi_dictionary.md`](../docs/04_kpi_dictionary.md) — KPI definitions and calculation rules.
- [`../docs/06_analysis_model_validation.md`](../docs/06_analysis_model_validation.md) — validation of analytical layers and model decisions.
- [`../docs/09_final_insights_recommendations.md`](../docs/09_final_insights_recommendations.md) — final insights, recommendations, and limitations.

---

For result comparison, always begin from Scope B with no optional report filters applied.
