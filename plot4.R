library(ggplot2)
library(grid)
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
coalEmissionsByYear = aggregate(list(TotalEmissions = coalNEI$Emissions), by = list(Year = coalNEI$year, Type = coalNEI$type), function(x) sum(x) / 1000)

png('plot4.png', width = 600, height = 500, bg = "gray90")
annotationGrob = grobTree(textGrob("Coal combustion related emission declined\nbetween 1999 and 2008.",
                                   x = 0.3,  y = 0.9, hjust = 0,
                                   gp=gpar(col = "darkmagenta", fontsize = 12, fontface = "bold.italic")))

ggplot(data = coalEmissionsByYear, aes(x = Year, y = TotalEmissions, colour = Type)) +
    geom_line() +
    geom_point() +
    xlab("Year") +
    ylab("Total Emissions (kilotons)") +
    ggtitle(expression('Total Annual PM'[25]*' Emissions for Coal Sources')) +
    scale_x_continuous(breaks=c(1999, 2002, 2005, 2008)) + 
    theme(plot.title = element_text(colour = "darkblue"),
          axis.title = element_text(colour = "darkblue"),
          axis.text = element_text(colour = "darkblue"),
          panel.background = element_rect(fill = 'wheat1'),
          plot.background = element_rect( fill = 'gray90')) +
    annotation_custom(annotationGrob)

graphics.off()