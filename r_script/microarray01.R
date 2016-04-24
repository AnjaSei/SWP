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
## output:  description follows...
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

#CRAN packages
#install.packages("VennDiagram")
library(VennDiagram)


#args=c("/home/anja/Dokumente/Studium/6.Semester/Projektmanagement_im_Softwarebereich/Gruppe_1/input/ND_Group1_133Plus_2","/home/anja/Dokumente/Studium/6.Semester/Projektmanagement_im_Softwarebereich/Gruppe_1/output")
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
#create output folders
if (!dir.exists(args[2])){
  dir.create(path=args[2], recursive=TRUE)
  dir.create(path=paste0(args[2],"/scatterplots/rma/"), recursive=TRUE)
  dir.create(path=paste0(args[2],"/scatterplots/mas5/"), recursive=TRUE)
  dir.create(path=paste0(args[2],"/scatterplots/raw/"), recursive=TRUE)
  dir.create(path=paste0(args[2],"/microarray_images/"), recursive=TRUE)
  dir.create(path=paste0(args[2],"/plm_images/"), recursive=TRUE)
  dir.create(path=paste0(args[2],"/heatmaps/"), recursive=TRUE)
  dir.create(path=paste0(args[2],"/topographical_images/"), recursive=TRUE)
  dir.create(path=paste0(args[2],"/histograms/"), recursive=TRUE)
}


#########################Functions#####################################

##Create table with RMA or MAS5 normalized data
my_table<- function(norm_data, outputname){
  affyids<-rownames(norm_data);
  mapping <- select(hgu133plus2.db, keys=affyids, columns="SYMBOL")     #contains affyids and corresponding gene symbol(s)
  mapping[is.na(mapping)]<-"NA"
  mapping<-mapping[which(!duplicated(mapping$PROBEID)),]                #take only the first genesymbol for each affyid
  MEAN_ALL<-apply(norm_data, MARGIN=1, FUN=mean)
  summary<-cbind(mapping, norm_data, MEAN_ALL)
  summary<-summary[summary$SYMBOL!="NA",]                               #delete entries with unknown gene symbols
  summary <- summary[order(summary$SYMBOL, -abs(summary$MEAN_ALL) ), ]  #sort by SYMBOL and reverse of abs(value)
  summary<-summary[which(!duplicated(summary$SYMBOL)), ]    
  
  #select intensities from control group and IFN stimulated group 
  gesund<- cbind(summary$ND_51_CD14_133Plus_2.CEL, summary$ND_52_CD14_133Plus_2.CEL, summary$ND_53_CD14_133Plus_2.CEL);
  krank<- cbind(summary$ND_11_CD14_IFNa2a_90_133Plus_2.CEL, summary$ND_13_CD14_IFNa2a_90_133Plus_2.CEL, summary$ND_5_CD14_IFNa2a_90_133Plus_2.CEL, summary$ND_6_CD14_IFNa2a_90_133Plus_2.CEL, summary$ND_7_CD14_IFNa2a_90_133Plus_2.CEL, summary$ND_8_CD14_IFNa2a_90_133Plus_2.CEL)
  
  #add additional columns
  gesund_median<-apply(gesund, MARGIN=1, FUN=median)
  krank_median<-apply(krank, MARGIN=1, FUN=median)
  gesund_mean<-apply(gesund, MARGIN=1, FUN=mean)
  krank_mean<-apply(krank, MARGIN=1, FUN=mean)
  gesund_sd<-apply(gesund, MARGIN=1, FUN=sd)
  krank_sd<-apply(krank, MARGIN=1, FUN=sd)
  gesund_min<-apply(gesund, MARGIN=1, FUN=min)
  krank_min<-apply(krank, MARGIN=1, FUN=min)
  gesund_max<-apply(gesund, MARGIN=1, FUN=max)
  krank_max<-apply(krank, MARGIN=1, FUN=max)  
  
  #combine intensities and new columns to one data set
  summary<-cbind(summary, gesund_median, krank_median, gesund_mean, krank_mean, gesund_sd, krank_sd, gesund_min, krank_min, gesund_max, krank_max)
  write.table(summary, row.names=FALSE, file=paste0(args[2], "/", outputname), sep="\t", dec=",")
  return(summary);
}


