
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
library(ggplot2)
library(rgeos)
library(rgdal)
library(readstata13)
library(RColorBrewer)
library(sf)
library(sp)
library(spData)
library(tidyverse)


# Clear -------------------------------------------------------------------
rm(list=ls())

# Load Data ---------------------------------------------------------------
df <- read.csv("X:/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Audio Screening (efm)/01 Data/pfm2_villagesample_surveydates_dates.csv")



# Set Data Variables ------------------------------------------------------
df$mobilization_start <- as.Date(df$mobilization_start, "%m/%d/%y")
df$baseline_start <- as.Date(df$baseline_start, "%m/%d/%y")
df$baseline_end <- as.Date(df$baseline_end, "%m/%d/%y")
df$screening_invite <- as.Date(df$screening_invite, "%m/%d/%y")
df$screening_event <- as.Date(df$screening_event, "%m/%d/%y")
df$endline_start <- as.Date(df$endline_start, "%m/%d/%y")
df$endline_end <- as.Date(df$endline_end, "%m/%d/%y")
df$endline2_start <- as.Date(df$endline2_start, "%m/%d/%y")
df$endline2_end <- as.Date(df$endline2_end, "%m/%d/%y")

# Prepare GANTT -----------------------------------------------------------
dateRange <- c(min(df$mobilization_start), as.Date("2020-12-31"))
nVills <- length(df$vill_id)
dateSeq <- seq.Date(dateRange[1], dateRange[2], by = 7)

df$uid <- factor(df$uid, levels = df$uid[order(df$baseline_start, df$treat)])
df$uid <- fct_rev(df$uid)

df$census<-rep('census', 30)
df$baseline<-rep('baseline', 30)
df$screening<-rep('screening', 30)
df$endline<-rep('endline', 30)
df$endline2<-rep('endline', 30)

# Make GANTT --------------------------------------------------------------

gantt <- 
  ggplot(df, aes(y=uid, yend=uid)) + 
  theme_minimal()+ 
  geom_segment(size=2, aes(x=mobilization_start, xend = baseline_end, colour = "black")) +
  geom_text(size=3, aes(label=Group, x=screening_event, colour = "grey")) +
  geom_segment(size=2, aes(x=endline_start, xend=endline_end, colour = "grey")) +
  geom_segment(size=2, aes(x=endline2_start, xend=endline2_end, colour = "grey")) + 
  scale_color_manual(labels = c("Census and Baseline", "Endline"), values=c("grey", "black")) +
  labs(x='Date', y='Village') +
  theme(legend.title=element_blank(), 
        legend.position="bottom",
        legend.text=element_text(size=10),
        panel.grid.minor.y=element_blank(),
        panel.grid.major.y=element_blank(),
        axis.text=element_text(size=10),
        axis.title.x = element_text(face="bold", size=12, vjust = -2),
        axis.title.y = element_text(face="bold", size=12, vjust=1))


# Save --------------------------------------------------------------------

ggsave("X:/Dropbox/Apps/Overleaf/Tanzania - Audio Screening (efm)/Figures/pfm2_gantt.pdf", plot = gantt, 
       width = 12, height = 8, units = "in")

