# load global options
knitr::opts_chunk$set(echo = TRUE)

# load all related packages
pacman::p_load(pacman, rio,lmerTest, ggplot2, lme4, tidyverse, sjPlot, coefplot2, performance, see, broom.mixed, kableExtra, janitor, ggeffects, dplyr, gridExtra, qqplotr, emmeans, pbkrtest, knitr,ggpubr, here, table1, psych, broom,lsr, rstatix, formatR, RVAideMemoire, labelled, cowplot, readr, svglite, rmcorr, cowplot, grid, gtable, RColorBrewer, extrafont, corrplot, grDevices,icesTAF, gganimate) #

# kable output
options(kableExtra.auto_format = FALSE)

# set up the contrast option for ANOVA
options(contrasts = c("contr.sum","contr.poly"))






### might be useful for future needs

## load fonts
# font_import()
# loadfonts()

## formatting tables
# options(knitr.table.format = 'markdown')


## set up figure sizes
# knitr::opts_chunk$set(fig.width= 3, fig.asp = 0.8, fig.pos = '!h') 
# saved <- options(repr.plot.width=3, repr.plot.height=2) #  ,repr.plot.asp = 0.8