# Load packages ----
library(shiny)
library(bslib)
library(dplyr)
library(tidyr)
library(ggplot2)
library(geojsonio)
library(leaflet)
library(leaflet.extras)
library(sp)
library(dygraphs)


# Load and shape data ----

perceived_health <- read.csv("C:/Users/brotsam/Documents/R/RShiny_Dashboard _1/perceived_health.csv") # Loading in data from health indicators CODR table
df <- perceived_health %>% select(-DGUID, -(UOM:COORDINATE), -(STATUS:DECIMALS)) # Data cleaning, removing unnecessary columns
df[df == 'Both sexes'] <- 'Both sexes surveyed' # Changing category name to match dropdown menu, more specific to increase inclusivity
df_can0 <- df[df[2] == "Canada (excluding territories)",] # Creating dataset with only total Canada values, not specific to provinces
df_can <- pivot_wider(df_can0, names_from = 'Characteristics', values_from = "VALUE") # Changing format of dataset for displaying table, includes confidence interval columns

# Loading spatial data frame (for interactive map) ---
spdf <- geojson_read("C:/Users/brotsam/Documents/R/RShiny_Dashboard _1/provinces.geojson",  what = "sp")
spdf@data$NAME[4] <- 'Newfoundland and Labrador' # Changing '&' to 'and' to match original dataset for joining 

# Data preparation for line graph ---
vec_line <- perceived_health[1:7,]
df_line <- data.frame(vec_line[1], vec_line$VALUE)

# Merge necessary data for leaflet map -----
spdf@data <- data.frame(spdf@data, df[match(spdf@data[,'NAME'], df[,'GEO']),])

# Create color palette for map ---
mypalette <- colorNumeric(palette="Greens", domain=spdf@data$VALUE, na.color="transparent")
mypalette(c(spdf@data$VALUE))

# Define user interface (ui) ---
ui <- fluidPage(
  navbarPage(strong("Health of Canadians Report"), theme = bs_theme(version = 4, bootswatch = "cosmo"),
                tabPanel("Plot data",
                         sidebarLayout(
                           sidebarPanel(
                             helpText(em("Create customized plots with information from the Health of Canadians Report.")),
                             br(),
                             
                             selectInput("var", 
                                         label = "Health Indicator:",
                                         choices = list("Perceived health, very good or excellent",
                                                        "[More indicators here]"),
                                         selected = "Perceived health, very good or excellent"),
                             
                             selectInput("sex",
                                         label = "Sex(es):",
                                         choices = list("Both sexes surveyed",
                                                        "Females",
                                                        "Males"),
                                         selected = "Both sexes surveyed"),
                             
                             checkboxGroupInput("age", 
                                                label = "Age(s):",
                                                choices = list("Total, 12 years and over" = 1,
                                                               "12 to 17 years" = 2,
                                                               "18 to 34 years" = 3,
                                                               "35 to 49 years" = 4,
                                                               "50 to 64 years" = 5,
                                                               "65 years and over" = 6),
                                                selected = 1),
                             selectInput("year",
                                                label = "Select year:",
                                                choices = list("2021",
                                                               "2020",
                                                               "2019",
                                                               "2018",
                                                               "2017",
                                                               "2016",
                                                               "2015"),
                                                selected = "2021"),
                             
                             
                             
                             actionButton("click", "Create")
                           ),
                           
                           mainPanel(
                             plotOutput("bar"),
                             h4("View data table below:"),
                             tableOutput("table")
                           ),
                           
                           position = c("left", "right"),
                           
                           fluid = TRUE)
                ),
                tabPanel("Interactive Map",
                         sidebarLayout(
                           sidebarPanel(
                             helpText(em("Create customized plots with information from the Health of Canadaians Report.")),
                             br(),
                             
                             selectInput("var", 
                                         label = "Health Indicator:",
                                         choices = list("Perceived health, very good or excellent",
                                                        "[More indicators here]")),
                             actionButton("clickMap", "Reload map")
                           ),
                          mainPanel(
                            leafletOutput("map",height = 600, width = "100%")),
                          
                          position = c("left", "right"),
                          
                          fluid = TRUE
                         )
                         
                ),
             
                tabPanel("View Trends",
                         sidebarLayout(
                           sidebarPanel(
                             helpText(em("Visualize trends with information from the Health of Canadians Report.")),
                             br(),
                             
                             selectInput("var", 
                                         label = "Health Indicator:",
                                         choices = list("Perceived health, very good or excellent",
                                                        "[More indicators here]")),
                             
                             sliderInput("date", 
                                         label = "Date range of interest:",
                                         min = 2015, max = 2021, value = c(2015, 2021),
                                         step = 1, sep = ""),  ## input$date will be a vector containing 2 integer values
                             actionButton("clickTrend", "Create")
                           ),
                           mainPanel(
                             dygraphOutput("trend"))
                           
                         ))
             )
  )

