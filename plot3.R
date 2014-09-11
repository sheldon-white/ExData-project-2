library(ggplot2)
library(plyr)

# Remote URL where the data lives.
datasetURL = "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
emissionsFile = "summarySCC_PM25.rds"
sccFile = "Source_Classification_Code.rds"

if (!file.exists(emissionsFile) || !file.exists(sccFile) ) {
    message("Retrieving emissions data from '", datasetURL, "'")
    f <- tempfile() 
    download.file(datasetURL, f, method="curl") 
    unzip(f)
}

NEI = readRDS(emissionsFile)
baltimoreEmissions = subset(NEI, fips == "24510")
baltimoreEmissionsByYear = aggregate(list(TotalEmissions = baltimoreEmissions$Emissions), by = list(Year = baltimoreEmissions$year, Type = baltimoreEmissions$type), sum)

diffFunc = function(x) {
    x$diff = x$TotalEmissions[x$Year == 2008] - x$TotalEmissions[x$Year == 1999]
}
emissionsChangeByType = ddply(baltimoreEmissionsByYear, .(Type), diffFunc)
colnames(emissionsChangeByType)[2] = "ChangeInEmissions"

png('plot3.png', width = 600, height = 500, bg = "gray90")
ggplot(data = emissionsChangeByType, aes(x=Type, y=ChangeInEmissions, fill = Type)) +
    geom_bar(stat = "identity") +
    xlab("Emission Type") +
    ylab(expression('total PM'[25]*'(2008) - total PM'[25]*'(1999) (tons)')) +
    theme(plot.title = element_text(colour = "darkblue", hjust = 0.5),
          axis.title = element_text(colour = "darkblue"),
          axis.text = element_text(colour = "darkblue"),
          panel.background = element_rect(fill = 'wheat1'),
          plot.background = element_rect( fill = 'gray90')) +
    labs(title = "Changes in Emissions in Baltimore, MD\nBetween 1999 and 2008")
graphics.off()