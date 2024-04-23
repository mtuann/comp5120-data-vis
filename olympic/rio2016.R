library(shiny)
library(ggplot2)
library(readr)
library(reshape2)

# Define UI for application
ui <- fluidPage(
  titlePanel("Olympic Data Visualization"),
  
  sidebarLayout(
    sidebarPanel(
      # Add any inputs here if needed
        selectInput("game_season", "Game Season", choices = c("Summer", "Winter"), selected = "Summer"),
        selectInput("participant_type", "Participant Type", choices = c("Athlete", "Official", "Team Official", "Coach", "Media", "Other", "Technical Official"), selected = "Athlete"),
        selectInput("year", "Year", choices = c(1896:2022), selected = 2016)
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Heatmap", plotOutput("heatmapPlot", height = "1000px", width = "700px")),
        tabPanel("Empty Panel 1", plotOutput("emptyPlot1", height = "200px")),
        tabPanel("Empty Panel 2", plotOutput("emptyPlot2", height = "200px")),
        tabPanel("Empty Panel 3", plotOutput("emptyPlot3", height = "200px")),
        tabPanel("Empty Panel 4", plotOutput("emptyPlot4", height = "200px"))
      )
    )
  )
)

# Define server logic
server <- function(input, output) {
  
  # Load data
  df <- read_csv("/Users/tuan/Desktop/vinuni-stuff/comp5120-datavis/projects/olympic/data_medal_cleaned.csv")
  
  observe({
    # Filter rows based on game_season
    df_filtered <- subset(df, game_season == input$game_season)
    
    # Group by discipline_title and game_year, and count participant_type
    df_disciplines_year <- aggregate(participant_type ~ discipline_title + game_year, data = df_filtered, FUN = length)
    
    # Pivot the dataframe
    df_heatmap <- reshape(df_disciplines_year, idvar = "discipline_title", timevar = "game_year", direction = "wide")
    
    # Remove "participant_type." from column names
    names(df_heatmap) <- gsub("participant_type.", "", names(df_heatmap))
    
    df_heatmap[is.na(df_heatmap)] <- 0
    # change the value of df_heatmap to binary value except the first column
    df_heatmap[,-1] <- ifelse(df_heatmap[,-1] > 0, 1, 0)
    
    # sort df_heatmap descending by sum of each row (except the first column)   
    # df_heatmap <- df_heatmap[order(-rowSums(df_heatmap[,-1])),]
    
    # convert back to data as df_disciplines_year
    df_disciplines_year2 <- melt(df_heatmap, id.vars = "discipline_title", variable.name = "game_year", value.name = "participant_type")
    
    df_disciplines_year2$discipline_title <- factor(df_disciplines_year2$discipline_title, levels = df_disciplines_year2$discipline_title[order(rowSums(df_heatmap[,-1]), decreasing = FALSE)])
    
    # Plot the heatmap
    output$heatmapPlot <- renderPlot({
      ggplot(df_disciplines_year2, aes(x = game_year, y = discipline_title, fill = factor(participant_type))) +
        geom_tile(color = "black") +
        scale_fill_manual(values = c("white", "red"), labels = c("NO", "YES"), name = "HELD") +
        theme_minimal() +
        labs(title = "Binary Heatmap of Sports Participation Over Years", x = "Year", y = "Type of Sports") +
        theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 10),
              axis.text.y = element_text(size = 10),
              plot.title = element_text(size = 18, hjust = 0.5),
              panel.grid.major = element_blank(),
              panel.grid.minor = element_blank(),
              axis.line = element_line(color = "black"),
              legend.title = element_text(size = 12),
              legend.text = element_text(size = 10),
              plot.margin = unit(c(1, 1, 1, 1), "cm"))
    })
  })
  
  # Define server logic for empty panels
  output$emptyPlot1 <- renderPlot({
    plot(1, type = "n", xlab = "", ylab = "", axes = FALSE)
  })
  
  output$emptyPlot2 <- renderPlot({
    plot(1, type = "n", xlab = "", ylab = "", axes = FALSE)
  })
  
  output$emptyPlot3 <- renderPlot({
    plot(1, type = "n", xlab = "", ylab = "", axes = FALSE)
  })
  
  output$emptyPlot4 <- renderPlot({
    plot(1, type = "n", xlab = "", ylab = "", axes = FALSE)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
