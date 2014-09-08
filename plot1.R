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
#SCC = readRDS(rdsFile)
totalEmissionsByYear = aggregate(list(TotalEmissions = NEI$Emissions), by = list(Year = NEI$year), function(x) sum(x) / 1000)

png('plot1.png', width = 480, height = 480)
plot(totalEmissionsByYear$Year, totalEmissionsByYear$TotalEmissions, xlab = "Year", ylab = expression('Total PM'[25]*' Annual Emissions (kilotons)'), pch = 20, xaxt="n")
axis(1, at = c(1999, 2002, 2005, 2008));
lines(totalEmissionsByYear$Year, totalEmissionsByYear$TotalEmissions, type = "l")
graphics.off()