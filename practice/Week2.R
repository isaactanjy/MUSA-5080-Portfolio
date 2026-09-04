library(tidyverse)
library(tidycensus)

pa_income <- get_acs(
  geography = "county",
  variables = "B19013_001",
  state = "PA",
  year = 2023,
  survey = "acs5"
)

# Nothing printed. This is because you didn't ask R to.

dim(pa_income)
glimpse(pa_income)
head(pa_income)

# Pennsylvania has 67 counties. My row count matches.

pa_income$GEOID

as.numeric("01001") # notice how the leading 0 disappears

# filter() verb - picking rows
filter(pa_income, estimate > 60000) # fewer rows than 67 as not all have income above 60000

# select() verb - picking columns
select(pa_income, NAME, estimate, moe) # fewer columns

# mutate() verb - making a new column
mutate(pa_income, moe_pct = moe / estimate * 100)
pa_income <- mutate(pa_income, moe_pct = moe / estimate * 100) # if you don't do this step, the mutated column is not added to the dataframe
print(pa_income)

# arrange() - sorts
arrange(pa_income, moe_pct) # ascending
arrange(pa_income, desc(moe_pct)) # descending (note that the top from the desc version is Cameron County - 42023)

# The pipe %>% - and then
step1 <- filter(pa_income, moe_pct > 5)
step2 <- arrange(step1, desc(moe_pct))
step3 <- select(step2, NAME, estimate, moe, moe_pct)
step3

pa_income %>%
  filter(moe_pct > 5) %>%
  arrange(desc(moe_pct)) %>%
  select(NAME, estimate, moe, moe_pct)

# for above, it is taking pa_income, keeping the unreliable ones, sorting worst first, and then showing the four columns listed

pa_income %>%
  filter(moe_pct > 8) %>%
  arrange(desc(estimate)) %>%
  select(NAME, moe_pct)

# notice how this landed on Cameron County again! Hohoho

worst <- pa_income %>%
  filter(moe_pct > 8) %>%
  arrange(desc(estimate)) %>%
  select(NAME, moe_pct)

# placing the results in an object called worst

pa_income <- mutate(pa_income, reliable = moe_pct < 5)

pa_income %>%
  group_by(reliable) %>%
  summarize(n = n(),
            average_income = mean(estimate))
