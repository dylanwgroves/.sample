
# Introduction ------------------------------------------------------------
# Groves, Green, and Manda
# Radio and Forced Marriage
# Interaction Effects Graph


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
master <- read.dta13("01 Data/pfm2_master.dta")

master$b_fmsupport <- ifelse(master$b_s6q2_gh_marry == "Agree", 1, 
                        ifelse(master$b_s6q2_gh_marry == "Disagree", 0, 1))

# Group Data --------------------------------------------------------------

df <- master %>%
  filter(!is.na(s5q2_gh_marry), !is.na(fm_cogatt_girlchoice)) %>%
  group_by(ward_id, vill_id, treat) %>%
  summarize(fmsupport = 1-mean(as.numeric(fm_cogatt_girlchoice),  na.rm = TRUE), 
            fmreject = mean(as.numeric(fm_cogatt_girlchoice),  na.rm = TRUE),
            b_gh = mean(gh_index, na.rm = TRUE),
            b_fmsupport = mean(as.numeric(b_fmsupport), na.rm = TRUE),
            b_fmreject = 1-mean(as.numeric(b_fmsupport), na.rm = TRUE),
            diff = b_fmsupport - fmsupport)

# Plot --------------------------------------------------------------------

# # Gender Hierarchy Index
# ggplot(df) + 
#   theme_minimal() +
#   scale_fill_grey() +
#   geom_point(size = 4,
#              aes(x = b_gh, 
#                  y = fmsupport, 
#                  shape = as.factor(treat))) + 
#   geom_smooth(method = "lm", 
#               fullrange=TRUE, 
#               colour = "black",
#               aes(x = b_gh, 
#                   y = fmsupport, 
#                   linetype = as.factor(treat))) +
#   ylim(-0.2, 0.5) +
#   xlim(0.5, 0.65) +
#   theme(legend.position="bottom",
#         legend.title=element_blank()) +
#   scale_linetype_manual(values = c(1, 2), 
#                         labels = c("Placebo", "Treatment")) +
#   scale_shape_manual(values = c(16, 2),
#                      labels = c("Placebo", "Treatment")) +
#   labs(x = "Baseline Gender Hierachy Index (Village Mean)", y = "Endline Support for FM (Village Mean)")
# 


interact <- ggplot(df) + 
  theme_minimal() +
  scale_fill_grey() +
  geom_point(size = 4,
             aes(x = b_fmsupport, 
                 y = fmsupport, 
                 shape = as.factor(treat))) + 
  geom_smooth(method = "lm", 
              fullrange=TRUE, 
              colour = "black",
              aes(x = b_fmsupport, 
                  y = fmsupport, 
                  linetype = as.factor(treat))) +
  ylim(-.08, 0.7) +
  xlim(0, 0.53) +
  theme(legend.position="bottom",
        legend.title=element_blank()) +
  scale_linetype_manual(values = c(1, 2), 
                     labels = c("Placebo", "Treatment")) +
  scale_shape_manual(values = c("o", "x"),
                     labels = c("Placebo", "Treatment")) +
  labs(x = "Baseline Support for FM (Village Mean)", y = "Endline Support for FM (Village Mean)")

interact

ggsave("pfm2_interact.pdf", plot = interact, 
       width = 12, height = 8, units = "in")


# FM Reject

interact_alt <- ggplot(df) + 
  theme_minimal() +
  scale_fill_grey() +
  geom_point(size = 4,
             aes(x = b_fmreject, 
                 y = fmreject, 
                 shape = as.factor(treat))) + 
  geom_smooth(method = "lm", 
              fullrange=TRUE, 
              se = F,
              colour = "black",
              aes(x = b_fmreject, 
                  y = fmreject, 
                  linetype = as.factor(treat))) +
  ylim(0.4, 1) +
  xlim(0.4, 1) +
  theme(legend.key = element_rect(fill = NA, color = NA),
        legend.background=element_blank(),
        legend.position="bottom",
        legend.title=element_blank()) +
  scale_linetype_manual(values = c(1, 2), 
                        labels = c("Placebo", "Treatment")) +
  scale_shape_manual(values = c("o", "x"),
                     labels = c("Placebo", "Treatment")) +
  guides(color=guide_legend(override.aes=list(fill=NA))) +
  labs(x = "Baseline Disapproval of FM (Village Mean)", y = "Endline Dissaproval of FM (Village Mean)")

interact_alt

ggsave("pfm2_interact_alt.pdf", plot = interact_alt, 
       width = 12, height = 8, units = "in")
