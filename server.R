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
  
  colfunc <- colorRampPalette(c("#0000ff","#bfff00","#ffff00","#ffbf00","#ff8000","#ff4000","#ff0000"))
  
  observe({
    cat("observation triggered\n")
    input$dateRange
    cat(input$dateRange[1])

    date1 <- as.Date(input$dateRange[1], origin="1970-01-01")
    date2 <- as.Date(input$dateRange[2], origin="1970-01-01")
    data <- get_data()(date1, date2)
    if(nrow(data) == 0){
      dummy_data <- data.table(0,Sys.Date(),0,NA)
      setnames(dummy_data, "V1", "usageId")
      setnames(dummy_data, "V2", "time")
      setnames(dummy_data, "V3", "numOfUsage")
      setnames(dummy_data, "V4", "location")
      data <- dummy_data
    }

    data$time <- mdy_hms(data$time)
    data <- data[order(data$time),]
    data$numOfUsage <- as.numeric(data$numOfUsage)
    data$time <- as.character(data$time)
    
    max_usage <- max(data$numOfUsage)

    data_l2 <<- data[data[,"location"]=="SIS Level 2",]
    data_l3 <<- data[data[,"location"]=="SIS Level 3",]
    data_l4 <<- data[data[,"location"]=="SIS Level 4",]
    
    output$chart1 <- renderPlotly({
      y <- data_l2$numOfUsage 
      x <- as.character(data_l2$time)
      m <- list(
        l=50, r=50, t=50,b=200, pad=4
      )
      pal <- colfunc(max_usage+1)[y+1]
      plot_ly(data_l2, x = ~x, y = ~y, type = 'bar', marker = list(color =  pal))%>%
        layout(title = "Real-Time Usage - Level2",margin = m, 
               yaxis = list(title = 'Number Of Usage'),
               xaxis = list(title = 'Datetime'))
    })
    
    output$chart2 <- renderPlotly({
      y <- data_l3$numOfUsage 
      x <- as.character(data_l3$time)
      m <- list(
        l=50, r=50, t=50,b=200, pad=4
      )
      pal <- colfunc(max_usage+1)[y+1]
      plot_ly(data_l3, x = ~x, y = ~y,marker = list(color =  pal), type = 'bar')%>%
        layout(title = "Real-Time Usage - Level3",margin = m, 
               yaxis = list(title = 'Number Of Usage'),
               xaxis = list(title = 'Datetime'))
    })
    
    output$chart3 <- renderPlotly({
      y <- data_l4$numOfUsage 
      x <- as.character(data_l4$time)
      m <- list(
        l=50, r=50, t=50,b=200, pad=4
      )
      pal <- colfunc(max_usage+1)[y+1]
      plot_ly(data_l4, x = ~x, y = ~y, marker = list(color =  pal), type = 'bar')%>%
        layout(title = "Real-Time Usage - Level4",margin = m, 
               yaxis = list(title = 'Number Of Usage'),
               xaxis = list(title = 'Datetime'))
    })
    
    output$table1 <- renderDataTable(data_l2)
    output$table2 <- renderDataTable(data_l3)
    output$table3 <- renderDataTable(data_l4)
  })


})
