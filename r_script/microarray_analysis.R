#!/usr/bin/env Rscript
#############################################################
##
## file: microarray_analysis.R
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
#install.packages("gtools")
#install.packages("optparse")
library(VennDiagram)	      #for venn diagrams
library(gtools)		      #to calculate fold change 
library(optparse)	      #to parse command line options

option_list <- list(
   make_option("--input", action="store", help="Folder with CEL. files (mandatory)"),
   make_option("--output", action="store", help="Result folder (voluntary)"),

   make_option("--all", action="store_true", default=FALSE, help="Run full R script"), 
   make_option("--boxplot", action="store_true", default=FALSE, help="Boxplots"),
   make_option("--hist", action="store_true", default=FALSE, help="histograms"),
   make_option("--microarray_img", action="store_true", default=FALSE, help="Microarray images"),
   make_option("--plm", action="store_true", default=FALSE, help="Probe Level Model images"),
   make_option("--heatmap", action="store_true", default=FALSE, help="Heatmaps"),
   make_option("--topo", action="store_true", default=FALSE, help="Topographical images"),
   make_option("--rnadeg", action="store_true", default=FALSE, help="RNA degradation plot"),
   make_option("--qcplot", action="store_true", default=FALSE, help="quality control plot"),
   make_option("--table", action="store_true", default=FALSE, help="Tables with RMA and MAS5 normalized data including max, min, mean, sd, p-value, SLR, FC"),
   make_option("--scatter", action="store_true", default=FALSE, help="scatterplots"),
   make_option("--topgenes", action="store", type="integer", help="Venn diagrams of top differentially expressed genes")

)

opt <- parse_args(OptionParser(option_list=option_list))

#set default output folder
output="output"

#check if inputfolder (with CEL.files) is given
if (length(opt$input)==0) {
  stop("Gebe Pfad zu .Cel files an!")
}
#optional outputfolder is given
if (length(opt$output)>0) {
 output=opt$output
}

#create main output folder
if (!dir.exists(output)){
   dir.create(path=output, recursive=TRUE)
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
  p_value<- apply(cbind(gesund, krank), 1, function(x) {t.test(x[1:3], x[4:9])$p.value }) #calculate p-value (t.test)
  SLR<-gesund_mean-krank_mean #calculate signal log ratio
  FC<-logratio2foldchange(SLR, base=2)  #calculate fold change
  
  #combine intensities and new columns to one data set
  summary<-cbind(summary, gesund_median, krank_median, gesund_mean, krank_mean, gesund_sd, krank_sd, gesund_min, krank_min, gesund_max, krank_max, p_value, FC, SLR)
  write.table(summary, row.names=FALSE, file=paste0(output, "/", outputname, ".txt"), sep="\t", dec=",")
  write.csv(summary, row.names=FALSE, file=paste0(output, "/", outputname,".csv") )
  return(summary);
}

##Create scatterplots
my_scatterplot <- function(x, name, start_column, end_column){
  for (i in start_column:end_column){
    for (j in start_column:end_column){
      jpeg(filename=paste0(output, "/scatterplots/",name,"/", name, "_scatterplot_", colnames(x)[i], "_", colnames(x)[j], ".jpeg"), width=800, height=800, quality=100)
      plot(x[,i], x[,j], xlab=colnames(x)[i], ylab=colnames(x)[j], main="Intensitaetsvergleich" , cex=0.1)
      dev.off()
    }
  }
}

