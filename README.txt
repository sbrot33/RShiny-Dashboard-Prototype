# RShiny Dashboard Prototype: Health of Canadians Report

About:
This RShiny app was built to explore a dashboard option for disseminating the information in the Health of Canadians Report (to be released 2023) to the Canadian public. It was built using data on health indicators from a CODR table on the StatCan website, similar to the data that would be connected to this release.
This dashboard allows for 3 types of data visulization: bar graphs, cloropleth map, and line graph (for trends over time). Each type of visualization is located in its own tab, which can be selected from the top menu bar.

How to install: 
This dashboard is contained within one file, app.R. The file can be opened in RStudio, and the associated data sets (perceived_health.csv and provinces.geojson) must be saved in the specified file format and located in the same folder as the associated app.R file. 
The dataset can be found at https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=1310009601 and downloaded with the following customizations (Upon selecting "Add/remove data"):
- Geography: "Select all items"
- Age group: "Select all items"
- Sex: "Select all items"
- Indicators: "Perceived health, very good or excellent"
- Characteristics: "Percent AND Low 95% confidence interval, percent AND High 95% confidence interval, percent"
- Reference period: "From 2015 to 2021"
- Download options: "Download selected data (for database loading)."

How to use:
To run this dashboard, open file app.R and click "Run app". Selections can be made on each tab (tabs located on top) to adjust the data visualization, and clicking the action button below the selections will reload the figure with your specifications.
This dashboard is meant to be used as a prototype, and a final version would contain more than one indicator.

Technologies used: 
This project was written using R 4.1.3 and RStudio. It uses the following libraries: shiny (version 1.7.4), bslib, dplyr, tidyr, ggplot2, geojsonio, leaflet, leaflet.extras, sp, and dygraphs.
