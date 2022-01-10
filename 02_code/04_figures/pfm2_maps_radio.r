
# Introduction ------------------------------------------------------------

# Author: Dylan Groves, dgroves@poverty-action.org
# Date: 6/28/2019
# Title: Randomization for Pangani FM 2

# Table of Contents -------------------------------------------------------

# Loads Sample Data (Generated in Sampling Folder)
# Randomization
# Plot Map
# Balance Tests

# Libraries ---------------------------------------------------------------

library(data.table)
library(dismo)
library(dplyr)
library(foreign)
library(geojsonio)
library(ggmap)
library(ggplot2)
library(ggpubr)
library(raster)
library(rgeos)
library(rgdal)
library(readstata13)
library(RColorBrewer)
library(sf)
library(sp)
library(spData)
library(tidyverse)


# Clear ------------------------------------------------------

rm(list=ls())


# Get Basemap Ready -------------------------------------------------------

ggmap::register_google(key = "AIzaSyAzh5EMvmLELIQXvFJhbmD9pCD4vM_XPXA")

# Load Sample Data and Set Seed -------------------------------------------------------------

# Randomization Spatial Data
load('X:/Box Sync/17_PanganiFM_2/04 Research Design/05 Randomization/01 Village/pfm2_randomization.RData')

# Survey Data
master <- read.dta13("01 Data/pfm2_master.dta")

# Village Center Location Data
spdf <- read.csv("01 Data/pfm2_villagesample_surveydates.csv")


# New Variables -----------------------------------------------------------

master$c_religion <- master$churchattendance
master$c_radio_amt <- ifelse(master$b_s4q2_radio == "None", 0, 
                             ifelse(master$b_s4q2_radio == "Less than one hour a day", 1,
                                    ifelse(master$b_s4q2_radio == "1-2 hours a day", 2, 
                                           ifelse(master$b_s4q2_radio == "2-3 hours a day", 3,
                                                  ifelse(master$b_s4q2_radio == "3-4 hours a day", 4,
                                                         ifelse(master$b_s4q2_radio == "More than 4 hours a day", 5, NA))))))
master$c_gh_index[master$c_gh_index < 0] <- 0
master$c_numberofkids[master$c_numberofkids < 0] <- 0
master$c_female = ifelse(master$c_gender == 1, 1, 0)

# Create Radio ------------------------------------------------------------

comply <- master %>% filter(comply_attend == "Yes")

df <- comply %>%
  dplyr::select(district_c, ward_c, village_c,
                c_education_years,
                c_female, 
                c_age, 
                c_married, 
                c_borninvillage,
                c_swahilimain, 
                c_multiplehuts, 
                c_timesincity, 
                c_cellown, 
                c_radio_amt, 
                c_muslim, 
                c_religion,
                c_dadchoosehusband,
                c_believewitchcraft, 
                c_likechange, 
                c_respectauthority) %>%
  drop_na()

name_list <- c("Years of Education", 
               "Female", 
               "Age", 
               "Married", 
               "Born in Village", 
               "Swahili is first language", 
               "Homestead has multiple huts", 
               "Times visited city", 
               "Own cell phone", 
               "Amount listen to radio", 
               "Muslim", 
               "Church/Mosque attendance",
               "Believe father should pick husband", 
               "Believe in witchcraft",
               "Change is generally good", 
               "People should respect authority")

X <- df[,4:length(df)]
covarnum <- length(X)

# Generate Village Averages -----------------------------------------------

df_vill <- df %>%
  select(district_c, ward_c, village_c, starts_with("c_")) %>%
  group_by(district_c, ward_c, village_c) %>%
  summarise_all(mean, na.rm = TRUE)

# Merges ------------------------------------------------------------------

centroid_merge <- merge(spdf, df_vill, 
                        by.x = c("district_c", "ward_c", "village_c"), by.y = c("district_c", "ward_c", "village_c"))



# Create Map --------------------------------------------------------------

