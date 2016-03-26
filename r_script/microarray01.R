#!/usr/bin/env Rscript
#############################################################
##
## file: microarray01.R
##
## created by: Rascha B., Sevcan G., Anja S.
## created on: March 17, 2016
##
## Description: quality control and data analysis of
##              affymetrix microarray data
##     
## input:   folder with .CEL files
##          path to output folder (optional)
##
## output:  affyids_genenames.txt
##          rma_data.txt
##          boxplots.jpeg
##          histograms_raw_vs_normalized.jpeg
##          raw_microarray_image.jpeg
##          plm_microarray_image.jpeg
##          histogramme.jpeg
##          histogramme_all_pm_mm.jpeg
##          RNA_degradation.jpeg
##          qc_plot.jpeg
##          
##############################################################

#source("http://bioconductor.org/biocLite.R")
#Bioconductor downloads and installs the package
#biocLite("affy")
#biocLite("hgu133plus2cdf")
#biocLite("hgu133plus2.db")
#biocLite("simpleaffy")
#biocLite("affyPLM")
#load libraries
library(affy)                 #methods for Affymetriy Oligonucleotide Arrays
library(hgu133plus2cdf)       #environment representing the HG-U133_Plus_2.cdf file
library(hgu133plus2.db)       #for gene annotation
library(simpleaffy)           #for quality control
library(affyPLM)              #for probe-level model image


#saves command line arguments
args = commandArgs(trailingOnly=TRUE)
#check number of command line arguments
if (length(args)!=1 && length(args)!=2) {
  stop("Gebe Pfad zu .Cel files und ggf. Ausgabeordner an!")
}
if (length(args)==1) {
  # set output folder
  args[2] = "output"
}
#create output folder
if (!dir.exists(args[2])){
  dir.create(path=args[2], recursive=TRUE)
}

##read .CEL files
data<- ReadAffy(celfile.path=args[1])

##select genename for each affyid
affyids<-featureNames(data)
mapping <- select(hgu133plus2.db, affyids, "GENENAME")
write.table(mapping, row.names=FALSE, quote=FALSE, sep="\t", file=paste0(args[2],"/affyids_genenames.txt"))

##RMA-Normalization
rma_data<-rma(data)
write.exprs(rma_data, file=paste0(args[2],"/rma_data.txt"))

##Check RMA-Normalization with:
##a) boxplots
#compare raw data and normalized data
jpeg(filename=paste0(args[2],"/boxplots.jpeg"), width=800, height=800, quality=100)
par(mfrow=c(1,2))
boxplot(data, main="raw data", cex.axis=0.3, col="red", las=2)
boxplot(exprs(rma_data), main="RMA normalized data", cex.axis=0.3, col="green", las=2)
dev.off()

##b) density diagrams
#compare raw data and normalized data
jpeg(filename=paste0(args[2],"/histograms_raw_vs_normalized.jpeg"), width=800, height=600, quality=100)
par(mfrow=c(1,2))
hist(data, main="raw data", col=1:9, lty=1)   #density plots of log intensities (AffyBatch). 
legend("topright", sampleNames(data), col=1:9, lty=rep(1,9), cex=0.7)
plotDensity(exprs(rma_data), main="RMA normalized data", lty=1, col =1:9)
legend("topright", sampleNames(data), col=1:9, lty=rep(1,9), cex=0.7)
dev.off()

######quality control##########

##microarray images 
for (i in 1:length(data)){
  #image raw data
  jpeg(filename=paste0(args[2],"/raw_", sampleNames(data)[i],".jpeg"), width=2000, height=2000, quality=100)
  image(data[,i])
  dev.off()
  #PLM image
  jpeg(filename=paste0(args[2],"/plm_", sampleNames(data)[i],".jpeg"), width=2000, height=2000, quality=100)
  image(fitPLM(data, background.method="RMA.2", normalize.method="quantile"), which=i )    
  dev.off()
}

##histogram
jpeg(filename=paste0(args[2],"/histogramme.jpeg"), width=800, height=600, quality=100)
par(mfrow=c(1,2))
hist(log2(exprs(data)), main="signal intensity of raw data")
hist(exprs(rma_data), main="signal intensity of RMA-normalized data")
dev.off()

#signal intensity distribution of pm, mm and both from raw data
jpeg(filename=paste0(args[2],"/histogramme_all_pm_mm.jpeg"), width=800, height=600, quality=100)
par(mfrow=c(2,2))
hist(data, which=c("both"), main="signal intensity (pm and mm)", ylim=c(0,1.2))
hist(data, which=c("pm"), main ="signal intensity pm", ylim=c(0,1.2))
hist(data, which=c("mm"), main ="signal intensity mm", ylim=c(0,1.2))
dev.off()

##RNA degradation plot
jpeg(filename=paste0(args[2],"/RNA_degradation.jpeg"), width=800, height=800, quality=100)
deg_data<-AffyRNAdeg(data)
plotAffyRNAdeg(deg_data, col=1:9)
legend("topleft", sampleNames(data), col=1:9, lty=rep(1,9), cex=1)
#summaryAffyRNAdeg(deg_data)   #slope<5 -> good
dev.off()

##QC-Plot
jpeg(filename=paste0(args[2],"/qc_plot.jpeg"), width=800, height=800, quality=100)
qc_data<-qc(data)
plot(qc_data)
dev.off()


#create the following table with RMA or MAS5 normalized data
#| PROBEID       | SYMBOL        | CEL.file(1) | CEL.file(2) | ...
#| ------------- |---------------| ------------| ------------| ...
#| 1007_s_at     |DDR1 , MIR4640 | 75,13       | 80.10       | ...

my_table<- function(norm_data, outputname){
  affyids<-rownames(exprs(norm_data));
  mapping <- select(hgu133plus2.db, keys=affyids, columns="SYMBOL")
  mapping[is.na(mapping)]<-"NA"
  table_probeid_symbol<-aggregate(SYMBOL~PROBEID, paste0, collapse=" , ", data=mapping)
  summary<-cbind(table_probeid_symbol, exprs(norm_data))
  write.table(summary, row.names=FALSE, file=paste0(args[2], "/", outputname), sep="\t", dec=",")
}

##RMA
my_table(rma_data, "table_rma.txt")

##MAS 5.0 
mas5_data<-mas5(data, sc=150)
my_table(mas5_data, "table_mas5.txt" )
