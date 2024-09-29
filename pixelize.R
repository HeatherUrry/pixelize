# Author: Heather Urry
# Date: Sept 6, 2020

# Description: This code will read in line drawing png files
# (they must be square) and convert them to pixels.
# It then graphs a scatter plot for the putative relationship
# between daily steps and sleep in hours. It outputs a csv file for each 
# image with data for user-specified number of observations for those two variables
# (defaults to 1000 observations). It also outputs a results csv file that shows 
# the correlation between steps and sleep and a p value for each file.

# This was inspired by "Selective attention in hypothesis-driven data analysis" by Itai Yanai and Martin Lercher
# https://www.biorxiv.org/content/10.1101/2020.07.30.228916v1.full

# user: specify number of observations per data file
obs <- 1000

# load library
library(magick)
library(ggplot2)
library(flexplot)

# set paths
# assumes separate folders located where this script is stored
png_path = "./png/"     # this is the folder containing your png files
data_path = "./data/"   # this is where the data files will be stored
plot_path = "./plots/"  # this is where the plots will be stored

# load in all of the png files
png_files <- dir(png_path,
                 pattern = "*.png",
                 full.names=TRUE) #where you have your files 

# create data frame
result <- as.data.frame(matrix(nrow=length(png_files),ncol=3))
names(result) <- c("file", "r", "p")

for (i in 1:length(png_files)){
  
  # read in the png files
  img <- image_read(png_files[i])

  # convert it to a data frame showing color value at each pixel
  img_points <- as.data.frame(as.matrix(as.raster(img)))
  
  # create data frame showing which pixels are not transparent
  img_binary = data.frame()
  img_binary <- (img_points != "transparent" & img_points != "#ffffffff")
  colnames(img_binary) <- c(1:length(img_points))
  rownames(img_binary) <- c(1:length(img_points))
  
  # create a coordinate space showing x coordinates
  coord <- data.frame(1:length(img_points))
  for (j in 1:length(img_points)){
    coord[j, c(1:length(img_points))] <- c(1:length(img_points))
  }
  
  # multiply the data frame showing which pixels are not transparent
  # times the coordinate space; this will convert all transparent
  # pixels to a value of 0 and the non-transparent pixels to the x-coordinate
  keep <- img_binary*coord
  
  # now create a data frame that shows the row and column coordinates for the non-zero values
  keep <- which(keep!=0,arr.ind = TRUE)
  keepdf <- as.data.frame(keep)
  
  # # rotate by 45 degrees
  # # rotated matrix x and y, respectively: [x+y+1][x+y+n]
  # keepdf$x <- keepdf$row + keepdf$col + 1
  # keepdf$y <- -keepdf$row + keepdf$col + length(coord)
  
  # sample so it looks more like a set of data points
  # set random seed so this is reproducible
  set.seed(8675309); keepdf <-  keepdf[sample(nrow(keepdf), obs), ]
  
  # plot original
  # image is upside down; correct that
  keepdf$row <- length(coord)+1-keepdf$row
  
  # plot(keepdf$col,keepdf$row)
  
  # # plot rotated
  # plot(keepdf$x,keepdf$y)
  
  # scale the two columns so they look more like real sleep and step values
  # total sleep time M and SD taken from https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4342722/
  keepdf$sleep_hrs <- 426.4 + (62.4*scale(keepdf$row, center=TRUE, scale=TRUE))
  keepdf$sleep_hrs <- as.integer(keepdf$sleep_hrs)/60
  
  # daily steps M and SD taken from https://academic.oup.com/ptj/article/87/12/1642/2747262
  keepdf$steps <- 9501 + (2295*scale(keepdf$col, center=TRUE, scale=TRUE))
  keepdf$steps <- as.integer(keepdf$steps)
  
  # calculate the correlation and p value
  cor <- cor.test(keepdf$steps,keepdf$sleep_hrs)
  result[i,"r"] <- cor$estimate
  result[i,"p"] <- cor$p.value
  
  # capture img name
  result[i,"file"] <- substr(png_files[i],nchar(png_path)+1,nchar(png_files[i]))
  
  # record name of data file to be saved
  result[i,"data"] <- paste0("data",i,".csv")
  
  # save data file
  write.csv(keepdf[ , c(3:4)], paste0(data_path,"data",i,".csv"),
            row.names=FALSE)
  
  # save plot
  p <- flexplot(sleep_hrs~steps,data=keepdf,method="lm")
  ggsave(filename=paste0(plot_path,"data",i,"_plot.png"),
         plot=p)
}

# save result file summarizing info about each file
write.csv(result, paste0(data_path,"data_files.csv"),
          row.names = TRUE)

