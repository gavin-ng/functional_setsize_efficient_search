setwd("D:/Box Sync/Projects/Functional Set Size/FSS/functional_setsize_efficient_search/Experiment 1/Data")
setwd("C:/Users/Gavin/Downloads")

library(tidyverse)
library(ggplot2)
library(ez)
library(broom)
library(BayesFactor)

all_data <- read.csv("all.csv", header=TRUE)
all_data$RT <- as.numeric(as.character(all_data$RT))

accuracy_df <- all_data %>%
  group_by(sub_id) %>%
  summarise(accuracy = 1-mean(abs(Error)))


# after_removal <- all_data %>%
#   filter(sub_id != 26) %>%
#   filter(as.numeric(sub_id) <= 34)
# 
# cleaner_df <- all_data %>%
#   filter(sub_id != 26) %>%
#   filter(as.numeric(sub_id) <= 34) %>%
#   filter(RT > 200 & RT < 1500) 
# 
# 100* (1 - (nrow(cleaner_df) / nrow(after_removal)))

# data missing for subject 11 
# computer error for subject 26
# total subjects collected: 39, but pre-reg stated only 32 will be used
clean_df <- all_data %>% filter(Error == 0) %>%
  filter(sub_id != 26) %>%
  filter(as.numeric(sub_id) <= 34) %>%
  filter(RT < 1500 , RT > 200) %>%
  mutate(total_setsize = bird_setsize + fish_setsize) 

##################
#### ANALYSES ####
##################


individual_df <- clean_df %>% 
  group_by(sub_id, fish_setsize, bird_setsize) %>%
  summarise(meanRT = mean(RT))

individual_df$fish_setsize <- individual_df$fish_setsize+1
individual_df$bird_setsize <- as.factor(individual_df$bird_setsize)


individual_df$bird_setsize <- as.factor(individual_df$bird_setsize)
individual_df$fish_setsize <- as.factor(individual_df$fish_setsize)
individual_df$sub_id <- as.factor(individual_df$sub_id)

ezANOVA(individual_df,
        meanRT,
        within=c(fish_setsize, bird_setsize),
        wid = sub_id
)

individual_df$sub_id <- as.numeric(as.character(individual_df$sub_id))
anovaBF(meanRT ~ fish_setsize*bird_setsize, data=individual_df)


## Log vs linear fits

clean_df$bird_setsize <- as.factor(clean_df$bird_setsize)
clean_df$log_fish_setsize <- log(clean_df$fish_setsize+1)
clean_df$sub_id <- as.factor(clean_df$sub_id)

log_fits <- clean_df %>%
  group_by(log_fish_setsize, bird_setsize, sub_id) %>%
  summarise(meanRT = mean(RT)) %>%
  group_by(bird_setsize, sub_id) %>% 
  do(log_r2 = summary(lm(meanRT ~ log_fish_setsize, data=.))$r.squared)

linear_fits <- clean_df %>%
  group_by(fish_setsize, bird_setsize, sub_id) %>%
  summarise(meanRT = mean(RT)) %>%
  group_by(bird_setsize, sub_id) %>%
  do(linear_r2 = summary(lm(meanRT ~ fish_setsize, data=.))$r.squared)

fits_df <- merge(log_fits, linear_fits)

t.test(as.numeric(fits_df$log_r2), as.numeric(fits_df$linear_r2), paired=TRUE)
mean(as.numeric(fits_df$log_r2))
mean(as.numeric(fits_df$linear_r2))

log_aic <- AIC(lm(meanRT ~ log_fish_setsize, data=log_fits))
linear_aic <- AIC(lm(meanRT ~ fish_setsize, data=linear_fits))

exp((linear_aic - log_aic)/2)

#### Plot

summary_df <- clean_df %>% 
  group_by(fish_setsize, bird_setsize) %>%
  summarise(meanRT = mean(RT), SD = sd(RT)/32)


summary_df$fish_setsize <- summary_df$fish_setsize+1

summary_df$fish_setsize <- as.numeric(summary_df$fish_setsize)
summary_df$bird_setsize <- as.factor(summary_df$bird_setsize)


ggplot(summary_df, aes(x=fish_setsize, y=meanRT, color=bird_setsize)) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin=meanRT-SD, ymax=meanRT+SD), width=.5) + 
  # geom_line() +
  stat_smooth(method="lm", formula=y~log(x), se=FALSE, linetype=1, size=1) +
  scale_color_manual(values=c('#8B0000', '#FF0000', '#FF9100', "#FFE600")) +
  xlab("Fish set size") +
  ylab("RT(ms)") +
  labs(color="Bird set size")
  
  
  

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


