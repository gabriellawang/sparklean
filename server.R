#------------------------------Check Installation------------------------------------------
packages <- c("data.table", "shiny", "plotly", "shinydashboard", "jsonlite")
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(packages, rownames(installed.packages())))  
}

#------------------------------Import packages---------------------------------------------
library(data.table)
library(shiny)
library(plotly)
library(shinydashboard)
library(jsonlite)


# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
  
  #------------------Get data----------------
  url <- "https://qlclp3roz7.execute-api.us-east-1.amazonaws.com/dev/getAll"
  data <- fromJSON(url)
  data <- data[order(data$time),]
  data$numOfUsage <- as.numeric(data$numOfUsage)
  data1 <- data[data[,"location"]=="SIS Level 2",]
  data2 <- data[data[,"location"]=="SIS Level 4",]
  
  output$chart1 <- renderPlotly({
    
    # generate bins based on input$bins from ui.R
    y <- data1$numOfUsage 
    x <- data1$time
    m <- list(
      l=50, r=50, t=50,b=200, pad=4
    )
    plot_ly(data1, x = ~time, y = ~numOfUsage, type = 'scatter', mode = 'lines')%>%
      layout(title = "Real-Time Usage - Level2",margin = m, 
             yaxis = list(title = 'Number Of Usage'),
             xaxis = list(title = 'Datetime'))
    
  })
  
  output$chart2 <- renderPlotly({
    
    # generate bins based on input$bins from ui.R
    y <- data2$numOfUsage 
    x <- data2$time
    m <- list(
      l=50, r=50, t=50,b=200, pad=4
    )
    plot_ly(data2, x = ~time, y = ~numOfUsage, type = 'scatter', mode = 'lines')%>%
      layout(title = "Real-Time Usage - Level4",margin = m, 
             yaxis = list(title = 'Number Of Usage'),
             xaxis = list(title = 'Datetime'))
    
  })
  
  output$table1 <- renderDataTable(data1)
  output$table2 <- renderDataTable(data2)
  
})
