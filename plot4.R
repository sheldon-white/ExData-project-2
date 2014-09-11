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
SCC = readRDS(sccFile)
# find the SCC values for coal
coalSCC = SCC[grepl("^.+Coal$", SCC$EI.Sector),]

# find the coal emissions values
coalNEI = join(NEI, coalSCC, by = c("SCC"), type = "inner")
# aggregate and total by year
coalEmissionsByYear = aggregate(list(TotalEmissions = coalNEI$Emissions), by = list(Year = coalNEI$year), function(x) sum(x) / 1000)

png('plot4.png', width = 600, height = 500, bg = "gray90")
ggplot(data = coalEmissionsByYear, aes(x = Year, y = TotalEmissions)) +
    geom_line() +
    geom_point() +
    xlab("Year") +
    ylab(expression('Total PM'[25]*' Emissions (kilotons)')) +
    ggtitle(expression('Total Annual PM'[25]*' Emissions for Coal Sources in the United States')) +
    scale_x_continuous(breaks=c(1999, 2002, 2005, 2008)) + 
    theme(plot.title = element_text(colour = "darkblue"),
          axis.title = element_text(colour = "darkblue"),
          axis.text = element_text(colour = "darkblue"),
          panel.background = element_rect(fill = 'wheat1'),
          plot.background = element_rect( fill = 'gray90'))
graphics.off()