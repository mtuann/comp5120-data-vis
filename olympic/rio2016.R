
library(shiny)
library(ggplot2)
library(readr)
library(reshape2)
library(DT)
library(tidyverse)
library(plotly)


# Define UI for application
ui <- fluidPage(
  titlePanel("Olympic Data Visualization"),
  
  sidebarLayout(
    sidebarPanel(
      # Add any inputs here if needed
        selectInput("game_season", "Game Season", choices = c("Summer", "Winter"), selected = "Summer"),
        # selectInput("participant_type", "Participant Type", choices = c("Athlete", "Official", "Team Official", "Coach", "Media", "Other", "Technical Official"), selected = "Athlete"),
        # selectInput("year", "Year", choices = c(1896:2022), selected = 2016)
      # add tabs for description and change its by observe
      # tabsetPanel(
      #   tabPanel("Description",
      #            p("This application visualizes the Olympic data in both Summer and Winter seasons."),
      #            p("The data includes information about the participants, medals, and sports."),
      #   ), 
      # ),
    ),
    # Mean medals for host countries: 38.74
    # Mean medals for non-host countries: 14.535340314136125
    # T-statistic: 7.514655610310393, P-value: 1.5080550141806764e-13
    # Correlation between being the host and medal count: 0.2549949968076143
    
    
    mainPanel(
      tabsetPanel(
        tabPanel("Game Type",
                 fluidRow(
                   column(12, plotlyOutput("heatmapPlotSport", height = "1000px", width = "1000px")),
                   column(12, plotlyOutput("barchartSport", height = "1000px", width = "1000px")),
                 ),
                fluidRow(
                  column(12, uiOutput("comments"))
                ),
                fluidRow(
                  column(12, plotlyOutput("eventGender", height = "1000px"))
                ),
                fluidRow(
                  column(12, uiOutput("genderComments", height = "1000px"))
                ),
                fluidRow(
                  column(12, plotlyOutput("medalstat1", height = "1000px")),
                  column(12, plotlyOutput("medalstat2", height = "1000px")),
                )
        ),
        tabPanel("Medal Statistics",
          uiOutput("commentsHostBias"),
          plotlyOutput("emptyPlot1", height = "1000px"),
          uiOutput("commentsMedalist"),
          uiOutput("commentsMedalByGameSeason"),
          DTOutput("tableMedalist"),
          uiOutput("commentsMedalByContry"),
          DTOutput("medalplot4")
        ),
        tabPanel("Game Records",
          uiOutput("commentsGameIndividual"),
          DTOutput("emptyPlot3"),
          uiOutput("commentsGameTeam"),
          DTOutput("emptyPlot4")
        )
      )   
    )
  )
)

