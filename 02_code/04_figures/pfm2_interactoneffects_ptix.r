
# Introduction ------------------------------------------------------------
# Groves, Green, and Manda
# Radio and Forced Marriage
# Interaction Effects Graph


# Libraries ---------------------------------------------------------------


vec.pac= c("foreign", "quantreg", "gbm", "glmnet",
           "MASS", "rpart", "doParallel", "sandwich", "randomForest",
           "nnet", "matrixStats", "xtable", "readstata13", "car", "lfe", "doParallel",
           "caret", "foreach", "multcomp","cowplot")

lapply(vec.pac, require, character.only = TRUE) 

library(data.table)
library(dismo)
library(dplyr)
library(ggplot2)
library(ggpubr)
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

# Create Outcome Measures -------------------------------------------------

master$hiv_prior <- (master$hiv_prior_list+1)/4
master$hiv_elect <- master$hiv_prior_elect
master$hiv_discuss <- master$hiv_discuss

master$fm_prior <- (master$fm_prior_list+1)/4
master$fm_elect <- master$fm_prior_elect
master$fm_discuss <- master$fm_discuss


# Create Treatment Variable -----------------------------------------------

master$hiv_treat <- ifelse(master$treat == 1, 0, 1)
master$fm_treat <- master$treat

# Create Baseline Measures ------------------------------------------------

master$c_religion2 = ifelse(master$b_s3q2_rel_attend >=2, 1, 
                            ifelse(is.na(master$b_s3q2_rel_attend), NA, 0))

master$c_religion7 = ifelse(master$b_s3q2_rel_attend >=7, 1,
                            ifelse(is.na(master$b_s3q2_rel_attend), NA, 0))

master$c_schoolyears =  ifelse(master$b_s2q19_education == "None", 0,
                        ifelse(master$b_s2q19_education == "Kindergaren", 1,
                        ifelse(master$b_s2q19_education == "Standard 1", 2,
                        ifelse(master$b_s2q19_education == "Standard 2", 3,
                        ifelse(master$b_s2q19_education == "Standard 3", 4,
                        ifelse(master$b_s2q19_education == "Standard 4", 5,
                        ifelse(master$b_s2q19_education == "Standard 5", 6,
                        ifelse(master$b_s2q19_education == "Standard 6", 7,
                        ifelse(master$b_s2q19_education == "Standard 7", 8,
                        ifelse(master$b_s2q19_education == "Form 1", 9,
                        ifelse(master$b_s2q19_education == "Form 2", 10,
                        ifelse(master$b_s2q19_education == "Form 3", 11,
                        ifelse(master$b_s2q19_education == "Form 4", 12,
                        ifelse(master$b_s2q19_education == "Form 5", 13,
                        ifelse(master$b_s2q19_education == "Form 6", 14,
                        ifelse(master$b_s2q19_education == "O-Level", 15,
                        ifelse(master$b_s2q19_education == "Professional Certificate", 15,
                        ifelse(master$b_s2q19_education == "Diploma 1", 15,
                        ifelse(master$b_s2q19_education == "Diploma 2", 15,
                        ifelse(master$b_s2q19_education == "Bachelor'2 Degree", 15,
                        ifelse(master$b_s2q19_education == "Masters Degree", 15,
                        ifelse(master$b_s2q19_education == "Informal Training", 14, NA))))))))))))))))))))))
 
master$c_noeqkid =  ifelse(master$b_s6q1_gh_eqkid == "Agree", 1,
                    ifelse(master$b_s6q1_gh_eqkid == "Disagree", 0, NA))   

master$c_dadchoose =  ifelse(master$b_s6q2_gh_marry == "Agree", 1,
                           ifelse(master$b_s6q2_gh_marry == "Disagree", 0, NA))  

master$c_noeqearn =  ifelse(master$b_s6q3_gh_earn == "Yes", 1,
                             ifelse(master$b_s6q3_gh_earn == "No", 0, NA))  

master$c_nofemlead =  ifelse(master$b_s6q4_gh_lead == "Yes", 1,
                            ifelse(master$b_s6q4_gh_lead == "No", 0, NA)) 

master$c_ghindex = (master$c_noeqkid + master$c_dadchoose + master$c_noeqearn + master$c_nofemlead)/4        
                                


# Group Data --------------------------------------------------------------

