## R Script for Midterm group project
## Stats506, F20
## Group2: EunSeon Ahn, Tianshi Wang, Yanyu Long
##
## Visualization of COVID-19 Data:
##   	1) Marginal plot
##   	2) Bubble plot
##    3) Interactive plot
## 
## Author: Yanyu Long, longyyu@umich.edu
## Updated: November 20, 2020

# 79: -------------------------------------------------------------------------

# libraries: ------------------------------------------------------------------
library(tidyverse)

# directories: ----------------------------------------------------------------
data_lib = "E:/git/Stats506_midterm_project/Data"
filename_racial = "Race Data Entry - CRDT.csv"
filename_covid = "owid-covid-data.csv"

## Plot1 (Marginal Plot) -------------------------------------------------------
### data input and pre-processing
racial_data = read_delim(
  sprintf("%s/%s", data_lib, filename_racial), 
  delim = ",",
  col_types = cols(
    .default = col_integer(), 
    Date = col_character(),
    State = col_character()
  )
) %>% 
  pivot_longer(
    cols = starts_with(c("Cases", "Deaths")), 
    names_pattern = "(Cases|Deaths)_(.*)",
    names_to = c(".value", "Race")
  ) %>%
  filter(!str_detect(Race, "Total|Ethnicity"))

date_picked = "20201101"
race_picked = c("White", "Black", "LatinX", "Asian")
plot1_data = racial_data %>%
  filter(
    Date == date_picked, 
    str_detect(Race, paste0(race_picked, collapse = "|"))
  ) %>%
  mutate(
    Race = factor(Race, levels = race_picked, ordered = TRUE)
  )

### creating the main plot (without margin plots)
plot1_title = sprintf(
  "%s (%s)",
  "Total confirmed COVID-19 deaths vs. cases, U.S. States",
  format(as.Date(date_picked, "%Y%m%d"), "%m/%d/%y")
)
palette_picked = "Set1" # pick a color palette
# use `RColorBrewer::display.brewer.all()` to check out available palettes

pic1_main = plot1_data %>%
  ggplot(aes(x = Cases, y = Deaths, color = Race)) +
  theme_bw() +
  geom_point(size = 2, alpha = .7) +
  scale_color_brewer(palette = palette_picked) +
  ggtitle(plot1_title) +
  theme(
    plot.title = element_text(hjust = 0.5, size = 12),
    axis.title = element_text(size = 9)
  )
print(pic1_main)

### creating the margin plots

#### method1 - ggExtra::ggMarginal()
pic1 = pic1_main + 
  theme(legend.position = "left") # move legend to the left side
  # because ggMarginal() add margin plots on the right side

# marginal histogram
ggExtra::ggMarginal(
  pic1, type="histogram", 
  groupColour = TRUE, groupFill = TRUE
)

# marginal boxplot
ggExtra::ggMarginal(
  pic1, type="boxplot", size = 5,
  # `size` specifies the relative size of the main plot 
  # to the marginal ones
  groupColour = TRUE, groupFill = TRUE
)

#### method2 - Cowplot

# create the marginal histograms manually
pic1_xhist = cowplot::axis_canvas(pic1_main, axis = "x") +
  geom_histogram(
    data = plot1_data %>% filter(!is.na(Cases) & !is.na(Deaths)), 
    aes(x = Cases, fill = Race, color = Race),
    bins = 30, alpha = .6
  ) +
  scale_fill_brewer(palette = palette_picked) +
  scale_color_brewer(palette = palette_picked)
print(pic1_xhist)

pic1_yhist = cowplot::axis_canvas(pic1_main, axis = "y", coord_flip = TRUE) +
  geom_histogram(
    data = plot1_data %>% filter(!is.na(Cases) & !is.na(Deaths)), 
    aes(x = Deaths, fill = Race, color = Race),
    bins = 30, alpha = .6
  ) +
  scale_fill_brewer(palette = palette_picked) +
  scale_color_brewer(palette = palette_picked) +
  coord_flip()
print(pic1_yhist)

# group the main plot and marginal plots together

# add the margin plots to the top/right side of the main plot
{pic1_main + 
    theme(legend.position = "left") # move legend to the left
    # to make room for margin plots
} %>%
  cowplot::insert_xaxis_grob(
    pic1_xhist, 
    height = grid::unit(.8, "in"), 
    position = "top"
  ) %>%
  cowplot::insert_yaxis_grob(
    pic1_yhist, 
    width = grid::unit(.8, "in"), 
    position = "right"
  ) %>%
  cowplot::ggdraw()

# add the margin plots to the bottom/left side of the main plot
{pic1_main +
    scale_x_continuous(position = "top") +
    scale_y_continuous(position = "right")
    # move the axis labels to the top/right to make room for margin plots
  } %>%
  cowplot::insert_xaxis_grob(
    pic1_xhist + scale_y_reverse(), 
    height = grid::unit(.8, "in"), 
    position = "bottom"
  ) %>%
  cowplot::insert_yaxis_grob(
    pic1_yhist + scale_y_reverse(), 
    width = grid::unit(.8, "in"), 
    position = "left"
  ) %>%
  cowplot::ggdraw()

# use a boxplot for the y-axis margin plot
pic1_ybox = cowplot::axis_canvas(pic1_main, axis = "y") +
  geom_boxplot(
    data = plot1_data %>% filter(!is.na(Cases) & !is.na(Deaths)),
    aes(x = 0, y = Deaths, fill = Race, color = Race), 
    alpha = .6
  ) +
  scale_fill_brewer(palette = palette_picked) +
  scale_color_brewer(palette = palette_picked)
print(pic1_ybox)

