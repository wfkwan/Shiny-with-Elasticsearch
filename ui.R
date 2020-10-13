library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(plotly)
library(wordcloud2)

ui <- dashboardPage(
  dashboardHeader(title = "Sample Flight Dashboard"),
  ## Sidebar content
  dashboardSidebar(
    sidebarMenu(
      menuItem("Sample Dashboard", tabName = "sample", icon = icon("dashboard"))
    )
  ),
  
  ## Body content
  dashboardBody(
    tabItems(
      # First tab content
      tabItem(tabName = "sample",
              class = "active",
              fluidRow(
                box(
                  title = "Airline Flight",
                  plotlyOutput("airline_flights", height = 300),
                ),
                box(
                  title = "Airline Flight Destination Weather",
                  sliderInput("wordcloud_size", "Size of the Wordcloud:", 
                              min=0.1,
                              max=0.6,
                              value=0.6
                  ),
                  wordcloud2Output("dest_weather", height = 200),
                )
              ),
              fluidRow(
                box(
                  title = "Airline Flight Delay",
                  sliderInput("delay_time_range", "Time Range:", 
                              min=strptime("2020-10-10 08:00:00", 
                                           format="%Y-%m-%d %H:%M:%S"), 
                              max=strptime("2020-10-12 07:30:00",
                                           format="%Y-%m-%d %H:%M:%S"),
                              value=c(strptime("2020-10-10 08:00:00",
                                               format="%Y-%m-%d %H:%M:%S"),
                                      strptime("2020-10-12 07:30:00",
                                               format="%Y-%m-%d %H:%M:%S")),
                              step = 1800
                  ),
                  plotOutput("delay_time", height = 200),
                  width = "100%"
                )
              )
            )
      )
    )
)