#create venn diagrams
top_genes<-function(rma_table, mas5_table, top_number){
  #nur nach einem Kriterium sortieren
  #23=p_value, 25=FC, 24=SLR
  for (i in 23:25){
    #p-value
    if (colnames(rma_table)[i]=="p_value"){
      rma_top<-rma_table[order(rma_table[,i]),]
      mas5_top<-mas5_table[order(mas5_table[,i]),]
    }
    #SLR or FC
    else if (colnames(rma_table)[i]=="SLR" | colnames(rma_table)[i]=="FC"){
      rma_top<-rma_table[order(abs(rma_table[,i]), decreasing=TRUE),]
      mas5_top<-mas5_table[order(abs(mas5_table[,i]), decreasing=TRUE),]
    }
    else{
        stop("Something went wrong!")
    }
    
    rma_top<-rma_top$SYMBOL[1:top_number]
    mas5_top<-mas5_top$SYMBOL[1:top_number]
    top<-cbind(rma_top, mas5_top)
    
    venn.diagram(list("RMA"=top[,1], "MAS5"=top[,2]), main=paste0("Overlap of differentially expressed genes\n",colnames(rma_table)[i]), main.cex=2, cat.cex=1.5, cat.pos=c(0,0), fill=c("darkgreen", "blue"), cex=1.5, filename=paste0(output,"/venn_diagrams/venn_diagram_", colnames(rma_table)[i],".png"), imagetype="png")
    #write.table(top, row.names=FALSE, file=paste0(output,"/top_",top_number,"_",colnames(rma_table)[i],".txt"), dec=",", sep="\t" )

 
   
     }

  #1=p_value, 2=SLR, 3=FC
  #123
  rma_top<-rma_table[order(abs(rma_table$p_value), -abs(rma_table$SLR), -abs(rma_table$FC)),]
  mas5_top<-mas5_table[order(abs(mas5_table$p_value), -abs(mas5_table$SLR), -abs(mas5_table$FC)),]
  
  rma_top<-rma_top$SYMBOL[1:top_number]
  mas5_top<-mas5_top$SYMBOL[1:top_number]
  top<-cbind(rma_top, mas5_top)
  
  venn.diagram(list("RMA"=top[,1], "MAS5"=top[,2]), main=paste0("Overlap of differentially expressed genes\n p_value SLR FC"),main.cex=2, cat.cex=1.5, cat.pos=c(0,0), fill=c("darkgreen", "blue"), cex=1.5, filename=paste0(output,"/venn_diagrams/venn_diagram_p_value_SLR_FC.png"), imagetype="png")
  
  #132
  rma_top<-rma_table[order(abs(rma_table$p_value), -abs(rma_table$FC), -abs(rma_table$SLR)),]
  mas5_top<-mas5_table[order(abs(mas5_table$p_value), -abs(mas5_table$FC), -abs(mas5_table$SLR)),]

  rma_top<-rma_top$SYMBOL[1:top_number]
  mas5_top<-mas5_top$SYMBOL[1:top_number]
  top<-cbind(rma_top, mas5_top)
  
  venn.diagram(list("RMA"=top[,1], "MAS5"=top[,2]), main=paste0("Overlap of differentially expressed genes\n p_value FC SLR"),main.cex=2, cat.cex=1.5, cat.pos=c(0,0), fill=c("darkgreen", "blue"), cex=1.5, filename=paste0(output,"/venn_diagrams/venn_diagram_p_value_FC_SLR.png"), imagetype="png")
  
  #213
  rma_top<-rma_table[order(-abs(rma_table$SLR), abs(rma_table$p_value), -abs(rma_table$FC)),]
  mas5_top<-mas5_table[order(-abs(mas5_table$SLR), abs(mas5_table$p_value), -abs(mas5_table$FC)),]
  
  rma_top<-rma_top$SYMBOL[1:top_number]
  mas5_top<-mas5_top$SYMBOL[1:top_number]
  top<-cbind(rma_top, mas5_top)
  
  venn.diagram(list("RMA"=top[,1], "MAS5"=top[,2]), main=paste0("Overlap of differentially expressed genes\n SLR p_value FC"),main.cex=2, cat.cex=1.5, cat.pos=c(0,0), fill=c("darkgreen", "blue"), cex=1.5, filename=paste0(output,"/venn_diagrams/venn_diagram_SLR_p_value_FC.png"), imagetype="png")
  
  #231
  rma_top<-rma_table[order(-abs(rma_table$SLR), -abs(rma_table$FC), abs(rma_table$p_value)),]
  mas5_top<-mas5_table[order(-abs(mas5_table$SLR), -abs(mas5_table$FC), abs(mas5_table$p_value)),]
  
  rma_top<-rma_top$SYMBOL[1:top_number]
  mas5_top<-mas5_top$SYMBOL[1:top_number]
  top<-cbind(rma_top, mas5_top)
  
  venn.diagram(list("RMA"=top[,1], "MAS5"=top[,2]), main=paste0("Overlap of differentially expressed genes\n SLR FC p_value"),main.cex=2, cat.cex=1.5, cat.pos=c(0,0), fill=c("darkgreen", "blue"), cex=1.5, filename=paste0(output,"/venn_diagrams/venn_diagram_SLR_FC_p_value.png"), imagetype="png")
  
  
  #312
  rma_top<-rma_table[order(-abs(rma_table$FC), abs(rma_table$p_value), -abs(rma_table$SLR)),]
  mas5_top<-mas5_table[order(-abs(mas5_table$FC), abs(mas5_table$p_value), -abs(mas5_table$SLR)),]
  
  rma_top<-rma_top$SYMBOL[1:top_number]
  mas5_top<-mas5_top$SYMBOL[1:top_number]
  top<-cbind(rma_top, mas5_top)
  
  venn.diagram(list("RMA"=top[,1], "MAS5"=top[,2]), main=paste0("Overlap of differentially expressed genes\n FC p_value SLR"),main.cex=2, cat.cex=1.5, cat.pos=c(0,0), fill=c("darkgreen", "blue"), cex=1.5, filename=paste0(output,"/venn_diagrams/venn_diagram_FC_p_value_SLR.png"), imagetype="png")
  
  #321
  rma_top<-rma_table[order(-abs(rma_table$FC), -abs(rma_table$SLR), abs(rma_table$p_value)),]
  mas5_top<-mas5_table[order(-abs(mas5_table$FC), -abs(mas5_table$SLR), abs(mas5_table$p_value)),]
  
  rma_top<-rma_top$SYMBOL[1:top_number]
  mas5_top<-mas5_top$SYMBOL[1:top_number]
  top<-cbind(rma_top, mas5_top)
  
  venn.diagram(list("RMA"=top[,1], "MAS5"=top[,2]), main=paste0("Overlap of differentially expressed genes\n FC SLR p_value"),main.cex=2, cat.cex=1.5, cat.pos=c(0,0), fill=c("darkgreen", "blue"), cex=1.5, filename=paste0(output,"/venn_diagrams/venn_diagram_FC_SLR_p_value.png"), imagetype="png")
  }