df_all <- master %>%
  filter(!is.na(fm_prior) & !is.na(fm_elect) & !is.na(fm_discuss) & !is.na(hiv_prior) & !is.na(hiv_elect) & !is.na(hiv_discuss)) %>%
  group_by(ward_id, vill_id, hiv_treat, fm_treat) %>%
  summarize(hiv_conatt_share = mean(hiv_conatt_share/4, na.rm = TRUE),
            hiv_conatt_work = mean(hiv_conatt_work, na.rm = TRUE),
            hiv_cogatt_nosecret = mean(hiv_cogatt_nosecret, na.rm = TRUE),
            fm_cogatt_girlchoice = mean(fm_cogatt_girlchoice, na.rm = TRUE),
            fm_conatt_support = mean(fm_conatt_support, na.rm = TRUE),
            fm_cognorm_story = mean(fm_cognorm_story, na.rm = TRUE),
            fm_conatt_report = mean(hiv_cogatt_nosecret, na.rm = TRUE),
            fm_cognorm_story = mean(hiv_cogatt_nosecret, na.rm = TRUE),
            fm_cogatt_law = mean(hiv_cogatt_nosecret, na.rm = TRUE),
            hiv_prior = mean(hiv_prior, na.rm = TRUE),
            hiv_elect = mean(hiv_elect, na.rm = TRUE),
            hiv_discuss = mean(hiv_discuss, na.rm = TRUE),
            fm_prior = mean(fm_prior, na.rm = TRUE),
            fm_elect = mean(fm_elect, na.rm = TRUE),
            fm_discuss = mean(fm_discuss, na.rm = TRUE),
            b_auth = mean(c_respectauthority, na.rm = TRUE),
            b_elder = mean(c_trustelders, na.rm = TRUE),
            b_change = mean(c_likechange, na.rm = TRUE),
            b_christian = mean(c_christian, na.rm = TRUE),
            b_listenradio = mean(c_anyradio, na.rm = TRUE),
            b_dadchoose = mean(c_dadchoosehusband, na.rm = TRUE),
            b_witchcraft = mean(c_believewitchcraft, na.rm = TRUE),
            b_swahili = mean(c_swahilimain, na.rm = TRUE),
            b_religious = mean(b_s3q2_rel_attend, na.rm = TRUE),
            b_religion2 = mean(c_religion2, na.rm = TRUE),
            b_religion7 = mean(c_religion7, na.rm = TRUE),
            b_vill_dist_town = mean(vill_dist_town, na.rm = TRUE),
            b_hivsafekid = mean(c_hivsafe, na.rm = TRUE),
            b_schoolyears = mean(c_schoolyears, na.rm = TRUE))


