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
totalEmissionsByYear = aggregate(list(TotalEmissions = NEI$Emissions), by = list(Year = NEI$year), function(x) sum(x) / 1000)

png('plot1.png', width = 600, height = 500, bg = "gray90")
plot(totalEmissionsByYear$Year, totalEmissionsByYear$TotalEmissions,
     type = "n",
     main = expression('Total Annual PM'[25]*' Emissions for United States'),
     xlab = "Year",
     ylab = expression('Total PM'[25]*' Emissions (kilotons)'),
     xaxt="n",,
     col.main = "darkblue",
     col.axis = "darkblue",
     col.lab = "darkblue",
     font.axis = 3)

rect(par("usr")[1], par("usr")[3], par("usr")[2], par("usr")[4], col = "wheat1")
points(totalEmissionsByYear$Year, totalEmissionsByYear$TotalEmissions, pch = 20)
axis(1, at = c(1999, 2002, 2005, 2008), font.axis = 3, col.axis = "darkblue");
lines(totalEmissionsByYear$Year, totalEmissionsByYear$TotalEmissions, type = "l")
text(2000, 2.0, expression('Total PM'[25]*' Emissions declined between 1999 and 2008.'), col = "darkblue", adj = c(0,0))
graphics.off()