##Create scatterplots
my_scatterplot <- function(x, name, start_column, end_column){
  for (i in start_column:end_column){
    for (j in start_column:end_column){
      jpeg(filename=paste0(args[2], "/scatterplots/",name,"/", name, "_scatterplot_", colnames(x)[i], "_", colnames(x)[j], ".jpeg"), width=800, height=800, quality=100)
      plot(x[,i], x[,j], xlab=colnames(x)[i], ylab=colnames(x)[j], main="Intensitaetsvergleich" , cex=0.1)
      dev.off()
    }
  }
}


##Calculate p-values with t-test
my_p_values <- function(data_table, gesund, krank){
  p_values<-rep(1, nrow(gesund))
  for (i in 1:nrow(gesund)){
    p_values[i]<-t.test(gesund[i,], krank[i,])$p.value
  }
  data_table<-cbind(data_table, p_values)
}

#select genes with lowest p-value -> differentially expressed genes
my_top_genes<-function(data_table, top_number){
  temp<-data_table[order(data_table$p_values),]
  return(temp$SYMBOL[1:top_number]);
  
}


#######################################################################


##Read .CEL files
data<- ReadAffy(celfile.path=args[1])
raw_data<-log2(exprs(data))

##RMA-Normalization
rma<-rma(data)
rma_data<-exprs(rma)

##MAS5-Normalization
mas5<-mas5(data, sc=150)
mas5_data<-log2(exprs(mas5));

##Check Normalization with:
##a) boxplots
#compare raw data and normalized data
jpeg(filename=paste0(args[2],"/boxplots.jpeg"), width=800, height=800, quality=100)
par(mfrow=c(1,3))
boxplot(data, main="raw data", cex.axis=0.3, col="red", las=2)
boxplot(rma_data, main="RMA normalized data", cex.axis=0.3, col="darkgreen", las=2)
boxplot(mas5_data, main="MAS5 normalized data", cex.axis=0.3, col="blue", las=2)
dev.off()

##b) density diagrams
#compare raw data and normalized data
jpeg(filename=paste0(args[2],"/histograms/histograms_raw_vs_normalized.jpeg"), width=800, height=600, quality=100)
par(mfrow=c(1,3))
hist(data, main="raw data", col=1:9, lty=1)   #density plots of log intensities (AffyBatch). 
legend("topright", sampleNames(data), col=1:9, lty=rep(1,9), cex=0.7)
plotDensity(rma_data, main="RMA normalized data", lty=1, col =1:9)
legend("topright", sampleNames(data), col=1:9, lty=rep(1,9), cex=0.7)
plotDensity(mas5_data, main="Mas5 normalized data", lty=1, col =1:9)
legend("topright", sampleNames(data), col=1:9, lty=rep(1,9), cex=0.7)
dev.off()

##############quality control##################

###microarray images 

##image raw data
for (i in 1:length(data)){
  jpeg(filename=paste0(args[2],"/microarray_images/raw_", sampleNames(data)[i],".jpeg"), width=2000, height=2000, quality=100)
  image(data[,i])
  dev.off()
}

##PLM image
for (i in 1:length(data)){
  jpeg(filename=paste0(args[2],"/plm_images/plm_", sampleNames(data)[i],".jpeg"), width=2000, height=2000, quality=100)
  image(fitPLM(data, background.method="RMA.2", normalize.method="quantile"), which=i )    
  dev.off()
}

##heatmap raw data
for (i in 1:length(data)){
  jpeg(filename=paste0(args[2],"/heatmaps/heatmap_raw_data_", sampleNames(data)[i],".jpeg"), width=2000, height=2000, quality=100)
  image(data[,i], col=heat.colors(100))
  dev.off()
}

