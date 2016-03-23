
###1. File list

... microarray01.R    enthaelt den Quellcode
... CEL_Files/        Ordner, der die zu analysierenden .CEL Files enthaelt  

###2. Ausfuehren

Speichere den R-Code in einem Verzeichnis deiner Wahl und wechsle in der Kommandozeile zu diesem Verzeichnis.

Der R-Code laesst sich in zwei verschiedenen Modi ausfuehren:  
Mit einem Parameter:	... Parameter 1 gibt das Verzeichnis an, das die .CEL Files beeinhaltet.
                     	... Zum Speichern der Ergebnisse wird im aktuellen Arbeitsverzeichnis der Ordner "output/" angelegt.  
Ausfuehren in der Kommandozeile:  
		        ... Rscript microarray01.R Pfad/zu/CEL_files 
	
Mit zwei Parametern:	... Parameter 1 gibt das Verzeichnis an, das die .CEL Files beeinhaltet.
			... Parameter 2 enthaelt das Verzeichnis, in welchem die Ergebnisse des Programms gespeichert werden sollen.
Ausfuehren in der Kommandozeile:  
      			Rscript microarray01.R /Pfad/zu/CEL_files Pfad/zu/output_folder  


###4. Bemerkungen

Installiere, wenn noch nicht vorhanden, die folgenden packages mit Bioconducter:
source("http://bioconductor.org/biocLite.R")
biocLite("affy")
biocLite("hgu133plus2cdf")
biocLite("hgu133plus2.db")
biocLite("simpleaffy")
biocLite("affyPLM")


