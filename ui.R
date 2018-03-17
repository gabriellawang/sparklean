#------------------------------Check Installation------------------------------------------
packages <- c("shiny", "plotly", "shinydashboard")
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(packages, rownames(installed.packages())))  
}

#------------------------------Import packages---------------------------------------------
library(shiny)
library(plotly)
library(shinydashboard)

dashboardPage(
  dashboardHeader(title = "Sparklean Dashboard", titleWidth = 300),
  ## Sidebar content
  dashboardSidebar(
    width = 300,
    div(style="overflow-y: scroll"),
    sidebarMenu(
      width = 300,

      menuItem("SIS Level 2", tabName = "lvl2", 
               icon = icon("bar-chart", lib = "font-awesome")),

      menuItem("SIS Level 4", tabName = "lvl4", 
               icon = icon("bar-chart", lib = "font-awesome")),
      fluidRow(
        column(width=12, dateRangeInput('dateRange',
                                        label = 'Date Range',
                                        start = Sys.Date(), end = Sys.Date()))
        
      )
    )
  ),
  
  dashboardBody(
    tabItems(
      tabItem(tabName = "lvl2", align = "center",
              fluidRow(
                #h2("Toilet Usage Analysis - Lvl 2"),
                align="center",
                box(
                  title = "Toilet Usage Analysis - Lvl 2", status = "primary", solidHeader = TRUE,
                  collapsible = TRUE,
                  width=12,
                  plotlyOutput("chart1")
                ),
                box(
                  title = "Toilet Usage Data - Lvl 2", status = "primary", solidHeader = TRUE,
                  collapsible = TRUE,
                  width=12,
                  dataTableOutput("table1")
                )
                
              )              
      ),
      
      tabItem(tabName = "lvl4", align = "center",
              fluidRow(
                #h2("Toilet Usage Analysis - Lvl 4"),
                align="center",
                box(
                  title = "Toilet Usage Analysis - Lvl 4", status = "primary", solidHeader = TRUE,
                  collapsible = TRUE,
                  width=12,
                  plotlyOutput("chart2")
                ),
                box(
                  title = "Toilet Usage Data - Lvl 4", status = "primary", solidHeader = TRUE,
                  collapsible = TRUE,
                  width=12,
                  dataTableOutput("table2")
                )
              )
          )
      )
    )
  )