# Create GG Map
gmap <- ggmap(get_googlemap(center = c(lon = 38.8482, lat = -5.2565),
                           zoom = 10, scale = 2,
                           maptype ='terrain',
                           color = "bw"))

# Create Plot List
plot_list = list()
colnames <- colnames(X)

for (i in 1:length(X)) {

covar <- colnames[i]
covar <- sym(covar)



# Muslim
map <- gmap + 
  geom_text(colour = "black", aes(label = Letter, fontface="bold", x = villcent_long, y = villcent_lat, size = !!covar), 
                       data = centroid_merge) +
  guides(text = guide_legend(text="STOP"),
         override.aes = aes(label = "")) +
  ylab("") +
  xlab("") +
  labs(size = "name1") +
  theme(axis.text.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks.x=element_blank(),
        axis.ticks.y=element_blank(),
        legend.position = c(0.8, 0.2),
        legend.title = element_text(size=5), legend.text=element_text(size=5)) 
  
plot_list[[i]] = map
}


plot_list[[1]]

# Combine Plots -----------------------------------------------------------

plot_combined <- ggarrange(plotlist = plot_list,
                           ncol = 4, nrow = 4)


plot_combined_annotate <- annotate_figure(plot_combined,
                                          bottom = text_grob(expression(atop("A: Treatment Village in Block A", paste("a: Placebo Village in Block A"))), color = "black",
                                                             hjust = 1, x = 1, face = "italic", size = 10),
                                          left = text_grob("Estimated CATE", color = "black", rot = 90))







plot_combined_annotate









  # Converto Numeric --------------------------------------------------------

sp_sample@data$district_c <- as.numeric(sp_sample@data$district_c)
sp_sample@data$ward_c <- as.numeric(sp_sample@data$ward_c)
sp_sample@data$village_c <- as.numeric(sp_sample@data$village_c)



# Merge -------------------------------------------------------------------

merge <- sp::merge(df_sample, df_vill, all.y = TRUE,
                   by.x = c("district_c", "ward_c", "village_c"), by.y = c("district_c", "ward_c", "village_c"))



# Plot --------------------------------------------------------------------



# Set Parameters ----------------------------------------------------------

border_vills <- "white"
fill_vills <- "grey"
fill_pangani <- "grey70"

fill_control_notselected <- "dodgerblue2"
fill_control_selected <- "dodgerblue4"
villcent_control <- "dodgerblue"

fill_treat_notselected <- "firebrick2"
fill_treat_selected <- "firebrick4"
villcent_treat <- "firebrick1"

fill_pangani <- "dimgrey"
border_pangani <- "dimgrey"

fill_pfm <- "black"
fill_towns <- "black"
fill_road <- "black"

vill_cent <- ""

vills_small <- vills[vills$s_dist_pfm < 100,]
roads_small <- roads[vills_small,]
towns_small <- towns[vills_small,]





# Plot --------------------------------------------------------------------

plot(vills_small, col=fill_vills, border=border_vills, main = paste0("Pangani FM2 Randomization (Villages)"), ylim=c())
plot(roads_small, col = fill_road, add = T)
plot(sp_sample[sp_sample$select == 1 & sp_sample$treat == 0,], col=fill_control_selected, border=border_vills, add= T)
plot(sp_sample[sp_sample$select == 1 & sp_sample$treat == 1,], col=fill_treat_selected, border=border_vills, add= T)
plot(district_pangani, border=border_pangani, lwd=1.4, col = "NA", add = T)

plot(sp_sample_villcent[sp_sample_villcent$treat == 1,], col=villcent_treat, add = T, cex=1, pch='+')
plot(sp_sample_villcent[sp_sample_villcent$treat == 0,], col=villcent_control, add = T, cex=1, pch='+')
  
plot(roads_small, col = fill_road, add = T)
points(towns_small, pch=18, cex=1, col=fill_towns)
points(towns_pangani, pch=18, cex=1.5, col=fill_towns)
text(towns_pangani, labels = "Pangani FM", pos = 4)

# Merge 
 