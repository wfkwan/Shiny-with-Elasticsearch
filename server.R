library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(plotly)

annotate_agg1_es_result <- function(result, include_others=FALSE) {
  name <- c()
  count <- c()
  aggregation_result <- result$aggregations[[1]]
   if (include_others){
    if ("key_as_string" %in% names(aggregation_result)) name <- c(name, aggregation_result$key_as_string)
    else name <- c(name, aggregation_result$key)
    name <- c(name, "Others")
    count <- c(count, aggregation_result$sum_other_doc_count)
   }
    for (r in aggregation_result$buckets){
      if ("key_as_string" %in% names(r)) name <- c(name, r$key_as_string)
      else name <- c(name, r$key)
      count <- c(count, r$doc_count)
    }
  data.frame(name=name, count=count)
}

annotate_agg2_es_result <- function(result, include_others=FALSE) {
  
  name1 <- c()
  name2 <- c()
  count <- c()
  # start the first aggragation
  # select the first element from the list using [[1]] instead of $
  # since extract elements by name from a named list requires a known name
  aggregation_result <- result$aggregations[[1]]$buckets
    for (r1 in aggregation_result){
      # This part is for the other documents which are not included in this aggragation query
      # In some situations this value is nonzero
      # for example if you set the bucket size smaller than the maximum number of unique terms when using term aggragations
      if (include_others){
        # "key_as_string" key exist when datetime field is used for aggragation
        if ("key_as_string" %in% names(r1)) name1 <- c(name1, r1$key_as_string)
        else name1 <- c(name1, r1$key)
        name2 <- c(name2, "Others")
        print(r1$sum_other_doc_count)
        count <- c(count, r1[[length(r1)]]$sum_other_doc_count)
      }
      # second layer of aggragation
      for (r2 in r1[[length(r1)]]$buckets){
        if ("key_as_string" %in% names(r1)) name1 <- c(name1, r1$key_as_string)
        else name1 <- c(name1, r1$key)
        name2 <- c(name2, r2$key)
        count <- c(count, r2$doc_count)
      }
    }
  data.frame(name1=name1, name2=name2, count=count)
}


server <- function(input, output, session) {
  output$airline_flights <- renderPlotly({
    data <- setNames(annotate_agg1_es_result((es$search("kibana_sample_data_flights", airline_carrier_query))),
                     c("airline", "nflights"))
    colors <- c('rgb(211,94,96)', 'rgb(128,133,133)', 'rgb(144,103,167)', 'rgb(171,104,87)', 'rgb(114,147,203)')
    plot_ly(data, labels = ~airline, values = ~nflights, type = 'pie',
                   textposition = 'inside',
                   textinfo = 'label+percent',
                   insidetextfont = list(color = '#FFFFFF'),
                   marker = list(colors = colors,
                                 line = list(color = '#FFFFFF', width = 1)),
                   showlegend = FALSE)
  
  })
  
  output$delay_time <- renderPlot({
    data <- setNames(annotate_agg2_es_result((es$search("kibana_sample_data_flights", delay_type_query))),
                     c("time", "airline", "ndelays"))
    data$time <- as.POSIXct(data$time, format="%Y-%m-%dT%H:%M:%S")
    data <- data[(data$time >= input$delay_time_range[1]) & (data$time <= input$delay_time_range[2]), ]
    ggplot(data, aes(x=time, y=ndelays, fill=airline)) + geom_bar(stat="identity") + theme_minimal()
    
  })
  
  output$dest_weather <- renderWordcloud2({
    data <- setNames(annotate_agg1_es_result((es$search("kibana_sample_data_flights", dest_weather_query))),
                     c("weather", "ndest"))
    print(data)
    wordcloud2(data, size = input$wordcloud_size)
  })
  
}
