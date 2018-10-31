setwd("C:/Users/Gavin/Downloads/Fish Data/Data")

library(tidyverse)
library(ggplot2)
library(ez)
library(TOSTER)

all_data <- read.csv("all.csv", header=TRUE)
all_data$RT <- as.numeric(as.character(all_data$RT))

aa <- all_data %>% filter(sub_id>2) %>%
  count(bird_setsize, fish_setsize)
clean_df <- all_data %>% filter(Error == 0) %>%
  filter(sub_id >2) %>%
  mutate(total_setsize = bird_setsize + fish_setsize)

cleaner_df <- clean_df %>%
  filter(RT > 200 & RT < 2000) %>%
  # group_by(total_setsize) %>%
  count(bird_setsize, fish_setsize) %>%
  mutate(a = 1- n/765)

removed_trials <- (nrow(clean_df) - nrow(cleaner_df)) / nrow(clean_df)

clean_df$log_bird_setsize <- log(clean_df$bird_setsize+1)
clean_df$log_fish_setsize <- log(clean_df$fish_setsize+1)


clean_df$fish_setsize <- as.factor(clean_df$fish_setsize) 
clean_df$bird_setsize <- as.factor(clean_df$bird_setsize)



summary_df <- clean_df %>% 
  group_by(fish_setsize, bird_setsize) %>%
  summarise(meanRT = mean(RT), SD = sd(RT))

summary_df$fish_setsize <- as.factor(summary_df$fish_setsize)

ggplot(summary_df, aes(x=bird_setsize, y=meanRT, color=fish_setsize)) +
  geom_point(size = 3) +
  geom_line() +
  # stat_smooth(method="lm", formula=y~log(x), se=FALSE, linetype=1, size=1) +
  # scale_color_manual(values=c('#000000', '#00007f', '#0000e5', "#b2b2ff"))
  scale_color_manual(values=c('#b2b2ff', '#0000e5', '#00007f', "#000000"))

individual_df <- clean_df %>% 
  group_by(sub_id, fish_setsize, bird_setsize) %>%
  summarise(RT = mean(RT))


individual_df$bird_setsize <- as.factor(individual_df$bird_setsize)
individual_df$fish_setsize <- as.factor(individual_df$fish_setsize)
individual_df$sub_id <- as.factor(individual_df$sub_id)

ezANOVA(individual_df,
        RT,
        within=c(fish_setsize, bird_setsize),
        wid = sub_id
)


clean_df$bird_setsize <- as.numeric(as.character((clean_df$bird_setsize)))

slopes <- clean_df %>%
  group_by(sub_id, bird_setsize, log_fish_setsize) %>%
  summarise(meanRT = mean(RT)) %>%
  do(slope = lm(meanRT ~ log_fish_setsize, data=.)) %>%
  tidy(slope) %>%
  filter(term=="log_fish_setsize") %>%
  select(-term, -std.error, -statistic, -p.value)


clean_df$bird_setsize <- as.factor(clean_df$bird_setsize)

slopes <- clean_df %>%
  group_by(sub_id, log_fish_setsize, bird_setsize) %>%
  summarise(RT = mean(RT)) %>%
  do(slope = lm(RT ~ (log_fish_setsize), data=.)) %>%
  tidy(slope) %>%
  # filter(term=="log_fish_setsize") %>%
  select(-term, -std.error, -statistic, -p.value)


ezANOVA(slopes,
        wid=sub_id,
        within=bird_setsize,
        dv = estimate)

t.test(slopes %>% filter())

# summary_df$fish_setsize <- as.factor(summary_df$fish_setsize)
summary_df$bird_setsize <- as.factor(summary_df$bird_setsize)



summary_df$fish_setsize <- summary_df$fish_setsize +1
ggplot(summary_df, aes(x=fish_setsize, y=RT)) +
  geom_point(size=3) +
  stat_smooth(method="lm", formula=y~log(x)) + 
  stat_smooth(method="lm", formula = y~x)



#### analysis by tloc
tloc_df <- clean_df %>% 
  group_by(tloc) %>%
  summarise(RT = mean(RT)) %>%
  mutate(x=if_else(tloc%%10 == 0, 10, tloc%%10), 
                   y=floor(-tloc/10.1)) %>%
  mutate(roundedRT = round(RT))

ggplot(tloc_df, aes(x=x, y=y, size=RT)) +
  geom_point() + 
  geom_text(aes(label=roundedRT), hjust=0.5, vjust=2, size=4) +
  coord_cartesian(y = c(-10.5, -6.5), x = c(0.5, 10.5)) 


