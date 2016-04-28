################################################################################
# Inclui todas as bibliotecas necessárias
################################################################################
init_library <- function(){
  library(RSQLite)
  library(ggplot2)
  library(ggmap)
  library(dplyr)
  library(maps)
  library(grid)
  library(gridExtra)
  library(scales)
}

################################################################################
# Realiza a instalação de todos os pacotes necessarios
################################################################################
init_packages <- function(){
  install_package(c('RSQLite','ggplot2','ggmap','dplyr','maps','mapdata','gridExtra','scales'))


################################################################################
# Realiza a instalação de todos os pacotes necessarios
################################################################################
install_package <- function(package){
  if(!require(package)) {
    install.packages(package, dependencies = T)
  }
}

################################################################################
# Cria um arquivo no formato PNG 
# * dir = o diretório do arquivo com o arquivo incluído.
# Ex: "./kaggle/us-baby-names/img/teste.png"
################################################################################
create_file_png <- function(ggp, dir, i_width, i_height){
  png(filename= dir, width = i_width, height = i_height)  
  print(ggp)
  dev.off()
}

create_file_csv <- function(MyData, dir){
  write.csv(MyData, file = dir) 
#  write.csv(MyData, file = dir, sep="\t", row.names=FALSE, col.names=FALSE, na="") 
}