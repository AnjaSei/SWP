#!/usr/bin/env Rscript

#source("http://bioconductor.org/biocLite.R")
#Bioconductor downloads and installs the package
#biocLite("affy")
#biocLite("hgu133plus2cdf")
#biocLite("hgu133plus2.db")
#biocLite("simpleaffy")
#lade Bibliotheken
library(affy)
library(hgu133plus2cdf)       #load package containing an environment representing the HG-U133_Plus_2.cdf file
library(hgu133plus2.db)       #fuer Genannotation
library(simpleaffy)           #fuer Qualitaetsanalyse
library("preprocessCore")

#speichere Kommandozeilenargumente
args = commandArgs(trailingOnly=TRUE)
# pruefe Anzahl der uebergebenen Argumente
if (length(args)!=1 && length(args)!=2) {
  stop("Gebe Pfad zu .Cel files und ggf. Ausgabeordner an!")
}
if (length(args)==1) {
  # setze Standard output Ordner
  args[2] = "output"
}
#ggf. Ausgabeordner erstellen
if (!dir.exists(args[2])){
  dir.create(path=args[2], recursive=TRUE)
}

##1. Lese .CEL-Files
data<- ReadAffy(celfile.path=args[1])

##2. AffIDs Genen zuordnen
affyids<-featureNames(data)
mapping <- select(hgu133plus2.db, affyids, "GENENAME")
write.table(mapping, row.names=FALSE, quote=FALSE, sep="\t", file=paste0(args[2],"/genenames.txt"))

##3. RMA-Normalisierung
rma_data<-rma(data)
write.exprs(rma_data, file=paste0(args[2],"/rma_data.txt"))

##Ueberpruefe Normalisierung mit:
##3a) Boxplots
jpeg(filename=paste0(args[2],"/boxplots.jpeg"), width=800, height=800, quality=100)
par(mfrow=c(1,2))
par(las=2)
boxplot(data, main="raw data", cex.axis=0.3)
boxplot(exprs(rma_data), main="RMA normalisierte Daten", cex.axis=0.3)
dev.off()

##3b) Density diagrams
#Vergleich raw data und normalisierter Daten
jpeg(filename=paste0(args[2],"/histogramme_raw_vs_normalisiert.jpeg"), width=800, height=600, quality=100)
par(mfrow=c(1,2))
hist(data, col=1:9, lty=1)   #density plots of log intensities (AffyBatch). 
legend("topright", sampleNames(data), col=1:9, lty=rep(1,9), cex=0.7)
plotDensity(exprs(rma_data), lty=1, col =1:9)
legend("topright", sampleNames(data), col=1:9, lty=rep(1,9), cex=0.7)
dev.off()

######Qualitaetskontrolle##########

##4. Microarraybilder
for (i in 1:length(data)){
  jpeg(filename=paste0(args[2],"/",sampleNames(data)[i],".jpeg"), width=2000, height=2000, quality=100)
  image(data[,i])
  dev.off()
}

##5. Histogramme
jpeg(filename=paste0(args[2],"/histogramme.jpeg"), width=800, height=600, quality=100)
par(mfrow=c(1,2))
hist(log2(exprs(data)), main="Signalintensitaet raw data")
hist(exprs(rma_data), main="Signalintensitaet RMA-normalisierte Daten")
dev.off()

#betrachte Signalverteilung pm, mm und alle
jpeg(filename=paste0(args[2],"/histogramme_all_pm_mm.jpeg"), width=800, height=600, quality=100)
par(mfrow=c(2,2))
hist(data, which=c("both"), main="Sinalintensitaet (pm und mm)", ylim=c(0,1.2))
hist(data, which=c("pm"), main ="Signalintensitaet pm", ylim=c(0,1.2))
hist(data, which=c("mm"), main ="Signalintensitaet mm", ylim=c(0,1.2))
dev.off()

##6. RNA-Degradationsplot
jpeg(filename=paste0(args[2],"/RNA_degradation.jpeg"), width=800, height=800, quality=100)
deg_data<-AffyRNAdeg(data)
plotAffyRNAdeg(deg_data, col=1:9)
legend("topleft", sampleNames(data), col=1:9, lty=rep(1,9), cex=1)
#summaryAffyRNAdeg(deg_data)   #slope<5 -> gut
dev.off()

##7. QC-Plot
jpeg(filename=paste0(args[2],"/qc_plot.jpeg"), width=800, height=800, quality=100)
qc_data<-qc(data)
plot(qc_data)
dev.off()




