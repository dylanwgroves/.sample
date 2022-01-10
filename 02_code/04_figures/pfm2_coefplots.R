  
# Purpose: 1. Create coefficient plots for main outcomes for science submission.  
# Author:  Peter Lugthart, Northwestern/GPRL; peter.lugthart@northwestern.edu
# Date created: 12Mar2019
# Date last modified: 05dec2019
# Inputs:
# Outputs: 
# NOTES: 
# See for themes: https://ggplot2.tidyverse.org/reference/ggtheme.html 
# See for shapes https://plot.ly/ggplot2/aes/ 
# https://www.rstudio.com/wp-content/uploads/2015/03/ggplot2-cheatsheet.pdf 
# http://www.cookbook-r.com/Graphs/Shapes_and_line_types/

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#SET PATH TO THE TOP-LEVEL NAMIBIA FOLDER ON YOUR COMPUTER
shared.namibia <- 'X:/Dropbox/Shared Namibia'
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

#LOAD PACKAGES 
#install.packages("ggplot2")
#install.packages("readstata13")
#install.packages("reshape2")
#install.packages("plm")
#install.packages("lmtest")
#install.packages("dplyr")
#install.packages("dotwhisker") 
#install.packages("readxl")
#install.packages("tidyverse")
#install.packages("tibble")
#install.packages("rlang")
#install.packages("stringr")
#install.packages("readxl")

library(tidyverse)
library(ggplot2)
library(readstata13)
library(reshape2)
library(plm)
library(lmtest)
library(dotwhisker)
library(dplyr)
library(readxl)


# A.1 Load regression results, using .txt verison
t1 <- read_excel(paste0("09 Presentations/Manda 2020/coefplot_main.xls"), sheet = "main")                #Behavioral 1 

#----------------------------
# A.2 Reformat behavioral 1 dataset: 
t1 <- t1[,c(1:3) ]                      #transpose and drop unnecessary rows 
colnames(t1) <- c("var_name", "estimate", "std.error")  #rename columns
t1 <- as.data.frame(t1)                             #set as data frame 
t1 <- mutate(t1, model="Treatment effect")  #create new column for the model variable
t1$estimate <- gsub("[*]", "", t1$estimate)        #Clean up entries for "estimate" so that they are purely numeric 
t1$std.error <- gsub("[()]","", t1$std.error)     #Clean up entries for "std.error" so that they are purely numeric  
t1$estimate <- as.numeric(t1$estimate)*100              #set the estimate as numeric
t1$std.error <- as.numeric(t1$std.error)*100            #set the std error as numeric
term <- c("Reject FM",                        #Create a list of the term names and combine with t1 dataset
          "Reject EFM",
          "Reject EFM (Vignette)",
          "Anti-EFM Norm (Vignette")       
main <- data.frame(t1, term)                          #Combine the dataframe with the term names 

# Make the coefficient plot 
main_plot <- dw_plot(main, 
                    dot_args=list(aes(shape=model), colour = "purple4", size=4),
                    whisker_args=list(size=1, colour = "purple4")) + 
  theme_classic() +
  geom_vline(xintercept = 0, colour = "grey60", linetype = 2) +
  xlab("Percentage Point Change") +
  ylab("Anti-EFM Attitudes") +
  xlim(-15,15) +
  theme(text = element_text(size=19),
        plot.title = element_text(size=15),
        axis.title.x = element_text(vjust=-0.5),
        legend.position = "none")

ggsave("09 Presentations/Manda 2020/pfm2_coefplot_main.pdf", plot = main_plot, 
       width = 12, height = 8, units = "in")


plot(main_plot)


# Reporting ---------------------------------------------------------------



# A.1 Load regression results, using .txt verison
t2 <- read_excel(paste0("09 Presentations/Manda 2020/coefplot_main.xls"), sheet = "report")                #Behavioral 1 

 
t2 <- t2[,c(1:3) ]                      #transpose and drop unnecessary rows 
colnames(t2) <- c("var_name", "estimate", "std.error")  #rename columns
t2 <- as.data.frame(t2)                             #set as data frame 
t2 <- mutate(t2, model="Treatment effect")  #create new column for the model variable
t2$estimate <- gsub("[*]", "", t2$estimate)        #Clean up entries for "estimate" so that they are purely numeric 
t2$std.error <- gsub("[()]","", t2$std.error)     #Clean up entries for "std.error" so that they are purely numeric  
t2$estimate <- as.numeric(t2$estimate)*100              #set the estimate as numeric
t2$std.error <- as.numeric(t2$std.error)*100            #set the std error as numeric
term <- c("Would Report EFM",                        #Create a list of the term names and combine with t2 dataset
          "Community Would Report EFM")       
