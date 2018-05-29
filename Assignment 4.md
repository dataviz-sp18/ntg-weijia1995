# Assignment 4

![image](https://user-images.githubusercontent.com/22485624/40634780-707e45f4-62bc-11e8-85ea-7da582192ebd.png)

### The Story - Why this topic

Sixty-one victims have been shot in Chicago in the first six days of 2017, and 4368 were shot in 2016 alone, according to [Chicago Tribune](http://crime.chicagotribune.com/chicago/). In 2015, the most recent year for which data is available for both cities, the fatal shooting rate in Chicago was five times as high as it was in New York: 15.6 per 100,000 residents compared to 2.8 per 100,000. According to a report by the University of Chicago Crime Lab, there were 762 homicides in 2016, which was about 58 percent more than in the previous year. But homicides were not the only category of crime to rise: other gun offenses, including nonfatal shootings and robberies, soared. 

### The Graph

This graph shows a specific concern on the crimes that include the use of guns, since we believe that wide spread of illegal guns contributes to the escalation of violent crimes in Chicago. We filter the dataset by the ‘Description’ of crimes, which is the subtypes of primary types of crime. The use of weapons is identified in this attribute so we can search for the crimes with handguns and other fire arms. In this data, about 36.6% violent crimes use guns. A density plot is generated to visualize the hot spots of gun crimes. We can see that the south side and west side of Chicago are the most troublesome regions and in the recent three years more gun crimes have happened in the west part. 

I chose a density plot so that it is easier for the audiences to preceive the information that the occurance of a gun crime in some region are more intense than in other parts. I chose the color to be red so it highlight the severeness of the situation. Three density plots align together for the audience to easily capture the change in density of gun crimes in Chicago. For example,  a clear pattern that the crime density in the south part of Chicago decreases significantly.

### Challenges

The major challenge for me to plot this density plot is the installation of the 'ggmap' package. For some reason yet to be clearified, my machine failed to download and install this crucial package which I need to retreive the map of Chicago from Google source. The problem was natually resolved when I clear the R enviornment and restarted R session. The time consumed for the map plot is also longer than other forms of plots that we normally generate; the long waiting period made me confused whether there is a bug in my code. Luckily, the coding process is very smooth.











