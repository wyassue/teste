# Variáveis Globais
dir <- "./kaggle/us-baby-names/"
dir_img <- "./kaggle/us-baby-names/img/"
dataName <- "./kaggle/us-baby-names/database.sqlite"
type_gender <- c('F','M')

# A inclusão dos algoritmos 
source('./kaggle/us-baby-names/util.R')
source('./kaggle/us-baby-names/answer.R')

library("dplyr")
library("readr")
library("wordcloud")

#init_packages()
#create_tables()
init_library()
questao11()