# Define server logic ----
server <- function(input, output) {
  observeEvent(shinyApp(ui = ui, server = server), {
    
    # The following lines select the input value selected by the user and subset the data set into these categories
    df2 <- df_can[df_can[1] == input$year, ]
    df1 <- df2[df2[['Indicators']] == input$var, ]
    df0 <- df1[df1$Sex == input$sex, ]
  
    age <- strsplit(input$age, "", fixed = FALSE) # Splitting the selection list into indiv. numbers associated with ages
    age_int <- as.integer(age) # Converting to integer, can use these to select rows
    
    plot1 <- as.matrix(df0[age_int, 6]) # Creates a matrix based on selected ages, to be plotted
    
    # 
    output$bar <- renderPlot({
      barplot(plot1, ylim = range(0, max(plot1)+7), beside = TRUE, 
              legend.text = as.matrix(df0[age_int, 3]), args.legend = list(x = "bottomright"),
              main = "Perceived health, very good or excellent")
      grid(nx = 0, ny = 10, col = "grey")
      abline(h = df0[1, 6], col = "red") ## The total population line, horizontal
      })
    
    output$table <- renderTable({
      df0
    })
  })
  
  # Creating a reactive function for the "click" button
  observeEvent(input$click,{
    df22 <- df_can[df_can[1] == input$year, ]
    df11 <- df22[df22[['Indicators']] == input$var, ]
    df00 <- df11[df11$Sex == input$sex, ]
    fortify(df00)
    View(df00)
    
    age <- strsplit(input$age, "", fixed = FALSE)
    age_int <- as.integer(age)
    plot0 <- as.matrix(df00[age_int, 6])
    
    # Reactive barplot output
    output$bar <- renderPlot({
      barplot(plot0, ylim = range(0, max(plot0)+5), beside = TRUE, space = 0.1, 
              legend.text = as.matrix(df00[age_int, 3]), args.legend = list(x = "bottomleft"),
              main = "Perceived health, very good or excellent")
      grid(nx = 0, ny = 10, col = "gray")
      abline(h = df00[1, 6], col = "red") # Total population reference line (horizontal)
    })
    
    # Table output below the barplot, reactive to "Create" button
    output$table <- renderTable({
      df00
      })
  
  
  })
  
  # Defining the popup labels for the leaflet plot
  province_popup <- paste0("<strong>GEO: </strong>",
                           spdf@data$NAME,
                           "<br><strong>Percent: </strong>",
                           spdf@data$VALUE)
  
  # Map output---
  output$map <- renderLeaflet({
    leaflet(data = spdf) %>% 
    addTiles()  %>% # Adds the default OpenStreetMap tiles
    setView(lat=60, lng=-95 , zoom=3) %>%
    addPolygons(weight = 1,
                fillColor = ~mypalette(spdf@data$VALUE),
                fillOpacity = 0.75,
                highlight = highlightOptions(color = 'blue', weight = 4, bringToFront = TRUE), # Add polygons
                popup = province_popup) %>%
    addLegend("bottomright", pal = mypalette, values = spdf@data$VALUE,
              title = "Perceived health, very good or excellent",
              labFormat = labelFormat(suffix = "%"),
              opacity = 1) %>%
    addResetMapButton()
  })
  

  # Line graph output---
  output$trend <- renderDygraph(
    dygraph(df_line, main = "Percent of Canadians indicating Very Good or Excellent Perceived Health",
            xlab = "Year", ylab = "Percent"))
  
  observeEvent(input$clickTrend, {
    print("click")
    
    df_plot <- df_line[df_line[1] >= input$date[1] & df_line[1] <= input$date[2], ]
    print(df_plot)
    output$trend <- renderDygraph(
      dygraph(df_plot, main = "Percent of Canadians indicating Very Good or Excellent Perceived Health",
              xlab = "Year", ylab = "Percent"))
  })
  
}

# Run the app ----

shinyApp(ui = ui, server = server)
