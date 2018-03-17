#------------------------------Check Installation------------------------------------------
packages <- c("data.table", "shiny", "plotly","lubridate", "shinydashboard", "jsonlite")
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(packages, rownames(installed.packages())))  
}

#------------------------------Import packages---------------------------------------------
library(data.table)
library(shiny)
library(plotly)
library(shinydashboard)
library(jsonlite)
library(lubridate)


shinyServer(function(input, output, session) {
  
  get_data <- reactive(function(start_date, end_date){
    time1 <- paste(start_date, "00:00:00 GMT")
    time2 <- paste(end_date, "23:59:59 GMT")
    milisecond1 <- as.numeric(as.POSIXct(time1, tz="Asia/Singapore"))
    milisecond2 <- as.numeric(as.POSIXct(time2, tz="Asia/Singapore"))
    url <- paste("https://qlclp3roz7.execute-api.us-east-1.amazonaws.com/dev/getBetween/",milisecond1,"000&",milisecond2,"000", sep="") 
    data <- fromJSON(url)
    return(data)
  })
  
  observe({
    cat("observation triggered\n")

    date1 <- as.Date(input$dateRange[1], origin="1970-01-01")
    date2 <- as.Date(input$dateRange[2], origin="1970-01-01")
    data <- get_data()(date1, date2)
    
    data$time <- mdy_hms(data$time)
    data <- data[order(data$time),]
    data$numOfUsage <- as.numeric(data$numOfUsage)
    data$time <- as.character(data$time)
    
    data1 <<- data[data[,"location"]=="SIS Level 2",]
    data2 <<- data[data[,"location"]=="SIS Level 4",]
    
    output$chart1 <- renderPlotly({
      y <- data1$numOfUsage 
      x <- as.character(data1$time)
      m <- list(
        l=50, r=50, t=50,b=200, pad=4
      )
      plot_ly(data1, x = ~x, y = ~y, type = 'scatter', mode = 'lines')%>%
        layout(title = "Real-Time Usage - Level2",margin = m, 
               yaxis = list(title = 'Number Of Usage'),
               xaxis = list(title = 'Datetime'))
    })
    
    output$chart2 <- renderPlotly({
      y <- data2$numOfUsage 
      x <- as.character(data2$time)
      m <- list(
        l=50, r=50, t=50,b=200, pad=4
      )
      plot_ly(data2, x = ~x, y = ~y, type = 'scatter', mode = 'lines')%>%
        layout(title = "Real-Time Usage - Level4",margin = m, 
               yaxis = list(title = 'Number Of Usage'),
               xaxis = list(title = 'Datetime'))
    })
    
    output$table1 <- renderDataTable(data1, rownames = FALSE)
    output$table2 <- renderDataTable(data2, rownames = FALSE)
    
  })
  
  
  
})
