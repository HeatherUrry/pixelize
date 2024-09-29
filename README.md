# pixelize
The pixelize.R script creates xy data based on black and white square png files. It will read in line drawing png files (they must be square) and convert them to pixels. It then graphs a scatter plot for the putative relationship between daily steps and sleep in hours using simulated data that mimic the image shown in the png file. It outputs a csv file for each image with data for user-specified number of observations for those two variables (defaults to 1000 observations). It also outputs a ./data/data_files.csv file that shows the correlation between steps and sleep and a p value for each file. 

The idea was inspired by "Selective attention in hypothesis-driven data analysis" by Itai Yanai and Martin Lercher, https://www.biorxiv.org/content/10.1101/2020.07.30.228916v1.full. 

Always looks at your data!

## Example png

![always_look](https://github.com/user-attachments/assets/f980ca1e-6d84-429b-97aa-8a654bab4482)

## Example plot of the above png

![data4_plot](https://github.com/user-attachments/assets/65a25664-c41f-441d-b1a0-c938970eb6c5)