# Define Function ---------------------------------------------------------


  plots <- function(het, name, min_dv, max_dv, min_het, max_het, dv1, dv2, dv3, dv4, dv5, dv6) {
  
  # HIV ---------------------------------------------------------------------

  # HIV_Discuss -------------------------------------------------------------
    
  hiv_1 <- ggplot(df) + 
    theme_minimal() +
    scale_fill_grey() +
    geom_point(size = 4,
               aes(x = het, 
                   y = dv1, 
                   shape = as.factor(hiv_treat))) + 
    geom_smooth(method = "lm", 
                fullrange=TRUE, 
                colour = "black",
                aes(x = het, 
                    y = dv1, 
                    linetype = as.factor(hiv_treat))) +
    ylim(min_dv, max_dv) +
    xlim(min_het, max_het) +
    theme(legend.position="bottom",
          legend.title=element_blank()) +
    scale_linetype_manual(values = c(1, 2), 
                       labels = c("Placebo", "Treatment")) +
    scale_shape_manual(values = c("o", "x"),
                       labels = c("Placebo", "Treatment")) +
    labs(x = name, y = "DV")

  
  # HIV_Priority ------------------------------------------------------------
  
  hiv_2 <- ggplot(df) + 
    theme_minimal() +
    scale_fill_grey() +
    geom_point(size = 4,
               aes(x = het, 
                   y = dv2, 
                   shape = as.factor(hiv_treat))) + 
    geom_smooth(method = "lm", 
                fullrange=TRUE, 
                colour = "black",
                aes(x = het, 
                    y = dv2, 
                    linetype = as.factor(hiv_treat))) +
    ylim(min_dv, max_dv) +
    xlim(min_het, max_het) +
    theme(legend.position="bottom",
          legend.title=element_blank()) +
    scale_linetype_manual(values = c(1, 2), 
                          labels = c("Placebo", "Treatment")) +
    scale_shape_manual(values = c("o", "x"),
                       labels = c("Placebo", "Treatment")) +
    labs(x = name, y = "DV")
  
  
  
  # HIV_Elect ---------------------------------------------------------------
  
  hiv_3 <- ggplot(df) + 
    theme_minimal() +
    scale_fill_grey() +
    geom_point(size = 4,
               aes(x = het, 
                   y = dv3, 
                   shape = as.factor(hiv_treat))) + 
    geom_smooth(method = "lm", 
                fullrange=TRUE, 
                colour = "black",
                aes(x = het, 
                    y = dv3, 
                    linetype = as.factor(hiv_treat))) +
    ylim(min_dv, max_dv) +
    xlim(min_het, max_het) +
    theme(legend.position="bottom",
          legend.title=element_blank()) +
    scale_linetype_manual(values = c(1, 2), 
                          labels = c("Placebo", "Treatment")) +
    scale_shape_manual(values = c("o", "x"),
                       labels = c("Placebo", "Treatment")) +
    labs(x = name, y = "DV")
  
  
  # fm ---------------------------------------------------------------------
  
  # fm_Discuss -------------------------------------------------------------
  
  dv = df$fm_discuss
  
  fm_1 <- ggplot(df) + 
    theme_minimal() +
    scale_fill_grey() +
    geom_point(size = 4,
               aes(x = het, 
                   y = dv4, 
                   shape = as.factor(fm_treat))) + 
    geom_smooth(method = "lm", 
                fullrange=TRUE, 
                colour = "black",
                aes(x = het, 
                    y = dv4, 
                    linetype = as.factor(fm_treat))) +
    ylim(min_dv, max_dv) +
    xlim(min_het, max_het) +
    theme(legend.position="bottom",
          legend.title=element_blank()) +
    scale_linetype_manual(values = c(1, 2), 
                          labels = c("Placebo", "Treatment")) +
    scale_shape_manual(values = c("o", "x"),
                       labels = c("Placebo", "Treatment")) +
    labs(x = name, y = "DV")
  
  # fm_Priority ------------------------------------------------------------
  
  dv = df$fm_prior
  
  fm_2 <- ggplot(df) + 
    theme_minimal() +
    scale_fill_grey() +
    geom_point(size = 4,
               aes(x = het, 
                   y = dv5, 
                   shape = as.factor(fm_treat))) + 
    geom_smooth(method = "lm", 
                fullrange=TRUE, 
                colour = "black",
                aes(x = het, 
                    y = dv5, 
                    linetype = as.factor(fm_treat))) +
    ylim(min_dv, max_dv) +
    xlim(min_het, max_het) +
    theme(legend.position="bottom",
          legend.title=element_blank()) +
    scale_linetype_manual(values = c(1, 2), 
                          labels = c("Placebo", "Treatment")) +
    scale_shape_manual(values = c("o", "x"),
                       labels = c("Placebo", "Treatment")) +
    labs(x = name, y = "DV")
  
  
  # fm_Elect ---------------------------------------------------------------
  
  dv = df$fm_elect
  
  fm_3 <- ggplot(df) + 
    theme_minimal() +
    scale_fill_grey() +
    geom_point(size = 4,
               aes(x = het, 
                   y = dv6, 
                   shape = as.factor(fm_treat))) + 
    geom_smooth(method = "lm", 
                fullrange=TRUE, 
                colour = "black",
                aes(x = het, 
                    y = dv6, 
                    linetype = as.factor(fm_treat))) +
    ylim(min_dv, max_dv) +
    xlim(min_het, max_het) +
    theme(legend.position="bottom",
          legend.title=element_blank()) +
    scale_linetype_manual(values = c(1, 2), 
                          labels = c("Placebo", "Treatment")) +
    scale_shape_manual(values = c("o", "x"),
                       labels = c("Placebo", "Treatment")) +
    labs(x = name, y = "DV")
  
  

# Create Plot -------------------------------------------------------------
  
  plot <- ggarrange(hiv_1, hiv_2, hiv_3, fm_1, fm_2, fm_3,
            labels = c("HIV Open - Own Statuts", "HIV Open - Family Share", "HIV Accept - Work", 
                       "Reject FM", "Reject Early FM", "Reject Early FM - Story"),
            ncol = 3, nrow = 2)
  
  plot(plot)
  
  ggsave("03 Tables and Figures/02 Clean/plots_att_schooling.pdf", plot = plot, 
         width = 11, height = 8.5, units = "in")
  
  
}



 # Create Plot -------------------------------------------------------------

df <- df_attend

max(df$b_vill_dist_road)

plots(df$b_schoolyears, "Control", 0.0, 1.1, 3,8, 
      df$hiv_conatt_share, df$hiv_cogatt_nosecret, df$hiv_conatt_work,
      df$fm_cogatt_girlchoice, df$fm_conatt_support, df$fm_cogatt_story)
   





