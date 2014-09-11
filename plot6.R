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

diffFunc = function(x) {
    x$diff = x$TotalEmissions[x$Year == 2008] - x$TotalEmissions[x$Year == 1999]
}

emissionsChangeByCity = ddply(emissionsByYear, .(City), diffFunc)
colnames(emissionsChangeByCity)[2] = "ChangeInEmissions"

png('plot6.png', width = 600, height = 500, bg = "gray90")
ggplot(data = emissionsChangeByCity, aes(x=City, y=abs(ChangeInEmissions), fill = City)) +
    geom_bar(stat = "identity") +
    xlab("") +
    ylab(expression('abs(total PM'[25]*'(2008) - total PM'[25]*'(1999)) (tons)')) +
    theme(plot.title = element_text(colour = "darkblue", hjust = 0.5),
          axis.title = element_text(colour = "darkblue"),
          axis.text = element_text(colour = "darkblue"),
          panel.background = element_rect(fill = 'wheat1'),
          plot.background = element_rect( fill = 'gray90')) +
    labs(title = "Magnitude of Changes in Vehicle Emissions in Baltimore and Los Angeles\nBetween 1999 and 2008")
graphics.off()