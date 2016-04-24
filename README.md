
###1. File list

* microarray01.R   enthaelt den Quellcode
* CEL_Files/   Ordner, der die zu analysierenden .CEL Files beeinhaltet

###2. Ausfuehren in der Kommandozeile:  

    Rscript microarray01.R [options] 


Options:

	--input=INPUT
		Folder with CEL. files (mandatory)

	--output=OUTPUT
		Result folder (voluntary)

	--all
		Run full R script

	--boxplot
		Boxplots

	--hist
		histograms

	--microarray_img
		Microarray images

	--plm
		Probe Level Model images

	--heatmap
		Heatmaps

	--topo
		Topographical images

	--rnadeg
		RNA degradation plot

	--qcplot
		quality control plot

	--table
		Tables with RMA and MAS5 normalized data including max, min, mean, sd, p-value, SLR, FC

	--scatter
		scatterplots

	--topgenes=TOPGENES
		Venn diagrams of top differentially expressed genes

	-h, --help
		Show this help message and exit



###3. Bemerkungen

Installiere, wenn noch nicht vorhanden, die folgenden packages:

Bioconducter:  
source("http://bioconductor.org/biocLite.R")  
biocLite("affy")  
biocLite("hgu133plus2cdf")  
biocLite("hgu133plus2.db")  
biocLite("simpleaffy")  
biocLite("affyPLM")  

CRAN packages
install.packages("VennDiagram")
install.packages("gtools")
install.packages("optparse")


Zum Ausfuehren des Programmes ist die (derzeit) aktuellste R-Version 3.2.4 erforderlich.


