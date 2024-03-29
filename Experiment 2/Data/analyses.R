setwd("D:/Box Sync/Projects/Functional Set Size/FSS/functional_setsize_efficient_search/Experiment 2/Data")
# setwd("C:/Users/Gavin/Downloads")

library(tidyverse)
library(ggplot2)
library(ez)
library(broom)
library(BayesFactor)



# for making ticks on axes
number_ticks <- function(n) {function(limits) pretty(limits, n)}

every_nth <- function(x, nth, empty = TRUE, inverse = FALSE) 
{
  if (!inverse) {
    if(empty) {
      x[1:nth == 1] <- ""
      x
    } else {
      x[1:nth != 1]
    }
  } else {
    if(empty) {
      x[1:nth != 1] <- ""
      x
    } else {
      x[1:nth == 1]
    }
  }
}


all_data <- read.csv("all.csv", header=TRUE)
all_data$rt <- as.numeric(as.character(all_data$rt))

accuracy_df <- all_data %>%
  group_by(Subject.Number) %>%
  summarise(accuracy = mean(hit))

bad_subs <- (accuracy_df %>%
  filter(accuracy < .9))$Subject.Number


clean_df <- all_data %>% filter(hit == 1) %>%
  filter(Subject.Number < 21) %>%
  filter(rt < 2000 , rt > 200) %>%
  mutate(total_setsize = turtles + tortoises) 

percent_removed = 1 - nrow(clean_df)/nrow(all_data)

n_subs <- nrow(clean_df %>%
  group_by(Subject.Number) %>%
  count(Subject.Number))



##################
#### ANALYSES ####
##################


individual_df <- clean_df %>% 
  group_by(Subject.Number, turtles, tortoises) %>%
  summarise(meanRT = mean(rt))



ezANOVA(individual_df,
        meanRT,
        within=c(turtles, tortoises),
        wid = Subject.Number
)

# individual_df$sub_id <- as.numeric(as.character(individual_df$sub_id))

individual_df$turtles <- as.factor(individual_df$turtles)
individual_df$tortoises <- as.factor(individual_df$tortoises)
anovaBF(meanRT ~ turtles*tortoises, data=individual_df)


## Log vs linear fits

clean_df$log_tortoises <- (as.numeric(clean_df$tortoises) + 1)
clean_df$tortoises <- as.factor(clean_df$tortoises)
clean_df$log_turtles <- log(clean_df$turtles+1)
clean_df$Subject.Number <- as.factor(clean_df$Subject.Number)

log_fits_turtles <- clean_df %>%
  group_by(log_turtles, tortoises, Subject.Number) %>%
  summarise(meanRT = mean(rt)) %>%
  group_by(tortoises, Subject.Number) %>% 
  do(log_r2 = summary(lm(meanRT ~ log_turtles, data=.))$r.squared)

linear_fits_turtles <- clean_df %>%
  group_by(turtles, tortoises, Subject.Number) %>%
  summarise(meanRT = mean(rt)) %>%
  group_by(tortoises, Subject.Number) %>%
  do(linear_r2 = summary(lm(meanRT ~ turtles, data=.))$r.squared)

log_fits_tortoises <- clean_df %>%
  group_by(log_tortoises, turtles, Subject.Number) %>%
  summarise(meanRT = mean(rt)) %>%
  group_by(turtles, Subject.Number) %>%
  do(log_r2 = summary(lm(meanRT ~ log_tortoises, data=.))$r.squared)

log_fits_tortoises <- clean_df %>%
  group_by(log_tortoises, turtles, Subject.Number) %>%
  summarise(meanRT = mean(rt)) %>%
  group_by(turtles, Subject.Number) %>% 
  do(log_r2 = summary(lm(meanRT ~ log_tortoises, data=.))$r.squared)

linear_fits_tortoises <- clean_df %>%
  group_by(turtles, tortoises, Subject.Number) %>%
  summarise(meanRT = mean(rt)) %>%
  group_by(turtles, Subject.Number) %>%
  do(linear_r2 = summary(lm(meanRT ~ tortoises, data=.))$r.squared)


t.test(as.numeric(log_fits_turtles$log_r2), as.numeric(linear_fits_turtles$linear_r2), paired=TRUE)
t.test(as.numeric(log_fits_tortoises$log_r2), as.numeric(linear_fits_tortoises$linear_r2), paired=TRUE)


mean(as.numeric(log_fits_turtles$log_r2))
mean(as.numeric(linear_fits_turtles$linear_r2))
mean(as.numeric(log_fits_tortoises$log_r2))
mean(as.numeric(linear_fits_tortoises$linear_r2))

log_aic <- AIC(lm(meanRT ~ log_turtle, data=log_fits))
linear_aic <- AIC(lm(meanRT ~ turtle, data=linear_fits))

exp((linear_aic - log_aic)/2)

#### Plot

summary_df <- clean_df %>% 
  group_by(turtles, tortoises) %>%
  summarise(meanRT = mean(rt), SD = sd(rt)/n_subs)


