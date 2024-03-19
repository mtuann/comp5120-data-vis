# Brief description of dataset
## Provenance
The data originates from the Mr. Trash Wheel Baltimore Healthy Harbor project, employing trash interceptors stationed at waterway ends. Powered sustainably, these interceptors, including the initial Mr. Trash Wheel, have removed over 2,362 tons of trash collectively. Data collection involves manual counting of items on conveyor paddles during dumpster filling, with averages used to estimate total trash. Random bushel samples and volunteer-led "dumpster dives" further validate methods and identify unaccounted materials.
## The Data

```{r}
# Option 1: tidytuesdayR package 
## install.packages("tidytuesdayR")

tuesdata <- tidytuesdayR::tt_load('2024-03-05')
## OR
tuesdata <- tidytuesdayR::tt_load(2024, week = 10)

trashwheel <- tuesdata$trashwheel


# Option 2: Read directly from GitHub

trashwheel <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2024/2024-03-05/trashwheel.csv')

```
## Data Dimensions

# `trashwheel.csv`

|variable       |class     |description    |
|:--------------|:---------|:--------------|
|ID             |character |Short name for the Trash Wheel             |
|Name           |character |Name of the Trash Wheel           |
|Dumpster       |double    |Dumpster number       |
|Month          |character |Month          |
|Year           |double    |Year           |
|Date           |character |Date           |
|Weight         |double    |Weight in tons         |
|Volume         |double    |Volume in cubic yards          |
|PlasticBottles |double    |Number of plastic bottles |
|Polystyrene    |double    |Number of polystyrene items    |
|CigaretteButts |double    |Number of cigarette butts |
|GlassBottles   |double    |Number of glass bottles   |
|PlasticBags    |double    |Number of plastic bags    |
|Wrappers       |double    |Number of wrappers       |
|SportsBalls    |double    |Number of sports balls    |
|HomesPowered   |double    |Homes Powered - Each ton of trash equates to on average 500 kilowatts of electricity.  An average household will use 30 kilowatts per day.   |
## Why we should choose this dataset for project 1 ?
1. Real-world Impact: The dataset originates from the Mr. Trash Wheel Baltimore Healthy Harbor initiative, which addresses environmental issues by removing trash from waterways. Visualizing this data can highlight the real-world impact of such initiatives, emphasizing the importance of environmental conservation.

2. Multifaceted Data: The dataset includes various dimensions such as trash weight, volume, and the number of specific items like plastic bottles, cigarette butts, and more. This provides a rich source of data to explore and visualize different aspects of trash accumulation and composition.

3. Temporal Analysis: With attributes like Month, Year, and Date, the dataset enables temporal analysis, allowing we to visualize trends and patterns over time. This can be valuable for understanding seasonal variations, long-term changes, or identifying specific events that influence trash accumulation.

4. Comparative Analysis: The dataset includes multiple Trash Wheels, each with its own ID and Name. Visualizing data from different Trash Wheels allows for comparative analysis, exploring differences in trash collection rates, compositions, and effectiveness among the interceptors.

5. Environmental Awareness: Visualizing data related to plastic bottles, polystyrene items, cigarette butts, and other waste materials can raise awareness about the types of pollutants present in water bodies. This can be instrumental in advocating for policies and initiatives aimed at reducing plastic pollution and promoting environmental sustainability.

6. Energy Conversion: The dataset includes a unique attribute, "HomesPowered," which quantifies the energy generated from the collected trash. Visualizing this aspect can demonstrate the potential renewable energy benefits of waste management initiatives, reinforcing the importance of recycling and resource recovery.

7. Learning Opportunity: Working with this dataset provides an opportunity to apply data visualization techniques in a meaningful context, fostering a deeper understanding of environmental issues and the role of data in addressing them.

8. Environmental Awareness: Visualizing data related to plastic bottles, polystyrene items, cigarette butts, and other waste materials can raise awareness about the types of pollutants present in water bodies. This can be instrumental in advocating for policies and initiatives aimed at reducing plastic pollution and promoting environmental sustainability.
## Research question and involved varaialbes
### Question 1:
How does the composition of collected trash vary across different Trash Wheels (ID) over time (Month and Year)? Specifically, I will explore the relationship between the number of plastic bottles, polystyrene items, and glass bottles collected by each Trash Wheel in different months and years.

#### Variables:
- ID (Trash Wheel)
- Month
- Year
- PlasticBottles
- Polystyrene
- GlassBottles

### Question 2:
What is the seasonal pattern of trash accumulation in terms of weight (Weight), volume (Volume), and the number of plastic bags (PlasticBags)? I will investigate how these variables change over different months and years, considering the potential impact of seasonal factors on trash collection.

#### Variables:
- Month
- Year
- Weight
- Volume
- PlasticBags
## Plan for answering each ot the questions
### Question 1: How does the volume and weight of collected waste vary seasonally?

#### 1. Data Preparation:
   - Load the dataset into R.
   - Explore and clean the data if necessary.

#### 2. Data Visualization:
   - Create a line plot to visualize the seasonal trend of volume and weight of collected waste across different months or years.

   - This figure will provide insights into the seasonal patterns of waste accumulation, allowing for comparisons between Trash Wheels.

   - Optionally, create additional plots such as bar charts or stacked area plots to compare the composition of collected trash among different Trash Wheels.

#### 3. Insights:
   - Identify any patterns or trends in the composition of collected trash across different Trash Wheels over time.
   - Determine if certain Trash Wheels are more effective in collecting specific types of trash compared to others.

#### 4. Variables Involved:
   - ID (Trash Wheel)
   - Month
   - Year
   - PlasticBottles
   - Polystyrene
   - GlassBottles

### Question 2:  How does the seasonal pattern of trash accumulation vary for different types of trash (e.g., plastic bottles, glass bottles, plastic bags)?

#### 1. Data Preparation:
   - Load the dataset into R.
   - Explore and clean the data if necessary.

#### 2. Data Visualization:
   - Create a heatmap to visualize the correlation matrix between different types of trash (e.g., plastic bottles, polystyrene items, glass bottles, cigarette butts, wrappers, and sports balls).
   - Generate line plots or bar charts to visualize the seasonal pattern of trash accumulation for each type of trash. Aggregate the data by month and year to analyze seasonal trends.
   - Use boxplots or violin plots to compare the distribution of trash accumulation across different seasons (e.g., summer, winter) for each type of trash.
   - Optionally, create scatterplots to explore potential relationships between different types of trash accumulation (e.g., plastic bottles vs. plastic bags).


#### 3. Insights:
   - Determine if there are significant correlations between different types of trash accumulation. For example, you might find that certain types of trash tend to co-occur more frequently, indicating potential common sources or behaviors.
   - Analyze the seasonal patterns of trash accumulation to identify if there are specific seasons when certain types of trash are more prevalent. Consider external factors such as weather or human activities that might influence trash accumulation patterns.
   - Compare the seasonal patterns of different types of trash accumulation to understand if there are variations in trash generation based on factors such as human activities (e.g., increased outdoor activities in summer leading to more plastic bottles or sports ball litter).

#### 4. Variables Involved:
   - Month
   - Year
   - Weight
   - Volume
   - PlasticBags
   - Other types of trash (e.g., plastic bottles, polystyrene items, glass bottles, cigarette butts, wrappers, sports balls)
