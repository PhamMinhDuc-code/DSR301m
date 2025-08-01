# official
library(shiny)
library(leaflet)
library(jsonlite)
library(ggplot2)
library(tidyverse)
library(shinydashboard)
library(dplyr)
library(shinyMatrix)
library(plotly)

ui <- dashboardPage(
  dashboardHeader(title = "Interactive Map"),
  dashboardSidebar(sidebarMenu(
    menuItem("Weather", tabName = "weather"),
    menuItem("Forecast", tabName = "forecast")
  )),
  dashboardBody(tags$head(
    tags$style(HTML('<link href="https://kit-free.fontawesome.com/releases/latest/css/free.min.css" rel="stylesheet">')),
    tags$link(rel = "stylesheet", type = "text/css", href = "style.css"),
    tags$style(HTML(
      '
  @keyframes moveBackground {
    0% {
      background-position: 0 0;
    }
    100% {
      background-position: 0 100%;
    }
  }

  .content-wrapper {
    background: linear-gradient(to bottom, #cfecf7, #f4cccc, #d2fc9e); /* Combine three colors in the gradient */
    background-size: 100% 300%;
    #animation: moveBackground 5s linear infinite;
  }
  
  .map-container {
    height: 400px;
    margin-bottom: 20px;
  }
  
  .chart-container {
    height: 300px;
    margin-bottom: 10px;
  }
  '
    )),
  ),
  tabItems(
    tabItem(tabName = "weather",
            # Map section - full width at the top
            fluidRow(
              column(
                width = 12,
                tags$div(
                  p("Current Weather: by Pham Minh Duc", class = "custom-text"),
                ),
                tags$div(
                  style = "display: flex; align-items: center; margin-bottom: 10px;",
                  tags$i(class = "fas fa-map-marker-alt custom-icon"),
                  tags$div(tags$span(textOutput("location"), class = "custom-text-output1")),
                  tags$i(class = "fas fa-cloud-sun-rain custom-cloud1"),
                ),
                tags$div(
                  style = "display: flex; align-items: center; margin-bottom: 20px;",
                  tags$i(class = "fas fa-temperature-high custom-icon-temp"),
                  p("Current Temperature: ", class = "custom-text-output2"),
                  tags$div(
                    tags$span(textOutput("temperature"), class = "custom-text-temp"),
                  ),
                ),
                box(
                  width = 12,
                  leafletOutput("map", height = "400px"),
                  class = 'map-container'
                )
              )
            ),
            
            # Weather info boxes - 2 rows, 3 columns each
            fluidRow(
              column(width = 4,
                     box(
                       width = 12,
                       title = div(
                         tags$i(class = "fa-solid fa-droplet box-icon"), 
                         "Humidity"
                       ),
                       textOutput("humidity"),
                       background = "blue"
                     )
              ),
              column(width = 4,
                     box(
                       width = 12,
                       title = div(
                         tags$i(class = "fas fa-temperature-high box-icon"), 
                         "Feels Like"
                       ),
                       textOutput("feels_like"),
                       background = "red"
                     )
              ),
              column(width = 4,
                     box(
                       width = 12,
                       title = div(
                         tags$i(class = "fas fa-smog box-icon"), 
                         "Weather Condition"
                       ),
                       textOutput("weather_condition"),
                       background = "olive"
                     )
              )
            ),
            
            fluidRow(
              column(width = 4,
                     box(
                       width = 12,
                       title = div(
                         tags$i(class = "fas fa-eye box-icon"), 
                         "Visibility"
                       ),
                       textOutput("visibility"),
                       background = "teal"
                     )
              ),
              column(width = 4,
                     box(
                       width = 12,
                       title = div(
                         tags$i(class = "fas fa-wind box-icon"), 
                         "Wind Speed"
                       ),
                       textOutput("wind_speed"),
                       background = "navy"
                     )
              ),
              column(width = 4,
                     box(
                       width = 12,
                       title = div(
                         tags$i(class = "fas fa-globe-americas box-icon"), 
                         "Air Pressure"
                       ),
                       textOutput("air_pressure"),
                       background = "maroon"
                     )
              )
            ),
            
            # 4 charts section - 2 rows, 2 columns each
            fluidRow(
              column(width = 6,
                     box(
                       width = 12,
                       title = "Temperature Trend",
                       plotlyOutput("temp_chart", height = "300px"),
                       class = 'chart-container'
                     )
              ),
              column(width = 6,
                     box(
                       width = 12,
                       title = "Humidity Trend",
                       plotlyOutput("humidity_chart", height = "300px"),
                       class = 'chart-container'
                     )
              )
            ),
            
            fluidRow(
              column(width = 6,
                     box(
                       width = 12,
                       title = "Pressure Trend",
                       plotlyOutput("pressure_chart", height = "300px"),
                       class = 'chart-container'
                     )
              ),
              column(width = 6,
                     box(
                       width = 12,
                       title = "Wind Speed Trend",
                       plotlyOutput("wind_chart", height = "300px"),
                       class = 'chart-container'
                     )
              )
            )
    ),
    tabItem(
      tabName = "forecast",
      tags$div(
        style = "display: flex; align-items: center;",
        tags$i(class = "fas fa-map-marker-alt custom-icon-fc"),
        tags$div(textOutput("location_")),
      ),
      # Add forecast content here
      
      column(width=3,
             box(
               selectInput(
                 "feature",
                 "Features:",
                 list(
                   "temp",
                   "feels_like",
                   "temp_min",
                   "temp_max",
                   "pressure",
                   "sea_level",
                   "grnd_level",
                   "humidity",
                   "speed",
                   "deg",
                   "gust",
                   "Pham Minh Duc")
               ),
               class = "box-fc")),
      box(plotlyOutput("line_chart"),class = "chart"),
    )
  )
  )
)

get_weather_info <- function(lat, lon) {
  api_key <- "35aa26b6f8b70e81d64047814f72a78a"
  API_call <-
    "https://api.openweathermap.org/data/2.5/weather?lat=%s&lon=%s&appid=%s"
  complete_url <- sprintf(API_call, lat, lon, api_key)
  json <- fromJSON(complete_url)
  
  location <- json$name
  temp <- json$main$temp - 273.2
  feels_like <- json$main$feels_like - 273.2
  humidity <- json$main$humidity
  weather_condition <- json$weather$description
  visibility <- json$visibility/1000
  wind_speed <- json$wind$speed
  air_pressure <- json$main$pressure
  weather_info <- list(
    Location = location,
    Temperature = temp,
    Feels_like = feels_like,
    Humidity = humidity,
    WeatherCondition = weather_condition,
    Visibility = visibility,
    Wind_speed = wind_speed,
    Air_pressure = air_pressure
  )
  return(weather_info)
}

get_forecast <- function(lat, lon) {
  api_key <- "35aa26b6f8b70e81d64047814f72a78a"
  # base_url variable to store url
  API_call = "https://api.openweathermap.org/data/2.5/forecast?lat=%s&lon=%s&appid=%s"
  
  # Construct complete_url variable to store full url address
  complete_url = sprintf(API_call, lat, lon, api_key)
  #print(complete_url)
  json <- fromJSON(complete_url)
  df <- data.frame(
    Time = json$list$dt_txt,
    Location = json$city$name,
    feels_like = json$list$main$feels_like - 273.2,
    temp_min = json$list$main$temp_min - 273.2,
    temp_max = json$list$main$temp_max - 273.2,
    pressure = json$list$main$pressure,
    sea_level = json$list$main$sea_level,
    grnd_level = json$list$main$grnd_level,
    humidity = json$list$main$humidity,
    temp_kf = json$list$main$temp_kf,
    temp = json$list$main$temp - 273.2,
    id = sapply(json$list$weather, function(entry)
      entry$id),
    main = sapply(json$list$weather, function(entry)
      entry$main),
    icon = sapply(json$list$weather, function(entry)
      entry$icon),
    humidity = json$list$main$humidity,
    weather_conditions = sapply(json$list$weather, function(entry)
      entry$description),
    speed = json$list$wind$speed,
    deg = json$list$wind$deg,
    gust = json$list$wind$gust
  )
  
  return (df)
}

server <- function(input, output, session) {
  # Set default coordinates
  default_lat <- 21.0277644
  default_lon <- 105.8341598
  
  # Initial call to get weather information for the default location
  weather_info <- get_weather_info(default_lat, default_lon)
  forecast_data <- get_forecast(default_lat, default_lon)
  
  # Display weather information for the default location
  output$location <- renderText({
    paste(weather_info$Location)
  })
  
  output$humidity <- renderText({
    paste(weather_info$Humidity, "%")
  })
  
  output$temperature <- renderText({
    paste(weather_info$Temperature, "°C")
  })
  
  output$feels_like <- renderText({
    paste(weather_info$Feels_like, "°C")
  })
  
  output$weather_condition <- renderText({
    paste(weather_info$WeatherCondition)
  })
  
  output$visibility <- renderText({
    paste(weather_info$Visibility,"Km")
  })
  
  output$wind_speed <- renderText({
    paste(weather_info$Wind_speed, "Km/h")
  })
  
  output$air_pressure <- renderText({
    paste(weather_info$Air_pressure)
  })
  
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      setView(lng = default_lon, lat = default_lat, zoom = 11)
  })
  
  # Render the 4 new charts
  output$temp_chart <- renderPlotly({
    data <- forecast_data[1:min(24, nrow(forecast_data)), ]  # Show 24 hours
    plot_ly(data, x = ~Time, y = ~temp, type = 'scatter', mode = 'lines+markers', 
            line = list(color = '#FF6B6B'), marker = list(color = '#FF6B6B')) %>%
      layout(title = "", xaxis = list(title = "Time"), yaxis = list(title = "Temperature (°C)"),
             showlegend = FALSE)
  })
  
  output$humidity_chart <- renderPlotly({
    data <- forecast_data[1:min(24, nrow(forecast_data)), ]
    plot_ly(data, x = ~Time, y = ~humidity, type = 'scatter', mode = 'lines+markers',
            line = list(color = '#4ECDC4'), marker = list(color = '#4ECDC4')) %>%
      layout(title = "", xaxis = list(title = "Time"), yaxis = list(title = "Humidity (%)"),
             showlegend = FALSE)
  })
  
  output$pressure_chart <- renderPlotly({
    data <- forecast_data[1:min(24, nrow(forecast_data)), ]
    plot_ly(data, x = ~Time, y = ~pressure, type = 'scatter', mode = 'lines+markers',
            line = list(color = '#45B7D1'), marker = list(color = '#45B7D1')) %>%
      layout(title = "", xaxis = list(title = "Time"), yaxis = list(title = "Pressure (hPa)"),
             showlegend = FALSE)
  })
  
  output$wind_chart <- renderPlotly({
    data <- forecast_data[1:min(24, nrow(forecast_data)), ]
    plot_ly(data, x = ~Time, y = ~speed, type = 'scatter', mode = 'lines+markers',
            line = list(color = '#96CEB4'), marker = list(color = '#96CEB4')) %>%
      layout(title = "", xaxis = list(title = "Time"), yaxis = list(title = "Wind Speed (m/s)"),
             showlegend = FALSE)
  })
  
  click <- NULL
  observeEvent(input$map_click, {
    click <<- input$map_click
    weather_info <<- get_weather_info(click$lat, click$lng)
    forecast_data <<- get_forecast(click$lat, click$lng)
    
    # Update weather information when a new location is selected
    output$location <- renderText({
      paste(weather_info$Location)
    })
    output$humidity <- renderText({
      paste(weather_info$Humidity, "%")
    })
    output$temperature <- renderText({
      paste(weather_info$Temperature, "°C")
    })
    output$feels_like <- renderText({
      paste(weather_info$Feels_like, "°C")
    })
    output$weather_condition <- renderText({
      paste(weather_info$WeatherCondition)
    })
    output$visibility <- renderText({
      paste(weather_info$Visibility, "Km")
    })
    output$wind_speed <- renderText({
      paste(weather_info$Wind_speed, "Km/h")
    })
    output$air_pressure <- renderText({
      paste(weather_info$Air_pressure)
    })
    
    # Update the 4 charts with new location data
    output$temp_chart <- renderPlotly({
      data <- forecast_data[1:min(24, nrow(forecast_data)), ]
      plot_ly(data, x = ~Time, y = ~temp, type = 'scatter', mode = 'lines+markers',
              line = list(color = '#FF6B6B'), marker = list(color = '#FF6B6B')) %>%
        layout(title = "", xaxis = list(title = "Time"), yaxis = list(title = "Temperature (°C)"),
               showlegend = FALSE)
    })
    
    output$humidity_chart <- renderPlotly({
      data <- forecast_data[1:min(24, nrow(forecast_data)), ]
      plot_ly(data, x = ~Time, y = ~humidity, type = 'scatter', mode = 'lines+markers',
              line = list(color = '#4ECDC4'), marker = list(color = '#4ECDC4')) %>%
        layout(title = "", xaxis = list(title = "Time"), yaxis = list(title = "Humidity (%)"),
               showlegend = FALSE)
    })
    
    output$pressure_chart <- renderPlotly({
      data <- forecast_data[1:min(24, nrow(forecast_data)), ]
      plot_ly(data, x = ~Time, y = ~pressure, type = 'scatter', mode = 'lines+markers',
              line = list(color = '#45B7D1'), marker = list(color = '#45B7D1')) %>%
        layout(title = "", xaxis = list(title = "Time"), yaxis = list(title = "Pressure (hPa)"),
               showlegend = FALSE)
    })
    
    output$wind_chart <- renderPlotly({
      data <- forecast_data[1:min(24, nrow(forecast_data)), ]
      plot_ly(data, x = ~Time, y = ~speed, type = 'scatter', mode = 'lines+markers',
              line = list(color = '#96CEB4'), marker = list(color = '#96CEB4')) %>%
        layout(title = "", xaxis = list(title = "Time"), yaxis = list(title = "Wind Speed (m/s)"),
               showlegend = FALSE)
    })
  })
  
  observeEvent(input$feature, {
    # display location
    output$location_ <- renderText({
      paste('Location: ', weather_info$Location)
    })
    # set default
    default_lon = 105.8341598
    default_lat = 21.0277644
    data <- get_forecast(default_lat, default_lon)
    output$line_chart <- renderPlotly({
      # Create a line chart using plot_ly
      feature_data <- data[, c("Time", input$feature)]
      # Create a line chart using plot_ly
      plot_ly(data = feature_data, x = ~Time, y = ~.data[[input$feature]], type = 'scatter', mode = 'lines+markers', name = input$feature) %>%
        layout(
          title = "Sample Line Chart",
          xaxis = list(title = "Time"),
          yaxis = list(title = input$feature)
        ) %>%
        add_trace(
          line = list(color = "red"),  # Set the line color to red
          marker = list(color = "black"),  # Set the marker color to black
          showlegend = FALSE  # Hide the legend for this trace
        )
    })
    
    # plot the forecast
    if (!is.null(click)) {
      data <- get_forecast(click$lat, click$lng)
      output$line_chart <- renderPlotly({
        # Create a line chart using plot_ly
        feature_data <- data[, c("Time", input$feature)]
        # Create a line chart using plot_ly
        plot_ly(data = feature_data, x = ~Time, y = ~.data[[input$feature]], type = 'scatter', mode = 'lines+markers', name = input$feature) %>%
          layout(
            title = "Sample Line Chart",
            xaxis = list(title = "Time"),
            yaxis = list(title = input$feature)
          ) %>%
          add_trace(
            line = list(color = "red"),  # Set the line color to red and hide the legend entry
            marker = list(color = "black"),
            showlegend = FALSE  # Hide the legend for this trace
          )
      })
    }
  })
}

shinyApp(ui, server)