summary_df$turtles <- summary_df$turtles+1

summary_df$turtles <- as.numeric(summary_df$turtles)
summary_df$tortoises <- as.factor(summary_df$tortoises)


ggplot(summary_df, aes(x=turtles, y=meanRT, color=tortoises)) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin=meanRT-SD, ymax=meanRT+SD), width=.5) + 
  # geom_line() +
  stat_smooth(method="lm", formula=y~log(x+1), se=FALSE, linetype=1, size=1) +
  scale_color_manual(values=c('#0000cc', '#0099cc', '#00cc99', "#66cc00")) +
  xlab("Distractor set size \n (Consistent region)") +
  ylab("RT(ms)") +
  labs(color="Set size\n(Target-inconsistent region)") + 
  scale_y_continuous(limits = c(650, 950),
                     breaks=seq(650, 950, 50),
                     labels = every_nth(seq(650, 950, 50), 1, inverse=TRUE)) +  labs(color="Distractor type") + 
  theme(axis.text.x = element_text(size=16),
        axis.text.y = element_text(size=16),
        axis.title.x = element_text(size=16),
        axis.title.y = element_text(size=16)) +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black")) +
  theme(legend.position = "none") 
  theme(legend.text=element_text(size=16))

summary_df$turtles <- as.factor(summary_df$turtles)
summary_df$tortoises <- as.numeric(as.character(summary_df$tortoises))
ggplot(summary_df, aes(x=tortoises, y=meanRT, color=turtles)) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin=meanRT-SD, ymax=meanRT+SD), width=.5) + 
  # geom_line() +
  stat_smooth(method="lm", formula=y~log(x+1), se=FALSE, linetype=1, size=1) +
  scale_color_manual(values=c('#8B0000', '#FF0000', '#FF9100', "#FFE600")) +
  
  xlab("Distractor set size \n (Inconsistent region)") +
  ylab("RT(ms)") +
  labs(color="Set size\n(Target-consistent region)") + 
  scale_y_continuous(limits = c(650, 950),
                     breaks=seq(650, 950, 50),
                     labels = every_nth(seq(650, 950, 50), 1, inverse=TRUE)) +  labs(color="Distractor type") + 
  theme(axis.text.x = element_text(size=16),
        axis.text.y = element_text(size=16),
        axis.title.x = element_text(size=16),
        axis.title.y = element_text(size=16)) +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black")) +
  # theme(legend.text=element_text(size=16))
  theme(legend.position = "none")

theme(legend.text=element_text(size=16))
tortoises_vs_turtles <- clean_df %>% 
  group_by(turtles, tortoises) %>%
  summarise(meanRT = mean(rt), SD = sd(rt)/nrow(accuracy_df)) %>%
  filter(tortoises == 0 | turtles == 0) %>%
  mutate(total_ss = as.numeric(as.character(tortoises)) + as.numeric(as.character(turtles))) %>%
  mutate(total_sss = total_ss + 1) %>%
  mutate(type = if_else(tortoises==0, "turtle", "tortoise"))

# collapse across tortoises
turtle_df <- clean_df %>%
  group_by(turtles) %>% 
  summarise(meanRT = mean(rt), SD = sd(rt)/nrow(accuracy_df)) %>%
  rename(ss = "turtles") %>%
  mutate(type = "consistent")

# collapse across turtles
tortoise_df <- clean_df %>%
  group_by(tortoises)%>% 
  summarise(meanRT = mean(rt), SD = sd(rt)/nrow(accuracy_df)) %>%
  rename(ss = 'tortoises') %>%
  mutate(type = "inconsistent")

t_v_t <- rbind(tortoise_df, turtle_df)

tortoises_vs_turtles <- rbind(tortoises_vs_turtles, tortoises_vs_turtles%>%filter(tortoises==0 & turtles==0) %>% mutate(type="tortoise"))

ggplot(t_v_t, aes(x=ss, y = meanRT, color =type)) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin=meanRT-SD, ymax=meanRT+SD), width=.5) + 
  # geom_line() +
  stat_smooth(method="lm", formula=y~log(x+1), se=FALSE, linetype=1, size=1) +
  scale_color_manual(values=c('#FF0000', '#0000cc'),
                     labels=c('Consistent region', 'Inconsistent region')) +
  xlab("Distractor set size \n ") +
  ylab("RT(ms)") +
  scale_y_continuous(limits = c(650, 950),
                     breaks=seq(650, 950, 50),
                     labels = every_nth(seq(650, 950, 50), 1, inverse=TRUE)) +  labs(color="Distractor type") + 
  theme(axis.text.x = element_text(size=16),
        axis.text.y = element_text(size=16),
        axis.title.x = element_text(size=16),
        axis.title.y = element_text(size=16)) +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black")) +
  # theme(legend.position = "none")
  theme(legend.text=element_text(size=16))
  
testing <- summary_df %>%
  filter((turtles == 1 & tortoises == 16) |
         (turtles == 17 & tortoises == 0) |
           (turtles == 9 & tortoises == 8))


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