#######################################################################


##Read .CEL files
data<- ReadAffy(celfile.path=opt$input)
raw_data<-log2(exprs(data))

#initialization
rma<-NA
rma_data<-NA

mas5<-NA
mas5_data<-NA

#create normalized data
if(opt$all | opt$boxplot | opt$hist | opt$table | opt$scatter | !is.null(opt$topgenes)){
   ##RMA-Normalization
   rma<-rma(data)
   rma_data<-exprs(rma)

   ##MAS5-Normalization
   mas5<-mas5(data, sc=150)
   mas5_data<-log2(exprs(mas5));
}


if(opt$all | opt$boxplot){

   ##Check Normalization with boxplots
   #compare raw data and normalized data
   jpeg(filename=paste0(output,"/boxplots.jpeg"), width=800, height=800, quality=100)
   par(mfrow=c(1,3))
   boxplot(data, main="raw data", cex.axis=0.3, col="red", las=2)
   boxplot(rma_data, main="RMA normalized data", cex.axis=0.3, col="darkgreen", las=2)
   boxplot(mas5_data, main="MAS5 normalized data", cex.axis=0.3, col="blue", las=2)
   dev.off()
}

if (opt$all | opt$hist){

   dir.create(path=paste0(output,"/histograms/"), recursive=TRUE)

   ##Check Normalization with boxplots
   ## density diagrams
   #compare raw data and normalized data
   jpeg(filename=paste0(output,"/histograms/histograms_raw_vs_normalized.jpeg"), width=800, height=600, quality=100)
   par(mfrow=c(1,3))
   hist(data, main="raw data", col=1:9, lty=1)   #density plots of log intensities (AffyBatch). 
   legend("topright", sampleNames(data), col=1:9, lty=rep(1,9), cex=0.7)
   plotDensity(rma_data, main="RMA normalized data", lty=1, col =1:9)
   legend("topright", sampleNames(data), col=1:9, lty=rep(1,9), cex=0.7)
   plotDensity(mas5_data, main="Mas5 normalized data", lty=1, col =1:9)
   legend("topright", sampleNames(data), col=1:9, lty=rep(1,9), cex=0.7)
   dev.off()

   ##histogram
   jpeg(filename=paste0(output,"/histograms/histogramme.jpeg"), width=800, height=600, quality=100)
   par(mfrow=c(1,3))
   hist(raw_data, main="signal intensity of raw data")
   hist(rma_data, main="signal intensity of RMA-normalized data")
   hist(mas5_data, main="signal intensity of MAS5-normalized data", xlab="log2(mas5_data)")
   dev.off()

   ##signal intensity distribution of pm, mm and both from raw data
   jpeg(filename=paste0(output,"/histograms/histogramme_all_pm_mm.jpeg"), width=800, height=600, quality=100)
   par(mfrow=c(2,2))
   hist(data, which=c("both"), main="signal intensity (pm and mm)", ylim=c(0,1.2))
   hist(data, which=c("pm"), main ="signal intensity pm", ylim=c(0,1.2))
   hist(data, which=c("mm"), main ="signal intensity mm", ylim=c(0,1.2))
   dev.off()

}


##############quality control##################

###microarray images 

##image raw data
if (opt$all | opt$microarray_img){

  dir.create(path=paste0(output,"/microarray_images/"), recursive=TRUE)

  for (i in 1:length(data)){
     jpeg(filename=paste0(output,"/microarray_images/raw_", sampleNames(data)[i],".jpeg"), width=2000, height=2000, quality=100)
     image(data[,i])
     dev.off()
   }
}

