✈️ **Airline Flight Bookings Analytics (Python + SQL Project)**

End-to-end airline analytics project: 7 raw CSV files cleaned in Python (pandas), loaded into MySQL, and analyzed with 25 SQL queries covering revenue, fare classes, airports, routes, scheduling and passenger check-in.
This project transforms raw booking data into a validated relational database and actionable business insights, presented in a 28-slide deck.

## 📊 Project Overview
This analysis covers airport, aircraft, flight, booking, ticket and fare-segment data across a relational MySQL database. Data is first cleaned and validated in Python, then explored with SQL concepts ranging from basic filtering to window functions.

**Scale:** 7 tables · 17,510 rows · 900 flights · 15 airports · 3,000 bookings · 4,805 tickets · 6,258 flight segments (all from 2025)

**Key Focus Areas**
- 💰 Revenue & fare-class analysis
- 🛫 Airport & route performance
- 📅 Flight scheduling, duration & status trends
- 🧳 Booking patterns & passenger check-in behavior
- 🧹 Data cleaning & data-quality auditing

---

## 🧭 Project Pipeline

| Step | Stage | Details |
|---|---|---|
| 1 | Raw data | 7 CSV files from the Kaggle airline bookings dataset |
| 2 | Python cleaning | Jupyter + pandas: profiling, duplicates, missing values, data types, key checks |
| 3 | Export | 7 validated CSV files in `data/cleaned/` |
| 4 | MySQL import | Tables, primary/foreign keys, `LOAD DATA LOCAL INFILE` with `NULLIF` for blanks |
| 5 | SQL analysis | 25 queries: filtering to window functions |
| 6 | Insights | Charts, findings and 28-slide presentation |

---

## 🗂️ Database Tables

| Table | Rows | Purpose |
|---|---|---|
| `airports` | 15 | Airport code, name, city, country, timezone |
| `airplanes` | 10 | Aircraft model, range, speed, seat capacity |
| `seats` | 2,522 | Seat map and fare class per aircraft |
| `flights` | 900 | Scheduled and actual times, route, status |
| `bookings` | 3,000 | Booking reference, date, total amount |
| `tickets` | 4,805 | Passenger tickets per booking, outbound flag |
| `segments` | 6,258 | Ticket-to-flight legs with fare class, price and boarding details |

The `segments` table acts as the central transactional entity. It links `tickets` (and through them `bookings`) to `flights`, which connect to `airports` (departure and arrival) and `airplanes`, which own the `seats`. `seats` and `segments` use composite primary keys. The MySQL Workbench EER diagram is in `images/eer_diagram.png`.

---

## 🧹 Data Cleaning (Python)

Each file was cleaned in its own Jupyter notebook using the same eight steps:

| Step | Action |
|---|---|
| 1. Load | `read_csv`; IDs read as text so ticket numbers are never altered |
| 2. Profile | Shape, data types, null counts and duplicates before any change |
| 3. Standardize | Column names, trimmed spaces, text case |
| 4. Missing values | Meaningful blanks kept as `NULL`; nothing invented |
| 5. Duplicates | Full-row and primary-key duplicates checked |
| 6. Data types | Text to datetime; `boarding_no` from `1.0` to whole number `1` |
| 7. Validity & outliers | Format checks, valid ranges, IQR outliers by fare class |
| 8. Integrity | Every foreign key verified against its parent table |

**Result:** 17,510 rows checked: **0 duplicates, 0 orphan keys, 0 invalid values, 1 column type corrected.**

| Table | Missing values | Action taken |
|---|---|---|
| `airports` | 0 | Codes validated (3 letters) |
| `airplanes` | 0 | Ranges checked; codes read as text |
| `seats` | 0 | Composite key and fare classes validated |
| `flights` | 456 actual-time blanks | Kept as `NULL` (flights not yet operated) |
| `bookings` | 0 | Amounts set to 2 decimals; no outliers |
| `tickets` | 0 | 115 names with titles (MD, PhD) kept; `outbound` set to 1/0 |
| `segments` | 3,175 check-in blanks | `boarding_no` fixed to integer; blanks kept as `NULL` |

---

## 🔍 Query Categories