# Define server logic
server <- function(input, output) {
  
  # Load data
  df <- read_csv("https://raw.githubusercontent.com/mtuann/comp5120-data-vis/main/olympic/data_medal_cleaned.csv")
  
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
    output$heatmapPlotSport <- renderPlotly({
      ggplotly(
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
      )
    })
    # adding bar chart
    df_sum <- data.frame(discipline_title = df_heatmap$discipline_title, sum = rowSums(df_heatmap[,-1]))
    # plot df_sum as bar chart and sort by sum column in descending order
    output$barchartSport <- renderPlotly({
      ggplotly(
        ggplot(df_sum, aes(x = reorder(discipline_title, sum), y = sum, fill = sum)) +
          geom_bar(stat = "identity") +
          scale_fill_gradient(low = "green", high = "red") +
          theme_minimal() +
          labs(title = "Sports Held Over the Years", x = "Type of Sports", y = "Number of Years") +
          theme(axis.text.x = element_text(hjust = 1, size = 10),
                plot.title = element_text(size = 18, hjust = 0.5),
                panel.grid.major = element_blank(),
                panel.grid.minor = element_blank(),
                axis.line = element_line(color = "black"),
                legend.title = element_text(size = 12),
                legend.text = element_text(size = 10),
                plot.margin = unit(c(1, 1, 1, 1), "cm")) +
          scale_y_continuous(breaks = seq(0, 30, by = 5)) +
          coord_flip()
      )
    })


    output$comments <- renderUI({
      if (input$game_season == "Summer") 
        tags$div(
          tags$h3("Summer season (types of sports):"),
          tags$ul(
            tags$li("Highly Consistent Sports: Athletics, Fencing, and Swimming are among the most consistent sports, appearing in almost every edition of the Summer Olympics. These sports can be considered as the cornerstone of the Olympic program."),
            tags$li("Water Sports: Water Polo, Diving, and Sailing are examples of sports that have been consistently present in the Olympics, particularly in recent years, indicating the importance of water sports in the Olympic program."),
            tags$li("Emerging Trends: Newer sports like Skateboarding, Sport Climbing, and Surfing have been added to the Olympic program to attract younger audiences and reflect contemporary sporting trends."),
            tags$li("Discontinued Sports: Some sports like Croquet, Cricket, and Polo were once part of the Olympic program but have since been discontinued. These sports were popular in the early editions of the Olympics but lost relevance over time."),
          )
        )
      else
        tags$div(
          tags$h3("Winter season (types of sports):"),
          tags$ul(
            tags$li("Traditional winter sports like cross-country skiing, figure skating, ice hockey, and ski jumping have been consistent since the inception of the Winter Olympics in 1924."),
            tags$li("Alpine skiing, biathlon, luge, and freestyle skiing were introduced in later years, adding variety to the Games."),
            tags$li("Recent additions include snowboarding, curling, skeleton, and short track speed skating, reflecting the evolving landscape of winter sports."),
          
          )
        )
    })


    # sport by event gender, data from df_season, group by discipline_title and event_gender, participant_type and filter by 'athlete' from participant_type
  df_gender = aggregate(medal_type ~ discipline_title + event_gender + participant_type, data = df_filtered %>% filter(participant_type == 'Athlete'), FUN = length)
  df_gender <- df_gender %>%
    rename(medal_cnt = medal_type)

  # reorder df_gender by discipline_title in ascending order
  df_gender <- df_gender[order(df_gender$discipline_title), ]

  gender_colors <- c("Men" = "#FF0000", "Women" = "#0000FF", "Open" = "#00FF00")
  # output$eventGender <- renderPlot({
  #     # Create stacked bar chart for df_gender
  # ggplot(df_gender, aes(x = reorder(discipline_title, -medal_cnt), y = medal_cnt, fill = event_gender)) +
  #     geom_bar(stat = "identity") +
  #     scale_fill_manual(values = gender_colors) +
  #     labs(x = "Type of Sports", y = "Count", fill = "Gender") +
  #     theme_minimal() +
  #     theme(legend.position = "top", axis.text.x = element_text(angle = 90, hjust = 1)) +
  #     scale_y_continuous(breaks = seq(0, 2800, by = 400))
  # })
  output$eventGender <- renderPlotly({
    # Create stacked bar chart for df_gender
    p <- ggplot(df_gender, aes(x = reorder(discipline_title, -medal_cnt), y = medal_cnt, fill = event_gender)) +
        geom_bar(stat = "identity") +
        scale_fill_manual(values = gender_colors) +
        labs(x = "Type of Sports", y = "Number of Medals", fill = "Gender") +
        theme_minimal() +
        theme(legend.position = "top", axis.text.x = element_text(angle = 90, hjust = 1)) +
        scale_y_continuous(breaks = seq(0, 2800, by = 400))
    
    # Convert ggplot to plotly
    ggplotly(p, tooltip = c("x", "y", "fill"))
  })


output$genderComments <- renderUI({
      if (input$game_season == "Summer") 
        tags$div(
          tags$h3("Summer season (gender participation):"),
          tags$ul(
            tags$li("Participation Discrepancy: There is a significant difference in participation between male and female athletes across various sports. For example, in athletics, 1913 medals were awarded to male athletes compared to 882 to female athletes."),
            tags$li("Gender Gap in Some Sports: Some sports have a substantial gender gap in participation. For instance, in wrestling, 1264 medals were awarded to male athletes compared to only 92 to female athletes."),
            tags$li("Equal Participation: However, there are also sports with relatively equal participation between genders, such as badminton, where 25 medals were awarded to both male and female athletes."),
            tags$li("Open Gender Events: Some sports have OPEN gender events such as Shooting, Sailing, and Equestrian, where athletes compete against each other regardless of gender."),
          )
        )
      else
        tags$div(
          tags$h3("Winter season (gender participation):"),
          tags$ul(
            tags$li("Gender Parity: Alpine Skiing, Biathlon, Cross Country Skiing, Freestyle Skiing, Luge, Short Track, Short Track Speed Skating, Skeleton, and Snowboard all show relatively equal participation between men and women athletes, with only slight differences in medal counts."),
            tags$li("Dominance: Speed skating stands out as a discipline where men have a considerably higher medal count compared to women. This suggests a potential dominance of male athletes in this sport, which could be influenced by factors like training resources, participation rates, or physiological differences."),
            tags$li("Limited Participation: Ski Jumping have a limited number of events for women compared to men, which is reflected in the lower number of female athletes and medal counts. This may indicate historical biases or structural barriers that limit women's participation in these sports."),
          
          )
        )
    })

    output$commentsMedalist <- renderUI({
      if (input$game_season == "Summer")
        tags$div(
          tags$h3("Summer season (medal distribution):"),
          tags$ul(
            tags$li("Increasing Medal Counts Over Time: The number of medals awarded in the Olympic Games has generally increased over the years. For instance, in the recent Tokyo 2020 Games, there were 1080 medals awarded (340 Gold, 338 Silver, and 402 Bronze), compared to only 222 medals in the inaugural Athens 1896 Games."),
            tags$li("Consistency in Medal Distribution: The distribution of medal types (Gold, Silver, Bronze) remains relatively consistent across most Olympic Games. However, there may be slight variations depending on factors such as the number of events and participating athletes."),
            tags$li("Growth in Olympic Participation: The increasing number of medals awarded over the years reflects the growth in Olympic participation. More countries are participating in the Games, leading to a higher number of events and athletes competing for medals.")
          )
        )
      else
        tags$div(
          tags$h3("Winter season (medal distribution):"),
          tags$ul(
            tags$li("Consistent Medal Counts in Recent Games: The number of medals awarded in recent Winter Olympics, such as PyeongChang 2018 and Beijing 2022, remained consistent across all three types (Gold, Silver, and Bronze), with each type having similar counts."),
            tags$li("Historical Trends: The data also reflects historical trends, with earlier Olympics having fewer events and therefore fewer medals awarded compared to more recent ones. For example, the first Winter Olympics in Chamonix 1924 had a total of 49 medals awarded, while recent editions have seen over 300 medals awarded."),
            tags$li("Consistency in Gold, Silver, and Bronze Distribution: Across most Winter Olympics, there is a relatively even distribution of Gold, Silver, and Bronze medals, indicating fair competition and performance across different events.")
          
          )
        )
    })

    # comment medal by game season
    output$commentsMedalByGameSeason <- renderUI({
      if (input$game_season == "Summer") 
        tags$div(
          tags$h3("Table shows medal counts by Olympic Games: Summer season")
        )
      else
        tags$div(
          tags$h3("Table shows medal counts by Olympic Games: Winter season")
        )
    })

    # comment medal by country
    output$commentsMedalByContry <- renderUI({
      if (input$game_season == "Summer") 
        tags$div(
          tags$h3("Table shows medal counts by country: Summer season")
        )
      else
        tags$div(
          tags$h3("Table shows medal counts by country: Winter season")
        )
    })

       # Create a new dataframe with counts
      count_medal_df <- df_filtered %>%
        group_by(game_year, game_name, game_location, medal_type) %>%
        summarise(count = n(), .groups = "drop")
      # sort by game_year descending and medal_type (length of string)
      count_medal_df <- count_medal_df[order(-count_medal_df$game_year, nchar(count_medal_df$medal_type)),]

      medal_colors <- c("GOLD" = "#FFD700", "SILVER" = "#C0C0C0", "BRONZE" = "#CD7F32")

      # # Define server logic for empty panels
      # output$emptyPlot1 <- renderPlot({
      #   # Plot
      #   ggplot(count_medal_df, aes(x = reorder(game_name, count), y = count, fill = medal_type)) +
      #     scale_fill_manual(values = medal_colors) +
      #     geom_bar(stat = "identity", position = "dodge") +
      #     coord_flip() +
      #     labs(title = "Medal Counts by Olympic Games", x = "Games", y = "Count") +
      #     theme_minimal() +
      #     theme(plot.title = element_text(hjust = 0.5),
      #           legend.title = element_blank())
      # })

      output$emptyPlot1 <- renderPlotly({
      # Plot
      p <- ggplot(count_medal_df, aes(x = reorder(game_name, count), y = count, fill = medal_type)) +
        scale_fill_manual(values = medal_colors) +
        geom_bar(stat = "identity", position = "dodge") +
        coord_flip() +
        labs(title = "Medal Counts by Olympic Games", x = "Games", y = "Count") +
        theme_minimal() +
        theme(plot.title = element_text(hjust = 0.5),
              legend.title = element_blank())
      
      ggplotly(p)
    })
    # comment host bias
    output$commentsHostBias <- renderUI({
      tags$div(
        tags$h3("Host Bias Analysis (both seasons):"),
        tags$ul(
          tags$li("Mean medals for host countries: 38.74"),
          tags$li("Mean medals for non-host countries: 14.535340314136125"),
          tags$li("T-statistic: 7.514655610310393, P-value: 1.5080550141806764e-13"),
          tags$li("Correlation between being the host and medal count: 0.2549949968076143")
        ),
        # A value of 0.255 indicates a positive correlation, meaning there is a tendency for the medal count to increase when a country hosts the Olympics. However, the value is relatively low, suggesting that while there is a positive relationship, it is not very strong.
        tags$p("A value of 0.255 indicates a positive correlation, meaning there is a tendency for the medal count to increase when a country hosts the Olympics. However, the value is relatively low, suggesting that while there is a positive relationship, it is not very strong.")
      )
    })

      # Table
      output$tableMedalist <- renderDT({
        datatable(count_medal_df, 
                  options = list(
                    searching = TRUE,
                    pageLength = 50
                  )
        )
      })
      

      # filter data by country (participant_title)
      medals_by_country <- df_filtered %>%
        group_by(medal_type, country_name, country_3_letter_code) %>%
        summarise(count = n(), .groups = "drop")
      # sort by count descending
      medals_by_country <- medals_by_country[order(-medals_by_country$count),]
        # Table
        output$medalplot4 <- renderDT({
          datatable(medals_by_country, 
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
      set_limit = 90
      if (input$game_season == "Winter") {
        set_limit = 75
      }
      # get list of discipline_title with sum medal_type >= 90
      large_medals <- medals_by_sport %>%
        group_by(discipline_title) %>%
        summarise(count = sum(count)) %>%
        filter(count >= set_limit)
      
      small_medals <- medals_by_sport %>%
        group_by(discipline_title) %>%
        summarise(count = sum(count)) %>%
        filter(count < set_limit)
      
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
        labs(x = paste("Sport types with a number of awarded medals >=", set_limit), y = "Count", fill = "Medal Type") +
        theme_minimal() +
        theme(legend.position = "top", axis.text.x = element_text(angle = 90, hjust = 1)) +
        scale_y_continuous(breaks = seq(0, 3200, by = 400))
      
      # Create stacked bar chart for small medal counts
      plot_small <- ggplot(medals_by_sport_small, aes(x = reorder(discipline_title, -count), y = count, fill = medal_type)) +
        geom_bar(stat = "identity") +
        scale_fill_manual(values = medal_colors) +
        labs(x = paste("Sport types with a number of awarded medals <", set_limit), y = "Count", fill = "Medal Type") +
        theme_minimal() +
        theme(legend.position = "top", axis.text.x = element_text(angle = 90, hjust = 1)) +
        scale_y_continuous(breaks = seq(0, 100, by = 20))
      
      output$medalstat1 <- renderPlotly({
        ggplotly(plot_large)
      })
      
      output$medalstat2 <- renderPlotly({
        ggplotly(plot_small)
      })

      # Top 20 participants with the most medals
      # remove NA values of athlete_full_name column
      df_athlete <- df_filtered[!is.na(df_filtered$athlete_full_name),]
      # group by athlete_full_name and count the number of medals
      top_participants <- df_athlete %>%
        group_by(athlete_full_name, country_name, discipline_title) %>%
        summarise(count = n(), .groups = "drop") %>%
        top_n(50, count) %>%
        arrange(desc(count))
    # comment game individual

    output$commentsGameIndividual <- renderUI({
      tags$div(
        tags$h3("Table shows top 50 participants with the most medals")
      )
    })

      # Table
      output$emptyPlot3 <- renderDT({
        datatable(top_participants, 
                  options = list(
                    searching = TRUE,
                    pageLength = 50
                  )
        )
      })
    
    # Top 20 game teams with the most medals
    output$commentsGameTeam <- renderUI({
      tags$div(
        tags$h3("Table shows top 20 game teams with the most medals")
      )
    })


      # select only game_team (participant_type = "GameTeam") and group by game_name and country_name
    df_gameteam <- df_filtered[df_filtered$participant_type == "GameTeam",]
    top_participants_team <- df_gameteam %>%
      group_by(game_name, country_name, medal_type, discipline_title) %>%
      summarise(count = n(), .groups = "drop") %>%
      top_n(20, count) %>%
      arrange(desc(count))

            # Table
      output$emptyPlot4 <- renderDT({
        datatable(top_participants_team, 
                  options = list(
                    searching = TRUE,
                    pageLength = 50
                  )
        )
      })


      
  })

  


  
  output$emptyPlot4 <- renderPlot({
    plot(1, type = "n", xlab = "", ylab = "", axes = FALSE)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
