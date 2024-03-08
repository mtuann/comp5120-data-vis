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

## How to Participate
- [Explore the data](https://r4ds.hadley.nz/), watching out for interesting relationships. We would like to emphasize that you should not draw conclusions about **causation** in the data. There are various moderating variables that affect all data, many of which might not have been captured in these datasets. As such, our suggestion is to use the data provided to practice your data tidying and plotting techniques, and to consider for yourself what nuances might underlie these relationships.
- Create a visualization, a model, a [shiny app](https://shiny.posit.co/), or some other piece of data-science-related output, using R or another programming language.
- [Share your output and the code used to generate it](../../../sharing.md) on social media with the #TidyTuesday hashtag.

### Data Dictionary

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

