
library(shiny)
library(ggplot2)
library(readr)
library(reshape2)
library(DT)

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
        tabPanel("Discipline", plotOutput("heatmapPlot", height = "1000px", width = "700px")),
        tabPanel("Medalist", plotOutput("emptyPlot1", height = "1000px")),
        tabPanel("Medalist-Summary", DTOutput("table")),
        tabPanel("Medal Statistics", 
                #  tabsetPanel(
                #    tabPanel("Plot 1", plotOutput("medalstat1", height = "500px")),
                #    tabPanel("Plot 2", plotOutput("medalstat2", height = "500px")),
                #    tabPanel("Plot 3", plotOutput("medalstat3", height = "500px")),
                #    tabPanel("Plot 4", plotOutput("medalstat4", height = "500px"))
                #  )
                 fluidRow(
                   column(6, plotOutput("medalstat1", height = "500px")),
                   column(6, plotOutput("medalstat2", height = "500px")),
                   column(6, plotOutput("medalstat3", height = "500px")),
                   column(6, plotOutput("medalstat4", height = "500px"))
                 )
        ),
        tabPanel("Empty Panel 4", plotOutput("emptyPlot4", height = "1000px"))
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

       # Create a new dataframe with counts
      count_medal_df <- df_filtered %>%
        group_by(game_year, game_name, game_location, medal_type) %>%
        summarise(count = n(), .groups = "drop")
      # sort by game_year descending and medal_type (length of string)
      count_medal_df <- count_medal_df[order(-count_medal_df$game_year, nchar(count_medal_df$medal_type)),]


      # Define server logic for empty panels
      output$emptyPlot1 <- renderPlot({
        # Plot
        ggplot(count_medal_df, aes(x = reorder(game_name, count), y = count, fill = medal_type)) +
          geom_bar(stat = "identity", position = "dodge") +
          coord_flip() +
          labs(title = "Medal Counts by Olympic Games", x = "Games", y = "Count") +
          theme_minimal() +
          theme(plot.title = element_text(hjust = 0.5),
                legend.title = element_blank())
      })

      # Table
      output$table <- renderDT({
        datatable(count_medal_df, 
                  options = list(
                    searching = TRUE,
                    pageLength = 20
                  )
        )
      })
      
      
      # Medals awarded by sport
      medals_by_sport <- df_filtered %>%
        group_by(discipline_title, medal_type) %>%
        summarise(count = n(), .groups = "drop")
      
      # Define medal colors
      medal_colors <- c("GOLD" = "#FFD700", "SILVER" = "#C0C0C0", "BRONZE" = "#CD7F32")
      
      # get list of discipline_title with sum medal_type >= 90
      large_medals <- medals_by_sport %>%
        group_by(discipline_title) %>%
        summarise(count = sum(count)) %>%
        filter(count >= 90)
      
      small_medals <- medals_by_sport %>%
        group_by(discipline_title) %>%
        summarise(count = sum(count)) %>%
        filter(count < 90)
      
      # get data that discipline_title in large_medals
      medals_by_sport_large <- medals_by_sport %>%
        filter(discipline_title %in% large_medals$discipline_title) %>%
        group_by(discipline_title, medal_type) %>%
        summarise(count = sum(count), .groups = "drop")
      
      # get data that discipline_title in small_medals
      medals_by_sport_small <- medals_by_sport %>%
        filter(discipline_title %in% small_medals$discipline_title) %>%
        group_by(discipline_title, medal_type) %>%
        summarise(count = sum(count), .groups = "drop")
      
      # Create stacked bar chart for large medal counts
      plot_large <- ggplot(medals_by_sport_large, aes(x = reorder(discipline_title, -count), y = count, fill = medal_type)) +
        geom_bar(stat = "identity") +
        scale_fill_manual(values = medal_colors) +
        labs(x = "Discipline Title of Medal >= 90", y = "Count", fill = "Medal Type") +
        theme_minimal() +
        theme(legend.position = "top", axis.text.x = element_text(angle = 90, hjust = 1)) +
        scale_y_continuous(breaks = seq(0, 3200, by = 400))
      
      # Create stacked bar chart for small medal counts
      plot_small <- ggplot(medals_by_sport_small, aes(x = reorder(discipline_title, -count), y = count, fill = medal_type)) +
        geom_bar(stat = "identity") +
        scale_fill_manual(values = medal_colors) +
        labs(x = "Discipline Title of Medal < 90", y = "Count", fill = "Medal Type") +
        theme_minimal() +
        theme(legend.position = "top", axis.text.x = element_text(angle = 90, hjust = 1)) +
        scale_y_continuous(breaks = seq(0, 100, by = 20))
      
      output$medalstat1 <- renderPlot({
        # Plot
        # plot_large
        # make the data in stack bar chart clickable
        plot_large

      })
      
      output$medalstat2 <- renderPlot({
        # Plot
        plot_small
      })
      
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