##topographical image raw data
for (i in 1:length(data)){
  jpeg(filename=paste0(args[2],"/topographical_images/topographical_image_raw_data_", sampleNames(data)[i],".jpeg"), width=2000, height=2000, quality=100)
  image(data[,i], col=topo.colors(100))
  dev.off()
}

##histogram
jpeg(filename=paste0(args[2],"/histograms/histogramme.jpeg"), width=800, height=600, quality=100)
par(mfrow=c(1,3))
hist(raw_data, main="signal intensity of raw data")
hist(rma_data, main="signal intensity of RMA-normalized data")
hist(mas5_data, main="signal intensity of MAS5-normalized data", xlab="log2(mas5_data)")
dev.off()

##signal intensity distribution of pm, mm and both from raw data
jpeg(filename=paste0(args[2],"/histograms/histogramme_all_pm_mm.jpeg"), width=800, height=600, quality=100)
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


##############gene expression analysis###############

##MAS 5.0 
#add median, mean, min, max, sd
mas5_table<-my_table(mas5_data, "table_mas5.txt" )
mas5_gesund<- cbind(mas5_table$ND_51_CD14_133Plus_2.CEL, mas5_table$ND_52_CD14_133Plus_2.CEL, mas5_table$ND_53_CD14_133Plus_2.CEL);
mas5_krank<- cbind(mas5_table$ND_11_CD14_IFNa2a_90_133Plus_2.CEL, mas5_table$ND_13_CD14_IFNa2a_90_133Plus_2.CEL, mas5_table$ND_5_CD14_IFNa2a_90_133Plus_2.CEL, mas5_table$ND_6_CD14_IFNa2a_90_133Plus_2.CEL, mas5_table$ND_7_CD14_IFNa2a_90_133Plus_2.CEL, mas5_table$ND_8_CD14_IFNa2a_90_133Plus_2.CEL)

##RMA
#add median, mean, min, max, sd
rma_table<-my_table(rma_data, "table_rma.txt")
rma_gesund<- cbind(rma_table$ND_51_CD14_133Plus_2.CEL, rma_table$ND_52_CD14_133Plus_2.CEL, rma_table$ND_53_CD14_133Plus_2.CEL);
rma_krank<- cbind(rma_table$ND_11_CD14_IFNa2a_90_133Plus_2.CEL, rma_table$ND_13_CD14_IFNa2a_90_133Plus_2.CEL, rma_table$ND_5_CD14_IFNa2a_90_133Plus_2.CEL, rma_table$ND_6_CD14_IFNa2a_90_133Plus_2.CEL, rma_table$ND_7_CD14_IFNa2a_90_133Plus_2.CEL, rma_table$ND_8_CD14_IFNa2a_90_133Plus_2.CEL)

##Create scatterplots
my_scatterplot(raw_data, "raw", 1, 9)
#my_scatterplot(rma_data, "rma", 1, 9)
my_scatterplot(rma_table, "rma", 3, 11)
#my_scatterplot(mas5_data, "mas5", 1, 9)
my_scatterplot(mas5_table, "mas5", 3, 11)

#add column with p-values to data sets
rma_table<-my_p_values(rma_table, rma_gesund, rma_krank) 
mas5_table<-my_p_values(mas5_table, mas5_gesund, mas5_krank)

#select top X differentially expressed genes
rma_top<-my_top_genes(rma_table, 50)
mas5_top<-my_top_genes(mas5_table, 50)

#draw Venn diagram of the top X differentially expressed genes
venn.diagram(list("RMA"=rma_top, "MAS5"=mas5_top), main="Overlap of differentially expressed genes\n(p-values)", main.cex=2, cat.cex=1.5, cat.pos=c(0,0), fill=c("darkgreen", "blue"), cex=1.5, filename=paste0(args[2],"/venn_diagram_p_values.png"), imagetype="png")
