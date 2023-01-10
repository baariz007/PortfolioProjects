## install and load necessary packages
library(tidyverse)
library(janitor)
library(ggmap)
library(geosphere)
library(lubridate)
library(dplyr)

## import data in R studio

jan21 <- read_csv("202101-divvy-tripdata.csv")
feb21 <- read_csv("202102-divvy-tripdata.csv")
mar21 <- read_csv("202103-divvy-tripdata.csv")
apr21 <- read_csv("202104-divvy-tripdata.csv")
may21 <- read_csv("202105-divvy-tripdata.csv")
jun21 <- read_csv("202106-divvy-tripdata.csv")
jul21 <- read_csv("202107-divvy-tripdata.csv")
aug21 <- read_csv("202108-divvy-tripdata.csv")
sep21 <- read_csv("202109-divvy-tripdata.csv")
oct21 <- read_csv("202110-divvy-tripdata.csv")
nov21 <- read_csv("202111-divvy-tripdata.csv")
dec21 <- read_csv("202112-divvy-tripdata.csv")

## checking data sets for consistency
colnames(jan21)
colnames(feb21)
colnames(mar21)
colnames(apr21)
colnames(may21)
colnames(jun21) 
colnames(jul21)
colnames(aug21)
colnames(sep21)
colnames(oct21)
colnames(nov21)
colnames(dec21)

## to check data structures (dbl, chr, date)
str(jan21)
str(feb21)
str(mar21)
str(apr21)
str(may21)
str(jun21)  
str(jul21)
str(aug21)
str(sep21)
str(oct21)
str(nov21)
str(dec21)

## merge individual monthly data frames into one large data frame
tripdata <- bind_rows(jan21, feb21, mar21, apr21, may21, jun21, jul21, aug21,
                      sep21, oct21, nov21, dec21)

## checking merged data frame
colnames(tripdata)  #List of column names
head(tripdata)  #See the first 6 rows of data frame.  Also tail(tripdata)
str(tripdata)  #See list of columns and data types (numeric, character, etc)
summary(tripdata)  #Statistical summary of data. Mainly for numeric.

## Adding date, month, year, day of week columns
tripdata <- tripdata %>% 
  mutate(year = format(as.Date(started_at), "%Y")) %>% # extract year
  mutate(month = format(as.Date(started_at), "%B")) %>% #extract month
  mutate(date = format(as.Date(started_at), "%d")) %>% # extract date
  mutate(day_of_week = format(as.Date(started_at), "%A")) %>% # extract day of week
  mutate(ride_length = difftime(ended_at, started_at)) %>% 
  mutate(start_time = strftime(started_at, "%H"))

# converting 'ride_length' to numeric for calculation on data

tripdata <- tripdata %>% 
  mutate(ride_length = as.numeric(ride_length))
is.numeric(tripdata$ride_length) # to check it is right format

# adding ride distance in km
tripdata$ride_distance <- distGeo(matrix(c(tripdata$start_lng, tripdata$start_lat), ncol = 2),
                                  matrix(c(tripdata$end_lng, tripdata$end_lat), ncol = 2))

tripdata$ride_distance <- tripdata$ride_distance/1000 #distance in km

# Remove "bad" data
# The dataframe includes a few hundred entries when bikes were taken out of docks 
# and checked for quality by Divvy where ride_length was negative or 'zero'
tripdata_clean <- tripdata[!(tripdata$ride_length <= 0),]

# first lets check the cleaned data frame
str(tripdata_clean)

# lets check summarised details about the cleaned dataset 
summary(tripdata_clean)
  
## Conduct descriptive analysis
# descriptive analysis on 'ride_length'
# mean = straight average (total ride length / total rides)
# median = midpoint number of ride length array
# max = longest ride
# min = shortest ride

tripdata_clean %>% 
  summarise(average_ride_length = mean(ride_length), median_length = median(ride_length), 
            max_ride_length = max(ride_length), min_ride_length = min(ride_length))

# members vs casual riders difference depending on total rides taken
tripdata_clean %>% 
  group_by(member_casual) %>% 
  summarise(ride_count = length(ride_id), ride_percentage = (length(ride_id) / nrow(tripdata_clean)) * 100)

ggplot(tripdata_clean, aes(x = member_casual, fill=member_casual)) +
  geom_bar() +
  labs(x="Casuals vs Members", y="Number Of Rides", title= "Casuals vs Members distribution")

tripdata_clean %>%
  group_by(member_casual) %>% 
  summarise(average_ride_length = mean(ride_length), median_length = median(ride_length), 
            max_ride_length = max(ride_length), min_ride_length = min(ride_length))


