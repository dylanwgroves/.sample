
# Introduction ------------------------------------------------------------
# Groves, Green, and Manda
# Radio and Forced Marriage
# Bar Charts


library(ggplot2)
library(readstata13)
library(reshape2)
library(plm)
library(lmtest)
library(dotwhisker)
library(dplyr)
library(readxl)


table1 <- read_xlsx("C:/Users/dylan/Dropbox/Wellspring Tanzania - Audio Screening/03 Tables and Figures/01 Raw/01 Uzikwasa Report/pfm2_uzikwasa_table1.xlsx", sheet = "Sheet1")
  
  meansplot_y <- ggplot(table1, aes(y=mean,x=variable,group=rc_treat)) + 
    geom_bar(position=position_dodge(),stat="identity",aes(fill=factor(rc_treat))) +
    scale_fill_manual(values=c("goldenrod1","dodgerblue2"),name="",labels=c("Control","Treatment"),breaks=c(0,1)) +
    geom_errorbar(aes(ymin=mean-se, ymax=mean+se), width=.25, position=position_dodge(.9)) + 
    ylab("Percent Rejecting") +
    xlab("Primary Outcome Measures") +
    theme_bw() +
    coord_cartesian(ylim=c(0,0.3)) +
    theme(legend.position="top")
  print(meansplot_y)
  
  
  table2 <- read_xlsx("C:/Users/dylan/Dropbox/Wellspring Tanzania - Audio Screening/03 Tables and Figures/01 Raw/01 Uzikwasa Report/pfm2_uzikwasa_table2.xlsx", sheet = "Sheet1")
  
  meansplot_y <- ggplot(table2, aes(y=mean,x=variable,group=rc_treat)) + 
    geom_bar(position=position_dodge(),stat="identity",aes(fill=factor(rc_treat))) +
    scale_fill_manual(values=c("goldenrod1","dodgerblue2"),name="",labels=c("Control","Treatment"),breaks=c(0,1)) +
    geom_errorbar(aes(ymin=mean-se, ymax=mean+se), width=.25, position=position_dodge(.9)) + 
    ylab("Percent Rejecting") +
    xlab("Pre and Post Treatment") +
    theme_bw() +
    coord_cartesian(ylim=c(0,0.4)) +
  theme(legend.position="top")
print(meansplot_y)

table2_wom <- read_xlsx("C:/Users/dylan/Dropbox/Wellspring Tanzania - Audio Screening/03 Tables and Figures/01 Raw/01 Uzikwasa Report/pfm2_uzikwasa_table2_women.xlsx", sheet = "Sheet1")

meansplot_y <- ggplot(table2_wom, aes(y=mean,x=variable,group=rc_treat)) + 
  geom_bar(position=position_dodge(),stat="identity",aes(fill=factor(rc_treat))) +
  scale_fill_manual(values=c("goldenrod1","dodgerblue2"),name="",labels=c("Control","Treatment"),breaks=c(0,1)) +
  geom_errorbar(aes(ymin=mean-se, ymax=mean+se), width=.25, position=position_dodge(.9)) + 
  ylab("Percent Rejecting") +
  xlab("Respondent Type") +
  theme_bw() +
  coord_cartesian(ylim=c(0,0.4)) +
  theme(legend.position="top")
print(meansplot_y)




