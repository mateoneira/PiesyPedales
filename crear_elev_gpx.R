##Este script toma un directorio de archivos gpx para crear trayectorias espacio-temporales
##utilizando el eje (z) para representar el tiempo. El resultado es que cada trayerctoria (archivo gpx)
##tiene coordenadas x,y,z, donde z (en metros) representa el tiempo transcurrido (en segundos) desde el
##inicio de la trayectoria.
##El input es un directorio con archivos gpx (sin otro tipo de archivos)
##Script realizado por Mateo Neira (LlactaLAB - Ciudades Sustentables, Universidad de Cuenca)

##To-Do
##Crear un solo archivo de salida
##Parametros para la altura maxima
##Calculo de velocidad y firo
##Colores
##Debug: Error en algunos archivos: 
# "Error in ogrListLayers(files[i]) : Cannot open data source"
# "In addition: There were 50 or more warnings (use warnings() to see the first 50)"

#cargar libreria de rgdal para leer archivos gpx y chron para trabajar con datos de tiempo.

library(chron)
library(rgdal)

#funcion para convertir el tiempo a segundos
segundos <- function(x) {
  hhmmss <- strsplit (x, ":", T)
  hh <- as.numeric (hhmmss[[1]][1])
  mm <- as.numeric (hhmmss[[1]][2])
  ss <- as.numeric (hhmmss[[1]][3])
  return (hh * 60 * 60 + mm * 60 + ss)
}

#funcion crear tiempo
crear_tiempo<-function(x){
  return(paste(substr(x,1,10),substr(x,12,19), sep=" "))
  
}


#Crea trayectorias espacio temporales en 3D
crear_STT3D<-function(directorio){
  #leer todos los archivos de un directorio de entrada
##esto tiene que ser solucionado de otra manera
  #setwd(directorio)
  files<-list.files()
  id<-as.integer(length(files))
  id<-c(1:id)
  print(id)
  
  for (i in id){
    print(i)
    
    #leer archivo gpx
    (layers <- ogrListLayers(files[i]))
    data <- readOGR(files[i], layer=layers[5])
    

    #agregar tiempo en formato tiempo
    data$temp<-substr(data$time, 12, 19)
    data$tiempo<-chron(times=data$temp)
    
    #grabar minimo del valor tiempo
    data$id<-paste(data$track_fid,data$track_seg_id, sep="")
    data$mintime<-with(data,ave(data$tiempo,data$id,FUN=min))
    
    #agregar tiempo reescalado segun minimo
    data$tiempo_E<-as.character(data$tiempo-data$mintime)
    
    #agregar tiempo en segundos
    data$seg<-sapply(data$tiempo_E, segundos)
    
    #cambiar formato tiempo, tiempo debe tener una fecha
    data$time<-paste("2015/02/02", data$tiempo_E, sep=" ")
    
    #crear elevacion a partir de segundos // factor de conversion puede cambiar
    data$ele<-data$seg
    
    #elimnar columnas innecesarias
    data$temp<-NULL
    data$tiempo<-NULL
    data$tiempo_E<-NULL
    data$seg<-NULL
    data$mintime<-NULL
    data$id<-NULL
    
    
    #escribe el nuevo archivo
    if (!file.exists("STT3D")){
            dir.create("STT3D")
            
    }
    nombrearchivo <- strsplit(files[i],"\\.")[[1]]
    nombrenuevo <- paste("./STT3D/",nombrearchivo[[1]], "_STT3D.",nombrearchivo[[2]], sep="")
    writeOGR(data, dsn=nombrenuevo, layer="track_points", driver="GPX", dataset_options="GPX_USE_EXTENSIONS=yes")
  }
  print("acabado!")
}

