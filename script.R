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

##1. Lese .CEL-Files
data<- ReadAffy(celfile.path = "/home/anja/Dokumente/Studium/6.Semester/Projektmanagement_im_Softwarebereich/Gruppe_1/input/ND_Group1_133Plus_2")

##2. AffIDs Genen zuordnen
affyids<-featureNames(data)
mapping <- select(hgu133plus2.db, affyids, "GENENAME")
write.table(mapping, row.names=FALSE, quote=FALSE, sep="\t", file="/home/anja/Dokumente/Studium/6.Semester/Projektmanagement_im_Softwarebereich/Gruppe_1/output/genenames.txt")

##3. RMA-Normaliserung
rma_data<-rma(data)
write.exprs(rma_data, file="/home/anja/Dokumente/Studium/6.Semester/Projektmanagement_im_Softwarebereich/Gruppe_1/output/rma_data.txt")

##Ueberpruefe Normalisierung mit:
##3a) Boxplots
#Boxplots of log-intensity distribution are plotted for between-array comparison. The distributions of raw PM (perfect match probes) log-intensities are not expected to be identical but still not totally different while the distributions of normalized (and summarized) probe-set log-intensities are expected to be more comparable if not identical (some normalization methods make the distributions even). Drawing these boxplots before and after normalization allows also checking the normalization step.
jpeg(filename="/home/anja/Dokumente/Studium/6.Semester/Projektmanagement_im_Softwarebereich/Gruppe_1/output/boxplots.jpeg", width=800, height=800, quality=100)
par(mfrow=c(1,2))
boxplot(data)
boxplot(exprs(rma_data))
dev.off()

##3b) Density diagrams
#Vergleich raw data und normalisierter Daten
#Density plots of log-intensity distribution of each array are superposed on a single graph for a better comparison between arrays and for an identification of arrays with weird distribution. As for the boxplots, the density distributions of raw PM (perfect match probes) log-intensities are not expected to be identical but still not totally different while the distributions of normalized probe-set log-intensities are expected to be more. Drawing these plots before and after normalization allows also checking the normalization step.
jpeg(filename="/home/anja/Dokumente/Studium/6.Semester/Projektmanagement_im_Softwarebereich/Gruppe_1/output/histogramme_raw_vs_normalisiert.jpeg", width=800, height=600, quality=100)
par(mfrow=c(1,2))
hist(data, col=1:9, lty=1)   #density plots of log intensities (AffyBatch). 
#plotDensity.AffyBatch(data, col=1:9, lty=1, which=c("both"))  #==plot(density(log2(exprs(data))))
legend("topright", sampleNames(data), col=1:9, lty=rep(1,9), cex=0.7)
plotDensity(exprs(rma_data), lty=1, col =1:9)
legend("topright", sampleNames(data), col=1:9, lty=rep(1,9), cex=0.7)
dev.off()

######Qualitaetskontrolle##########

##4. Microarraybilder
for (i in 1:length(data)){
  jpeg(filename=paste0("/home/anja/Dokumente/Studium/6.Semester/Projektmanagement_im_Softwarebereich/Gruppe_1/output/array",i,".jpeg"), width=2000, height=2000, quality=100)
  image(data[,i])
  dev.off()
}

##5. Histogramme
jpeg(filename="/home/anja/Dokumente/Studium/6.Semester/Projektmanagement_im_Softwarebereich/Gruppe_1/output/histogramme.jpeg", width=800, height=600, quality=100)
par(mfrow=c(1,2))
hist(exprs(rma_data))
hist(log2(mm(data)))
dev.off()

#betrachte Signalverteilung pm, mm und alle
jpeg(filename="/home/anja/Dokumente/Studium/6.Semester/Projektmanagement_im_Softwarebereich/Gruppe_1/output/histogramme_all_pm_mm.jpeg", width=800, height=600, quality=100)
par(mfrow=c(2,2))
hist(data, which=c("both"), main="Sinalintensitaet (pm und mm)", ylim=c(0,1.2))
hist(data, which=c("pm"), main ="Signalintensitaet pm", ylim=c(0,1.2))
hist(data, which=c("mm"), main ="Signalintensitaet mm", ylim=c(0,1.2))
dev.off()

##6. RNA-Degradationsplot
jpeg(filename="/home/anja/Dokumente/Studium/6.Semester/Projektmanagement_im_Softwarebereich/Gruppe_1/output/RNA_degradation.jpeg", width=800, height=800, quality=100)
deg_data<-AffyRNAdeg(data)
plotAffyRNAdeg(deg_data, col=1:9)
legend("topleft", sampleNames(data), col=1:9, lty=rep(1,9), cex=1)
summaryAffyRNAdeg(deg_data)   #slope<5 -> gut
dev.off()

##7. QC-Plot
jpeg(filename="/home/anja/Dokumente/Studium/6.Semester/Projektmanagement_im_Softwarebereich/Gruppe_1/output/qc_plot.jpeg", width=800, height=800, quality=100)
qc_data<-qc(data)
plot(qc_data)
dev.off()

##MA-Plot?