##PLM image
if (opt$all | opt$plm){

   dir.create(path=paste0(output,"/plm_images/"), recursive=TRUE)
 
   for (i in 1:length(data)){
     jpeg(filename=paste0(output,"/plm_images/plm_", sampleNames(data)[i],".jpeg"), width=2000, height=2000, quality=100)
     image(fitPLM(data, background.method="RMA.2", normalize.method="quantile"), which=i )    
     dev.off()
   }
}

##heatmap raw data
if (opt$all | opt$heatmap){

   dir.create(path=paste0(output,"/heatmaps/"), recursive=TRUE)

   for (i in 1:length(data)){
     jpeg(filename=paste0(output,"/heatmaps/heatmap_raw_data_", sampleNames(data)[i],".jpeg"), width=2000, height=2000, quality=100)
     image(data[,i], col=heat.colors(100))
     dev.off()
   }
}

##topographical image raw data
if (opt$all | opt$topo){

   dir.create(path=paste0(output,"/topographical_images/"), recursive=TRUE)

   for (i in 1:length(data)){
     jpeg(filename=paste0(output,"/topographical_images/topographical_image_raw_data_", sampleNames(data)[i],".jpeg"), width=2000, height=2000, quality=100)
     image(data[,i], col=topo.colors(100))
     dev.off()
   }
}

##RNA degradation plot
if(opt$all | opt$rnadeg){
   jpeg(filename=paste0(output,"/RNA_degradation.jpeg"), width=800, height=800, quality=100)
   deg_data<-AffyRNAdeg(data)
   plotAffyRNAdeg(deg_data, col=1:9)
   legend("topleft", sampleNames(data), col=1:9, lty=rep(1,9), cex=1)
   summaryAffyRNAdeg(deg_data)   #slope<5 -> good
   dev.off()
}

##QC-Plot
if(opt$all | opt$qcplot){
   jpeg(filename=paste0(output,"/qc_plot.jpeg"), width=800, height=800, quality=100)
   qc_data<-qc(data)
   plot(qc_data)
   dev.off()
}


##############gene expression analysis###############

if(opt$all | opt$table){

   ##MAS 5.0 
   #add median, mean, min, max, sd, p-value, SLR, FC
   mas5_table<-my_table(mas5_data, "table_mas5" )

   ##RMA
   #add median, mean, min, max, sd, p-value, SLR, FC
   rma_table<-my_table(rma_data, "table_rma")

   mas5_calls<-mas5calls(data)
   mas5_calls<-exprs(mas5_calls)
   mas5_calls<-cbind(rownames(mas5_calls), mas5_calls)
   colnames(mas5_calls)[1]<-"PROBEID"

   mas5_table<-merge(x=mas5_table, y=mas5_calls, by="PROBEID" ,all.x=TRUE)
   write.csv(mas5_table, row.names=FALSE, file=paste0(output, "/table_mas5.csv") )

}

##Create scatterplots
if(opt$all | opt$scatter){
   dir.create(path=paste0(output,"/scatterplots/rma/"), recursive=TRUE)
   dir.create(path=paste0(output,"/scatterplots/mas5/"), recursive=TRUE)
   dir.create(path=paste0(output,"/scatterplots/raw/"), recursive=TRUE)

   ##MAS 5.0 
   #add median, mean, min, max, sd, p-value, SLR, FC
   mas5_table<-my_table(mas5_data, "table_mas5" )

   ##RMA
   #add median, mean, min, max, sd, p-value, SLR, FC
   rma_table<-my_table(rma_data, "table_rma")

   my_scatterplot(raw_data, "raw", 1, 9)
   #my_scatterplot(rma_data, "rma", 1, 9)  #full data set 
   my_scatterplot(rma_table, "rma", 3, 11)	#'cleaned' data set
   #my_scatterplot(mas5_data, "mas5", 1, 9) #full data set
   my_scatterplot(mas5_table, "mas5", 3, 11) #'cleaned' data set
}

#select top genes and create venn diagramms
if(opt$all |!is.null(opt$topgenes)){

   dir.create(path=paste0(output,"/venn_diagrams/"), recursive=TRUE)

   ##MAS 5.0 
   #add median, mean, min, max, sd, p-value, SLR, FC
   mas5_table<-my_table(mas5_data, "table_mas5" )

   ##RMA
   #add median, mean, min, max, sd, p-value, SLR, FC
   rma_table<-my_table(rma_data, "table_rma")
	
   #set default value
   if(is.null(opt$topgenes)){
	top_genes(rma_table, mas5_table, 50)
   }

   else{
   	top_genes(rma_table, mas5_table, opt$topgenes)
   }
}







