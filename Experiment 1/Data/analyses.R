setwd("D:/Box Sync/Projects/Functional Set Size/FSS/functional_setsize_efficient_search/Experiment 1/Data")
setwd("C:/Users/Gavin/Downloads")

library(tidyverse)
library(ggplot2)
library(ez)
library(TOSTER)
library(BayesFactor)

all_data <- read.csv("all.csv", header=TRUE)
all_data$RT <- as.numeric(as.character(all_data$RT))

aa <- all_data %>% 
  filter(sub_id <= 32) %>%
  count(bird_setsize, fish_setsize)

accuracy_df <- all_data %>%
  group_by(sub_id) %>%
  summarise(accuracy = 1-mean(abs(Error)))


after_removal <- all_data %>%
  filter(sub_id != 26) %>%
  filter(as.numeric(sub_id) <= 34)

cleaner_df <- all_data %>%
  filter(sub_id != 26) %>%
  filter(as.numeric(sub_id) <= 34) %>%
  filter(RT > 200 & RT < 1500) 

100* (1 - (nrow(cleaner_df) / nrow(after_removal)))

# data missing for subject 11 
# computer error for subject 26
# total subjects collected: 39, but pre-reg stated only 32 will be used
clean_df <- all_data %>% filter(Error == 0) %>%
  filter(sub_id != 26) %>%
  filter(as.numeric(sub_id) <= 34) %>%
  filter(RT < 1500 , RT > 200) %>%
  mutate(total_setsize = bird_setsize + fish_setsize) 

removed_trials <- (nrow(clean_df) - nrow(cleaner_df)) / nrow(clean_df)

clean_df$log_bird_setsize <- log(clean_df$bird_setsize+1)
clean_df$log_fish_setsize <- log(clean_df$fish_setsize+1)


clean_df$fish_setsize <- as.factor(clean_df$fish_setsize) 
clean_df$bird_setsize <- as.factor(clean_df$bird_setsize)



summary_df <- clean_df %>% 
  group_by(fish_setsize, bird_setsize) %>%
  summarise(meanRT = mean(RT), SD = sd(RT))

summary_df$fish_setsize <- summary_df$fish_setsize+1

summary_df$fish_setsize <- as.numeric(summary_df$fish_setsize)
summary_df$bird_setsize <- as.factor(summary_df$bird_setsize)

ggplot(summary_df, aes(x=fish_setsize, y=meanRT, color=bird_setsize)) +
  geom_point(size = 3) +
  # geom_line() +
  stat_smooth(method="lm", formula=y~log(x), se=FALSE, linetype=1, size=1) +
  scale_color_manual(values=c('#000000', '#00007f', '#9E1E1E', "#b2b2ff")) +
  scale_color_manual(values=c('#b2b2ff', '#0000e5', '#9E1E1E', "#000000"))

individual_df <- clean_df %>% 
  group_by(sub_id, fish_setsize, bird_setsize) %>%
  summarise(meanRT = mean(RT))

individual_df$fish_setsize <- individual_df$fish_setsize+1
individual_df$bird_setsize <- as.factor(individual_df$bird_setsize)

ggplot(individual_df %>% filter(sub_id !=25), aes(x=fish_setsize, y=meanRT, color=bird_setsize)) +
  geom_point(size = 3) +
  # geom_line() +
  stat_smooth(method="lm", formula=y~log(x), se=FALSE, linetype=1, size=1) +
  scale_color_manual(values=c('#000000', '#00007f', '#9E1E1E', "#b2b2ff")) +
  scale_color_manual(values=c('#b2b2ff', '#0000e5', '#9E1E1E', "#000000")) +
  facet_wrap(~sub_id)


individual_df$bird_setsize <- as.factor(individual_df$bird_setsize)
individual_df$fish_setsize <- as.factor(individual_df$fish_setsize)
individual_df$sub_id <- as.factor(individual_df$sub_id)

ezANOVA(individual_df,
        RT,
        within=c(fish_setsize, bird_setsize),
        wid = sub_id
)

individual_df$sub_id <- as.numeric(as.character(individual_df$sub_id))
bf <- anovaBF(RT ~ fish_setsize*bird_setsize, data=individual_df %>% filter(sub_id <2))

bf

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

ggplot(tloc_df, aes(x=x, y=y, size=RT, color=RT)) +
  geom_point() + 
  geom_text(aes(label=roundedRT), hjust=0.5, vjust=2, size=4) +
  coord_cartesian(y = c(-10.5, -6.5), x = c(0.5, 10.5)) 


