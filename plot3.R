library(ggplot2)

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

png('plot3.png', width = 480, height = 480, bg = "gray90")
ggplot(data = baltimoreEmissionsByYear, aes(x=Year, y=TotalEmissions, colour=Type)) +
    geom_line() +
    geom_point() +
    xlab("Year") +
    ylab("Total Emissions (tons)") +
    ggtitle(expression('Total Annual PM'[25]*' Emissions in Baltimore City, MD')) +
    scale_x_continuous(breaks=c(1999, 2002, 2005, 2008))
graphics.off()