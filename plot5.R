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
# find the SCC values for motor vehicles
vehiclesSCC = SCC[grepl("^Mobile.+Vehicles$", SCC$EI.Sector),]

# and the emission entries for Baltimore
baltimoreEmissions = subset(NEI, fips == "24510")
# find the intersection (vehicle emissions in Baltimore)
baltimoreVehicleEmissions = join(baltimoreEmissions,
                                 vehiclesSCC,
                                 by = c("SCC"), type = "inner")
# sum the aggregated values by year
emissionsByYear = aggregate(list(TotalEmissions = baltimoreVehicleEmissions$Emissions),
                            by = list(Year = baltimoreVehicleEmissions$year,
                                      Type = baltimoreVehicleEmissions$type),
                            sum)

png('plot5.png', width = 600, height = 500, bg = "gray90")
annotationGrob = grobTree(textGrob("Baltimore vehicle emissions declined\nbetween 1999 and 2008.",
                                   x = 0.3,  y = 0.9, hjust = 0,
                            gp=gpar(col = "darkmagenta", fontsize = 12, fontface = "bold.italic")))

ggplot(data = emissionsByYear, aes(x = Year, y = TotalEmissions, colour = Type)) +
    geom_line() +
    geom_point() +
    xlab("Year") +
    ylab("Total Emissions (tons)") +
    ggtitle(expression('Total Annual PM'[25]*' Vehicle Emissions in Baltimore, MD')) +
    scale_x_continuous(breaks=c(1999, 2002, 2005, 2008)) + 
    theme(plot.title = element_text(colour = "darkblue"),
          axis.title = element_text(colour = "darkblue"),
          axis.text = element_text(colour = "darkblue"),
          panel.background = element_rect(fill = 'wheat1'),
          plot.background = element_rect( fill = 'gray90')) +
    annotation_custom(annotationGrob)

graphics.off()