report <- data.frame(t2, term)                          #Combine the dataframe with the term names 

# Make the coefficient plot 
report_plot <- dw_plot(report, 
                     dot_args=list(aes(shape=model), colour = "purple4", size=4),
                     whisker_args=list(size=1, colour = "purple4")) + 
  theme_classic() +
  geom_vline(xintercept = 0, colour = "grey60", linetype = 2) +
  xlab("Percentage Point Change") +
  ylab("Willing to Report EFM") +
  xlim(-15,15) +
  theme(text = element_text(size=19),
        plot.title = element_text(size=15),
        axis.title.x = element_text(vjust=-0.5),
        legend.position = "none")

ggsave("09 Presentations/Manda 2020/pfm2_coefplot_report.pdf", plot = report_plot, 
       width = 12, height = 8, units = "in")

# Reporting ---------------------------------------------------------------

t3 <- read_excel(paste0("09 Presentations/Manda 2020/coefplot_main.xls"), sheet = "policy")                #Behavioral 1 

t3 <- t3[,c(1:3) ]                      #transpose and drop unnecessary rows 
colnames(t3) <- c("var_name", "estimate", "std.error")  #rename columns
t3 <- as.data.frame(t3)                             #set as data frame 
t3 <- mutate(t3, model="Treatment effect")  #create new column for the model variable
t3$estimate <- gsub("[*]", "", t3$estimate)        #Clean up entries for "estimate" so that they are purely numeric 
t3$std.error <- gsub("[()]","", t3$std.error)     #Clean up entries for "std.error" so that they are purely numeric  
t3$estimate <- as.numeric(t3$estimate)*100              #set the estimate as numeric
t3$std.error <- as.numeric(t3$std.error)*100            #set the std error as numeric
term <- c("Vote for Anti-EFM Candidate",                        #Create a list of the term names and combine with t3 dataset
          "Support EFM Ban")
policy <- data.frame(t3, term)                          #Combine the dataframe with the term names 

# Make the coefficient plot 
policy_plot <- dw_plot(policy, 
                       dot_args=list(aes(shape=model), colour = "purple4", size=4),
                       whisker_args=list(size=1, colour = "purple4")) + 
  theme_classic() +
  geom_vline(xintercept = 0, colour = "grey60", linetype = 2) +
  xlab("Percentage Point Change") +
  ylab("Anti-EFM Policy Support") +
  xlim(-15,15) +
  theme(text = element_text(size=19),
        plot.title = element_text(size=15),
        axis.title.x = element_text(vjust=-0.5),
        legend.position = "none")

ggsave("09 Presentations/Manda 2020/pfm2_coefplot_policy.pdf", plot = policy_plot, 
       width = 12, height = 8, units = "in")



# Gender Hierarchy --------------------------------------------------------


t4 <- read_excel(paste0("09 Presentations/Manda 2020/coefplot_main.xls"), sheet = "GH")                #Behavioral 1 

t4 <- t4[,c(1:3) ]                      #transpose and drop unnecessary rows 
colnames(t4) <- c("var_name", "estimate", "std.error")  #rename columns
t4 <- as.data.frame(t4)                             #set as data frame 
t4 <- mutate(t4, model="Treatment effect")  #create new column for the model variable
t4$estimate <- gsub("[*]", "", t4$estimate)        #Clean up entries for "estimate" so that they are purely numeric 
t4$std.error <- gsub("[()]","", t4$std.error)     #Clean up entries for "std.error" so that they are purely numeric  
t4$estimate <- as.numeric(t4$estimate)*100              #set the estimate as numeric
t4$std.error <- as.numeric(t4$std.error)*100            #set the std error as numeric
term <- c("Gender Hierarchy Index",                        #Create a list of the term names and combine with t4 dataset
          "IPV Acceptance Index",
          "IPV Reporting",
          "IPV Reporting Norm",
          "IPV Acceptance Norm")
gh <- data.frame(t4, term)                          #Combine the dataframe with the term names 

# Make the coefficient plot 
gh_plot <- dw_plot(gh, 
                   dot_args=list(aes(shape=model), colour = "purple4", size=4),
                   whisker_args=list(size=1, colour = "purple4")) + 
  theme_classic() +
  geom_vline(xintercept = 0, colour = "grey60", linetype = 2) +
  xlab("Percentage Point Change") +
  ylab("Anti-EFM gh Support") +
  xlim(-15,15) +
  theme(text = element_text(size=19),
        plot.title = element_text(size=15),
        axis.title.x = element_text(vjust=-0.5),
        legend.position = "none")

ggsave("09 Presentations/Manda 2020/pfm2_coefplot_gh.pdf", plot = gh_plot, 
       width = 12, height = 8, units = "in")
View(report)





