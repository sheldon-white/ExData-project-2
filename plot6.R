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

# and the emission entries for the cities
baltimoreEmissions = subset(NEI, fips == "24510")
baltimoreEmissions$City = "Baltimore"

LAEmissions = subset(NEI, fips == "06037")
LAEmissions$City = "Los Angeles"
# find the intersection (vehicle emissions in the cities)
baltimoreVehicleEmissions = join(baltimoreEmissions,
                                 vehiclesSCC,
                                 by = c("SCC"), type = "inner")
LAVehicleEmissions = join(LAEmissions,
                                 vehiclesSCC,
                                 by = c("SCC"), type = "inner")
vehicleEmissions = rbind(baltimoreVehicleEmissions, LAVehicleEmissions)
# sum the aggregated values by year
emissionsByYear = aggregate(list(TotalEmissions = vehicleEmissions$Emissions),
                            by = list(Year = vehicleEmissions$year,
                                      City = vehicleEmissions$City),
                            sum)

png('plot6.png', width = 600, height = 500, bg = "gray90")
ggplot(data = emissionsByYear, aes(x = Year, y = TotalEmissions, colour = City)) +
    geom_line() +
    geom_point() +
    xlab("Year") +
    ylab(expression('Total PM'[25]*' Emissions (tons)')) +
    ggtitle(expression('Total Annual PM'[25]*' Vehicle Emissions in LA and Baltimore')) +
    scale_x_continuous(breaks=c(1999, 2002, 2005, 2008)) + 
    theme(plot.title = element_text(colour = "darkblue"),
          axis.title = element_text(colour = "darkblue"),
          axis.text = element_text(colour = "darkblue"),
          panel.background = element_rect(fill = 'wheat1'),
          plot.background = element_rect( fill = 'gray90'))

graphics.off()