| Category | Queries | SQL Concept | Insight |
|---|---|---|---|
| Filtering & Basic Queries | Q1–Q3, Q14 | `WHERE`, `LIKE`, `ORDER BY`, `LIMIT` | 1,509 bookings above ₹50,000; top-10 fares; passengers starting with "A" |
| Aggregations & Grouping | Q4–Q6, Q17 | `GROUP BY`, `HAVING` | ₹62.37M revenue; revenue per fare class; monthly booking amounts |
| Functions & Transformation | Q7–Q10, Q16 | String/date functions, `CASE WHEN` | Price bands (Low/Medium/High); flights per month; check-in status |
| Joins | Q11–Q13, Q15 | `JOIN` | Revenue per departure airport; top 5 routes by revenue |
| Subqueries | Q18–Q20 | Nested `SELECT` | Bookings, aircraft and segments above average benchmarks |
| CTE | Q21 | `WITH` | Airports generating over ₹1,000,000 in revenue |
| Views | Q22 | `CREATE VIEW` | `high_value_bookings` (amount ₹50,000 and above) |
| Window Functions | Q23–Q25 | `RANK()`, `LAG()`, `ROW_NUMBER()` | Fare ranking per flight; previous-leg price; flight sequence per aircraft |

---

## 📈 Key Findings

| Metric | Result |
|---|---|
| Total segment revenue | **₹62.37M** across 6,258 segments (average ₹9,966.61) |
| Business class | **10.6% of segments, 39.7% of revenue** (about 6.5x the Economy fare) |
| Top airport by revenue | **Bengaluru (BLR): ₹5.60M**; lowest is New York JFK at ₹2.82M |
| Top route by revenue | **Frankfurt to Singapore (FRA to SIN): ₹778,367** |
| Busiest departure airport | Paris CDG with 79 departures |
| Busiest / quietest month | December (95 flights) / January (57 flights) |
| Check-in rate | 3,083 of 6,258 segments (49.3%) have an assigned seat |

| Fare class | Segments | Revenue | Share of revenue | Avg fare |
|---|---|---|---|---|
| Economy | 4,653 | ₹26.70M | 42.8% | ₹5,739 |
| Business | 662 | ₹24.73M | 39.7% | ₹37,357 |
| Comfort | 943 | ₹10.94M | 17.5% | ₹11,597 |

---

## ⚠️ Data Quality Findings

A cross-table audit found inconsistencies in the source data. These were **reported, not overwritten**.

| Finding | Affected | How handled |
|---|---|---|
| Booking `total_amount` differs from sum of segment prices | 3,000 of 3,000 bookings | Revenue uses `segments.price` |
| Seat map larger than aircraft `seat_capacity` | 10 of 10 aircraft | Capacity taken from `airplanes` |
| Paid fare class differs from assigned seat class | 1,451 of 3,083 seats (47.1%) | Fare class taken from `segments` |
| Delayed / On Time flights with no actual times | 124 of 900 flights | Kept as recorded |
| Same seat assigned twice on one flight | 59 of 3,083 seats | Kept; noted as a limitation |

> **Note on Q24:** `LAG(price) OVER (PARTITION BY ticket_no)` has no `ORDER BY`, so "previous segment" is not guaranteed. Add an `ORDER BY` (for example by scheduled departure) for a repeatable result.

---

## 🛠️ Tech Stack

| Component | Details |
|---|---|
| Data Cleaning | Python, pandas |
| Notebook Environment | Jupyter Notebook |
| Database | MySQL (8.0+ recommended) |
| Query Environment | MySQL Workbench |
| Concepts Used | Filtering, Aggregations, Group By/Having, String & Date Functions, CASE, Joins, Subqueries, CTEs, Views, Window Functions |

## 📁 Repository Structure

```
├── data/
│   ├── raw/                       # 7 original CSV files
│   └── cleaned/                   # 7 cleaned CSV files
├── notebooks/                     # One cleaning notebook per table
├── sql/
│   ├── 01_table_setup.sql         # Table creation, keys and data loading
│   └── 02_queries.sql             # All 25 SQL queries
├── images/
│   └── eer_diagram.png            # MySQL Workbench EER diagram
├── presentation/
│   ├── SQL_Airline_Flight_Bookings_Analysis.pdf
│   └── SQL_Airline_Flight_Bookings_Analysis.pptx
└── README.md
```

## ✨ Features

- ✅ Full Python cleaning pipeline: 8 steps applied to all 7 files
- ✅ 25 queries spanning 8 SQL concept groups
- ✅ 7-table relational schema with primary/foreign keys and EER diagram
- ✅ Revenue, fare-class, airport and route analysis
- ✅ Window functions for ranking and sequencing
- ✅ Reusable view for high-value bookings
- ✅ Cross-table data-quality audit with documented limitations
- ✅ 28-slide presentation (PDF + PPTX)

7. Review the PPTX or PDF in `presentation/` for a walkthrough of the objectives, data cleaning, database design and insights

---

👩‍💻 **Author:** Ananya Gadodia · Data Analytics · [@gadodiaananya-dev](https://github.com/gadodiaananya-dev)
