library(ggplot2)
library(grid)

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

png('plot3.png', width = 600, height = 500, bg = "gray90")
annotationGrob = grobTree(textGrob("All emission types declined between\n1999 and 2008 except POINT type emissions.",
                                   x = 0.3,  y = 0.9, hjust = 0,
                            gp=gpar(col = "darkmagenta", fontsize = 12, fontface = "bold.italic")))

ggplot(data = baltimoreEmissionsByYear, aes(x = Year, y = TotalEmissions, colour = Type)) +
    geom_line() +
    geom_point() +
    xlab("Year") +
    ylab(expression('Total PM'[25]*' Emissions (kilotons)')) +
    ggtitle(expression('Total Annual PM'[25]*' Emissions in Baltimore City, MD')) +
    scale_x_continuous(breaks=c(1999, 2002, 2005, 2008)) + 
    theme(plot.title = element_text(colour = "darkblue"),
          axis.title = element_text(colour = "darkblue"),
          axis.text = element_text(colour = "darkblue"),
          panel.background = element_rect(fill = 'wheat1'),
          plot.background = element_rect( fill = 'gray90')) +
    annotation_custom(annotationGrob)

graphics.off()