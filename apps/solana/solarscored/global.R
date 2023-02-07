# lunatics
setwd('/Users/kellen/git/user_metrics/apps/solana/solarscored')

library(shiny)
library(data.table)
library(shinyWidgets)
library(reactable)
library(plotly)
library(shinyjs)
library(shinyBS)
library(dplyr)
library(solAttestR)
# library(terraConnectr)

#install.packages("~/user_metrics/apps/solana/solAttestR_0.0.0.9000.tar.gz", repos = NULL, type="source")
#install.packages("~/user_metrics/apps/optimism/opAttestR_0.0.0.9000.tar.gz", repos = NULL, type="source")


#not used:
#library(stringr)
#library(showtext)
#library(htmltools)

rating.max <- 420

#load("data.RData")
file.location <- ifelse(Sys.info()[["user"]] == "rstudio-connect",           
                        "/rstudio-data/solarscored_data.RData",
                        "solarscored_data.RData")
load(file.location)
# print(exists("score.criteria"))
score_criteria <- read.csv('./score_criteria.csv') %>% as.data.table()


round_any <- function(x, accuracy, f=round){f(x/ accuracy) * accuracy}

RemoveNAs <- function(table = dt,
                      na.to = 0) {
  for (j in seq_len(ncol(table)))
    set(table,which(is.na(table[[j]])),j,na.to)
}

Rescale <- function(x, newrange, oldrange = NULL) {
    if(is.null(oldrange)){
      if (is.numeric(x) && is.numeric(newrange)) {
        xna <- is.na(x)
        if (all(xna)) 
          return(x)
        if (any(xna)) 
          xrange <- range(x[!xna])
        else xrange <- range(x)
        if (xrange[1] == xrange[2]) 
          return(x)
        mfac <- (newrange[2] - newrange[1])/(xrange[2] - xrange[1])
        return(newrange[1] + (x - xrange[1]) * mfac)
      } else {
        warning("Only numeric objects can be rescaled")
        return(x)
      }
    } else if(!is.null(oldrange)){
      if (is.numeric(x) && is.numeric(newrange)) {
        xna <- is.na(x)
        if (all(xna)) 
          return(x)
        mfac <- (newrange[2] - newrange[1])/(oldrange[2] - oldrange[1])
        new.vals <- newrange[1] + (x - oldrange[1]) * mfac
        if(length(new.vals[ new.vals > max(newrange)]))
          new.vals[ new.vals > max(newrange)] <- max(newrange)
        if(length(new.vals[ new.vals < min(newrange)]))
          new.vals[ new.vals < min(newrange)] <- min(newrange)
        return(new.vals)
      } else {
        warning("Only numeric objects can be rescaled")
        return(x)
      }
    }
  }


MergeDataFrames <- function(list.of.data.frames,
                            by=NULL,
                            all=NULL){
  if(is.null(by)) stop("You need to explicitly define your 'by' statement")
  if(is.null(all)) {
    all <- FALSE
    message("MergeDataFrames: only complete rows will be returned. Use all=TRUE to return all rows.")
  }
  Reduce(
    function(...) 
      merge(...,
            by=by,
            all=all), 
    list.of.data.frames)
}


# theme_univ3_small <- function(base_size = 12,
#                               bgcolor.dark = "white",
#                               bgcolor.light = "white",
#                               text.color = "white",
#                               title.color = "#white",
#                               lines.color = "#EDEDF3") {
#   half_line <- base_size/2
#   theme(text = element_text(family = 'roboto-mono',
#                             face = "plain",
#                             colour = text.color, size = base_size,
#                             lineheight = 0.9,  hjust = 0.5,
#                             vjust = 0.5, angle = 0, 
#                             margin = margin(), debug = FALSE),
#         
#         plot.background = element_rect(color = NA, fill = "black"), 
#         plot.title = element_text(size = rel(1.2),
#                                   color = title.color,
#                                   margin = margin(b = half_line/2)),
#         
#         strip.background = element_rect(fill = bgcolor.dark, colour = NA),
#         strip.text = element_text(colour = text.color, size = rel(0.8)),
#         strip.text.x = element_text(margin = margin(t = half_line/2,
#                                                     b = half_line/2)), 
#         strip.text.y = element_text(angle = -90, 
#                                     margin = margin(l = half_line/2, 
#                                                     r = half_line/2)),
#         
#         axis.line = element_blank(),
#         axis.ticks.x = element_blank(), 
#         axis.ticks.y = element_blank(), 
#         
#         axis.text = element_text(color = text.color, size = base_size - 2),
#         
#         panel.background = element_rect(fill = "transparent", colour = NA),
#         panel.border = element_blank(),
#         panel.grid.major.x = element_blank(), 
#         panel.grid.major.y = element_blank(), 
#         panel.grid.minor.x = element_blank(),
#         panel.grid.minor.y = element_blank(),
#         
#         legend.background = element_rect(colour = NA, fill = "transparent"), 
#         legend.key = element_rect(colour = NA, fill = "transparent"),
#         
#         axis.title.x=element_blank(),
#         axis.text.x=element_blank(),
#         axis.title.y=element_blank(),
#         axis.text.y=element_blank())
# }
