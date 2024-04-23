library(shiny)
library(plotly)

# Sample data
country_data <- data.frame(
  country_name = c("USA", "China", "Russia", "Great Britain", "Germany"),
  gold_count = c(137, 127, 117, 89, 88),
  stringsAsFactors = FALSE
)

# Define UI
ui <- fluidPage(
  titlePanel("Gold Medal Count by Country"),
  plotlyOutput("bubblePlot")
)

# Define server
server <- function(input, output, session) {
  
  # Render bubble plot
  output$bubblePlot <- renderPlotly({
    plot_ly(country_data, x = ~country_name, y = ~gold_count, type = 'scatter', mode = 'markers',
            marker = list(size = ~gold_count, sizemode = "diameter"),
            text = ~paste("Country: ", country_name, "<br>Gold Count: ", gold_count),
            name = "Country") %>%
      layout(title = "",
             xaxis = list(title = ""),
             yaxis = list(title = ""),
             clickmode = 'event+select')
  })
  

}

# Run the application
shinyApp(ui = ui, server = server)