{pic1_main + 
    theme(legend.position = "left")
  } %>%
  cowplot::insert_xaxis_grob(
    pic1_xhist, 
    height = grid::unit(.8, "in"), 
    position = "top"
  ) %>%
  cowplot::insert_yaxis_grob(
    pic1_ybox, 
    width = grid::unit(.8, "in"), 
    position = "right"
  ) %>%
  cowplot::ggdraw()


## Plot2 (Bubble Plot) -------------------------------------------------------
### data input and pre-processing
plot2_data = read_delim(
  sprintf("%s/%s", data_lib, filename_covid), 
  delim = ","
) %>%
  select(date, iso_code, continent, total_deaths_per_million,
         stringency_index, human_development_index) %>%
  filter(date == "2020-10-20")
  # `date` or `iso_code` will not be used in the plotting process
  # but these two variables constitute the ID for each observation
  # so I keep those just for reference

### creating the bubble plot
plot2_title = paste0(
  "Total # of Deaths Across Gov. Stringency Index", 
  " and Human Development Index"
)

plot2_data %>%
  filter(!is.na(continent)) %>% # remove 'NA' from the plot's legend
  ggplot(aes(
    x = stringency_index, y = human_development_index,
    size = total_deaths_per_million, color = continent
  )) +
  theme_bw() +
  geom_point(alpha = .5) +
  scale_size_continuous(
    name = "Total Death (Per Mil.)",
    breaks = seq(100, 1300, 300),
    range = c(2, 14)
  ) +
  scale_color_brewer(
    name = "Continent", 
    palette = "Set1"
  ) +
  scale_x_continuous(
    name = "Stringency Index", 
    breaks = seq(0, 100, 10)
  ) +
  scale_y_continuous(
    name = "Human Development Index",
    breaks = seq(0, 1, 0.1)
  ) +
  ggtitle(plot2_title) +
  theme(
    panel.grid.minor = element_blank(),
    plot.title = element_text(hjust = 0.5, size = 12),
    axis.title = element_text(size = 10)
  ) +
  guides(color = guide_legend(override.aes = list(size = 3))) # enlarge the
  # symbol size in the color legend


## Plot3 (Interactive Plot) -------------------------------------------------------
### data input and pre-processing

plot3_data = read_delim(
  sprintf("%s/%s", data_lib, filename_covid), 
  delim = ",",
  col_types = cols( # specify the types for our variables of interest
    # otherwise some will be read in as 'logical' and lead to incorrect values
    date = col_character(),
    iso_code = col_character(),
    location = col_character(),
    total_cases_per_million = col_double(),
    total_deaths_per_million = col_double(),
    hosp_patients_per_million = col_double(),
    total_tests_per_thousand = col_double()
  )
) %>%
  select(date, iso_code, location, 
         total_cases_per_million, 
         total_deaths_per_million,  
         hosp_patients_per_million, 
         total_tests_per_thousand) %>%
  filter(
    iso_code %in% c("AUT", "BEL", "BGR", "CZE", "DNK"),
    date == "2020-10-20"
  ) %>%
  mutate(
    total_tests_per_thousand = total_tests_per_thousand * 1e03
    # turn 'per thousand' to 'per million'
  ) %>%
  pivot_longer(
    cols = total_cases_per_million:total_tests_per_thousand,
    names_pattern = "(.*)_per", 
    names_to = "variable"
  ) %>%
  mutate(
    variable = factor(
      variable, 
      levels = c("total_cases", "total_deaths", 
                 "hosp_patients", "total_tests"),
      # add labels so that the legend items in the plot make more sense
      label = c("Cases", "Deaths", "Hospitalizations", "Tests"),
      # order the factor levels to control for the order of variables
      # displayed in the bar plot
      ordered = TRUE)
  )


### creating the base (static) plot
plot3_title = "Comparison of # of Cases, Deaths, Hospitalizations, and Testing"
plot3_base = plot3_data %>%
  ggplot(aes(x = location, y = value,
             fill = variable)) +
  theme_bw() +
  geom_col(position = "dodge", width = .7) +
  scale_fill_brewer(
    name = "Total Number", 
    palette = "Paired"
  ) +
  scale_x_discrete(name = "Countries") +
  scale_y_continuous(name = "# per Mil.") +
  ggtitle(plot3_title) +
  theme(
    panel.grid.minor = element_blank(),
    plot.title = element_text(hjust = 0.5, size = 12),
    axis.title = element_text(size = 10)
  )
print(plot3_base)

### creating the interactive plot
plot3_base %>%
  plotly::ggplotly()

### transform the y-axis values using a log10 scale
{plot3_base +
    scale_y_continuous(
      name = "log10(# per Mil.)", 
      trans = "log10"
    ) + 
    theme(
      axis.text.y = element_blank() # remove the y-axis label
      # because they are not helpful due to the large data range
    )
  } %>%
  plotly::ggplotly()

### adjust the legend position in interactive plot
# note that the legend position is higher than static plots
# we can move the legend downwards using the following code
{plot3_base + 
    scale_y_continuous(name = "log10(# per Mil.)", trans = "log10") +
    theme(
      axis.text.y = element_blank(),
      legend.title = element_blank() # hide the legend title
    )
  } %>%
  plotly::ggplotly() %>%
  # move legend downwards
  plotly::layout(legend=list(y=0.8, yanchor="top")) %>% 
  # add the legend title back but to a lower position
  plotly::add_annotations(
    text="Total Number",
    xref="paper", x=1.02, xanchor="left",
    yref="paper", y=0.8, yanchor="bottom",
    legendtitle=TRUE,
    showarrow=FALSE
  )

# 79: -------------------------------------------------------------------------