# lets fix the days of the week order.
tripdata_clean$day_of_week <- ordered(tripdata_clean$day_of_week, 
                                      levels=c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"))

tripdata_clean %>% 
  group_by(member_casual, day_of_week) %>%  #groups by member_casual
  summarise(number_of_rides = n() #calculates the number of rides and average duration 
            ,average_ride_length = mean(ride_length),.groups="drop") %>% # calculates the average duration
  arrange(member_casual, day_of_week) #sort


##Visualize total rides data by type and day of week
tripdata_clean %>%  
  group_by(member_casual, day_of_week) %>% 
  summarise(number_of_rides = n(), .groups="drop") %>% 
  arrange(member_casual, day_of_week)  %>% 
  ggplot(aes(x = day_of_week, y = number_of_rides, fill = member_casual)) +
  labs(title ="Total rides by Members and Casual riders Vs. Day of the week") +
  geom_col(width=0.5, position = position_dodge(width=0.5)) +
  scale_y_continuous(labels = function(x) format(x, scientific = FALSE))


##Visualize average ride time data by type and day of week
tripdata_clean %>%  
  group_by(member_casual, day_of_week) %>% 
  summarise(average_ride_length = mean(ride_length), .groups="drop") %>%
  ggplot(aes(x = day_of_week, y = average_ride_length, fill = member_casual)) +
  geom_col(width=0.5, position = position_dodge(width=0.5)) + 
  labs(title ="Average ride time by Members and Casual riders Vs. Day of the week")


# First lets fix the days of the week order.
tripdata_clean$month <- ordered(tripdata_clean$month, 
                                levels=c("January", "February", "March", "April", "May", "June", 
                                         "July", "August", "September", "October", "November", "December"))

tripdata_clean %>% 
  group_by(member_casual, month) %>%  
  summarise(number_of_rides = n(), average_ride_length = mean(ride_length), .groups="drop") %>% 
  arrange(member_casual, month)

##Visualize total rides data by type and month
tripdata_clean %>%  
  group_by(member_casual, month) %>% 
  summarise(number_of_rides = n(),.groups="drop") %>% 
  arrange(member_casual, month)  %>% 
  ggplot(aes(x = month, y = number_of_rides, fill = member_casual)) +
  labs(title ="Total rides by Members and Casual riders Vs. Month", x = "Month", y= "Number Of Rides") +
  theme(axis.text.x = element_text(angle = 45)) +
  geom_col(width=0.5, position = position_dodge(width=0.5)) +
  scale_y_continuous(labels = function(x) format(x, scientific = FALSE))

##Visualize average ride time data by type and month
tripdata_clean %>%  
  group_by(member_casual, month) %>% 
  summarise(average_ride_length = mean(ride_length),.groups="drop") %>%
  ggplot(aes(x = month, y = average_ride_length, fill = member_casual)) +
  geom_col(width=0.5, position = position_dodge(width=0.5)) + 
  labs(title ="Average ride length by Members and Casual riders Vs. Month") +
  theme(axis.text.x = element_text(angle = 30))

##Comparison between Members and Casual riders depending on ride distance
tripdata_clean %>% 
  group_by(member_casual) %>% drop_na() %>%
  summarise(average_ride_distance = mean(ride_distance)) %>%
  ggplot() + 
  geom_col(mapping= aes(x= member_casual,y= average_ride_distance,fill=member_casual), show.legend = FALSE)+
  labs(title = "Mean travel distance by Members and Casual riders", x="Member and Casual riders", y="Average distance In Km")

##Analysis and visualization on cyclistic's bike demand by hour in a day
tripdata_clean %>%
  ggplot(aes(start_time, fill= member_casual)) +
  geom_bar() +
  labs(x="Hour of the day", title="Cyclistic's Bike demand by hour in a day") 
  

##Analysis and visualization on cyclistic's bike demand per hour by day of the week
tripdata_clean %>%
  ggplot(aes(start_time, fill=member_casual)) +
  geom_bar() +
  labs(x="Hour of the day", title="Cyclistic's bike demand per hour by day of the week") +
  facet_wrap(~ day_of_week)

##Analysis and visualization of Rideable type Vs. total rides by Members and casual riders
tripdata_clean %>%
  group_by(rideable_type) %>% 
  summarise(count = length(ride_id))

ggplot(tripdata_clean, aes(x=rideable_type, fill=member_casual)) +
  labs(x="Rideable type", title="Rideable type Vs. total rides by Members and casual riders") +
  geom_bar()

##Now analyze and visualize the dataset on coordinate basi
#Lets check the coordinates data of the rides.
#adding a new data frame only for the most popular routes >200 rides
coordinates_df <- tripdata_clean %>% 
  filter(start_lng != end_lng & start_lat != end_lat) %>%
  group_by(start_lng, start_lat, end_lng, end_lat, member_casual, rideable_type) %>%
  summarise(total_rides = n(),.groups="drop") %>%
  filter(total_rides > 200)

# now lets create two different data frames depending on rider type (member_casual)

casual_riders <- coordinates_df %>% filter(member_casual == "casual")
member_riders <- coordinates_df %>% filter(member_casual == "member")

##Lets setup ggmap and store map of Chicago (bbox, stamen map)
chicago <- c(left = -87.700424, bottom = 41.790769, right = -87.554855, top = 41.990119)

chicago_map <- get_stamenmap(bbox = chicago, zoom = 12, maptype = "terrain")

##Visualization on the map
# maps on casual riders
ggmap(chicago_map,darken = c(0.1, "white")) +
  geom_point(casual_riders, mapping = aes(x = start_lng, y = start_lat, color=rideable_type), size = 2) +
  coord_fixed(0.8) +
  labs(title = "Most used routes by Casual riders",x=NULL,y=NULL) +
  theme(legend.position="none")

#map on member riders
ggmap(chicago_map,darken = c(0.1, "white")) +
  geom_point(member_riders, mapping = aes(x = start_lng, y = start_lat, color=rideable_type), size = 2) +  
  coord_fixed(0.8) +
  labs(title = "Most used routes by Member riders",x=NULL,y=NULL) +
  theme(legend.position="none")






