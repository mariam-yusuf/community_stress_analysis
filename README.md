# Community Stress Analysis in Washington, D.C.

## Overview
This project explores *community stress patterns in Washington, D.C.* using 311 service request data.  
Rather than focusing on emergencies (like 911 calls), this analysis uses *311 call data* to understand the everyday challenges residents face — such as sanitation issues, noise complaints, and public infrastructure concerns — as indirect indicators of community stress levels.

The goal was to identify *patterns and potential disparities* between neighborhoods, highlighting how environmental and administrative factors may reflect levels of stress or dissatisfaction among residents.

---

## Tools & Methods
This project was completed using:
- *SQL* → For data cleaning, filtering, and aggregation.  
- *Excel* → For visualization, trend analysis, and correlation checks.  
- *PowerPoint* → For presentation and interpretation of findings.

---

## Dataset
- *Source:* 311 Service Requests – Washington, D.C.  
- *Period Covered:* January 2022 – December 2023  
- *Main Features:*
  - Request type (e.g., sanitation, streetlight, noise, etc.)
  - Date and time
  - Ward (neighborhood)
  - Status (open/closed)
  - Response time

---

## Key Steps
1. *Data Cleaning (SQL):*
   - Removed duplicates and irrelevant columns.  
   - Filtered data for complete 2022–2023 records.  
   - Grouped requests by ward and complaint type.  

2. *Analysis (Excel):*
   - Calculated total requests per ward and per category.  
   - Created pivot tables and bar charts to visualize the distribution.  
   - Compared request frequency and resolution rate across wards.  
   - Identified outliers (wards with unusually high complaint volumes).

3. *Interpretation:*
   - Wards with consistently higher complaint frequencies may reflect greater public dissatisfaction or stress.
   - Delays in resolution times also correlated with higher perceived community stress.

---

## Results Summary
- *Top 3 Request Categories:* Sanitation, Infrastructure, and Noise.
- *Wards with Highest Complaint Frequency:* Wards 1 and 8.
- *Common Indicator:* Neighborhoods with more unresolved requests tended to have higher total 311 calls.
- *Insight:* Non-emergency service data can serve as a proxy indicator for urban stress and satisfaction.

---

## Limitations
- 311 data does not directly measure psychological stress — it reflects reported frustrations or system inefficiencies.  
- Reporting behavior varies between communities.  
- The dataset only covers Washington, D.C., so findings are not generalizable.

---

## Files
- community_stress.sql – SQL queries used for data cleaning and grouping.  
- community_stress_analysis.xlsx – Excel file with charts, tables, and summaries.  
- presentation_slides.pptx – Final presentation slides.  

---

## Author
*Maryam Ali*  
Data Analysis Student | Medical Graduate | Interested in Public Health & Urban Analytics  
📍 Bahrain  
📧 [your.email@example.com]  
🔗 [GitHub Portfolio](https://github.com/yourusername)

---

## How to View
You can open:
- The .sql file to review the queries used.
- The .xlsx file in Excel to explore the visualizations.
- The .pptx file to see the presentation summary.

---

This project demonstrates how publicly available administrative data can reveal subtle patterns of urban stress and inequality through accessible, non-emergency metrics.
