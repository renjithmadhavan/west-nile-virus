# title: "WNV Exploration"
# author: "Keith Hultman"
# date: "November 19, 2016"
#
# Explore ideas for WNV project
#



library(tidyverse)
load("./data/trainset1.RData")

by_week <- trainset1 %>% select(Week, NumMosquitos) %>%
  group_by(Week) %>%
  summarise(avg = mean(NumMosquitos)) 


ggplot(by_week, aes(x=Week, y=avg)) + geom_point() + geom_smooth() + ggtitle("Number of mosquitos per week") + ylab("Average number of mosquitos per trap per week")

ggplot(trainset1, aes(x=Tmin, y=NumMosquitos)) + geom_jitter() + geom_smooth() + ggtitle("Number of mosquitos vs temperature") + xlab("Temperature, degree F") + ylab("Average number of mosquitos per trap")

ggplot(trainset1, aes(x=DewPoint, y=NumMosquitos)) + geom_jitter() + geom_smooth()+ ylab("Average number of mosquitos per trap")

ggplot(trainset1, aes(x=(Sunset - Sunrise), y=NumMosquitos)) + geom_jitter() + geom_smooth()+ ylab("Average number of mosquitos per trap")

ggplot(trainset1, aes(x=ma10, y=NumMosquitos)) + geom_jitter() + geom_smooth()+ ylab("Average number of mosquitos per trap")

ggplot(trainset1, aes(x=precip10d, y=NumMosquitos)) + geom_jitter() + geom_smooth() + ggtitle("10 day precipitation average")+ ylab("Average number of mosquitos per trap")

ggplot(trainset1, aes(x=Week, y=NumMosquitos)) + geom_jitter() + geom_smooth() + ggtitle("Average number of mosquitos per week")+ ylab("Average number of mosquitos per trap")

ggplot(trainset1, aes(Week, NumMosquitos, group=Week)) + geom_boxplot() + ggtitle("Average number of mosquitos per week")+ ylab("Average number of mosquitos per trap")

ggplot(trainset1, aes(x=(abs(32-Week)), y=NumMosquitos)) + geom_jitter() + geom_smooth() + 
  ggplot(trainset1, aes(x=Summer, y=NumMosquitos)) + geom_jitter() + geom_smooth() + ggtitle("Average number of mosquitos per week from week 32")+ ylab("Average number of mosquitos per trap")

week32 <- trainset1 %>% filter(Week == 32) 
week24 <- trainset1 %>% filter(Week == 24)

qqnorm(week32$NumMosquitos)
qqnorm(week24$NumMosquitos)



## Animated map!


library(tidyverse)
library(gganimate)
library(animation)


load("./data/trainset2.RData")
byweek <- group_by(trainset2, Week) %>% summarize(weekly_avg_mosq=mean(NumMosquitos))

map_mosq <- ggplot(trainset2, aes(x=Longitude, y=Latitude, 
                                  size=NumMosquitos, 
                                  color=WnvPresent,
                                  alpha = .5,
                                  frame=Week)) + geom_point() + ggtitle("Animated map of mosquitos and presence of West Nile Virus in Chicago")

animated_map_mosq <- gg_animate(map_mosq)
animated_map_mosq
gg_animate_save(animated_map_mosq, filename = "Animated Mosquito Map.gif")


By year and week


byyearweek <- group_by(trainset2, Year, Week) %>% summarize(weekly_avg_mosq=mean(NumMosquitos))

trainset2$timepoint <- ((trainset2$Year - 2007) + (trainset2$Week / 52)) * 52

map_mosq <- ggplot(trainset2, aes(x=Longitude, y=Latitude, 
                                  size=NumMosquitos, 
                                  color=WnvPresent,
                                  alpha = .5,
                                  frame=timepoint)) + geom_point() + ggtitle("Animated map of mosquitos and \npresence of West Nile Virus in Chicago \n")
map_mosq

gg_animate_save(map_mosq, filename = "mosq_map.gif")
gg_animate(map_mosq, interval=0.2)
animated_map_mosq <- gg_animate(map_mosq)
animated_map_mosq

gg_animate_save(animated_map_mosq, filename = "mosq_map.gif")




library(tweenr)

traincomplete <- complete(trainset2, Trap, nesting(Longitude, Latitude), Week)

traincomplete <- trainset2 %>% group_by(Longitude, Latitude, Week) %>% summarise(NumMosSum = sum(NumMosquitos), WnvSum = any(WnvPresent))



traincomplete <- ungroup(traincomplete)

traincomplete$Week <- as.factor(traincomplete$Week)
traincomplete2 <- complete(traincomplete, Week, Longitude, Latitude, fill = list(NumMosSum = 0, WnvSum = FALSE))


table(traincomplete2$Week)
?split
tw_mosq <- split(traincomplete2, f = traincomplete2$Week)
tw_mosq[[2]]


tw_mosq2 <- tween_states(tw_mosq, tweenlength = 3, 
                         statelength = 1, 
                         ease = "linear",
                         nframes = 100)

map_mosq <- ggplot(tw_mosq2, aes(x=Longitude, y=Latitude, 
                                 size=NumMosSum, 
                                 color=WnvSum,
                                 alpha = 0.5,
                                 frame=.frame)) + 
  geom_point() + 
  ggtitle("Animated map of mosquitos and presence of West Nile Virus in Chicago")

save(map_mosq, file = "./data/map_mosq.RData")
load("./data/map_mosq.RData")
gg.map <- gg_animate(map_mosq)
gg_animate_save(gg.map, filename = "mosq.map.gif")
gg_animate(map_mosq, interval=0.2)



library(ggmap)

chicago <- get_map("Chicago")

ani_map <- ggmap(chicago) + 
  geom_point(data = trainset2, aes(x=Longitude, y=Latitude, 
                                   size=NumMosquitos, 
                                   color=WnvPresent,
                                   frame=Week)) + 
  ggtitle("Animated map of mosquitos and presence of West Nile Virus in Chicago")

gg_ani_map <- gg_animate(ani_map)
gg_animate_save(gg_ani_map, filename = "Chicago Mosq animated map.gif")
gg_animate(ani_map, interval = 0.2)


#Heatmap


wnpositive <- filter(trainset1, WnvPresent == TRUE)
ggmap(chicago) + geom_jitter(aes(x = Longitude, y = Latitude), color = "red", 
                             alpha = 0.1, size = 2, data = wnpositive)

load("./data/traps.RData")

ggmap(chicago) + geom_density2d(data = wnpositive, aes(x = Longitude, y = Latitude), size = 0.3) + 
  stat_density2d(data = wnpositive, aes(x = Longitude, y = Latitude, fill = ..level.., alpha = ..level..), size = 0.01, 
                 bins = 16, geom = "polygon") + 
  scale_fill_gradient(low = "green", high = "red") + 
  scale_alpha(range = c(0, 0.3), guide = FALSE) + 
  ggtitle("Heat map of West Nile Virus positive traps") + 
  geom_point(data = traps, aes(x = Longitude, y = Latitude), shape = 4)

