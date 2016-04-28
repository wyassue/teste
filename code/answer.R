################################################################################
# Exibe um gráfico com a número de variações de nome por gênero a cada ano
################################################################################
questao1 <- function(){
  db <- dbConnect(dbDriver("SQLite"), dbname=dataName) 
  query<-"WITH YearOld AS (
    SELECT Year From NationalNames GROUP BY Year
  )
  SELECT NationalNames.* FROM NationalNames 
    JOIN YearOld ON YearOld.Year = NationalNames.Year"
  result <- dbGetQuery(db, query)
  
  plot.title = "Variedade dos nomes por gênero"
  plot.subtitle = "Variedade dos nomes por gênero durante 1880 a 2014"

  ggp <- ggplot(result, aes(x=Year, fill=Gender)) + 
    geom_histogram(alpha=0.6, binwidth = 1) + facet_wrap(~Gender) +
    scale_x_continuous("Ano",breaks=seq(1880,2015,by=15)) +
    scale_y_continuous("Quantidade de registros", breaks=seq(0,30000,by=5000)) + 
    ggtitle(bquote(atop(bold(.(plot.title)), atop(italic(.(plot.subtitle)))))) + 
    labs(fill="Gênero")
  
  create_file_png(ggp, paste(dir_img,"answer1.png"), 680, 200)
  dbDisconnect(db)
}

################################################################################
# Pesquisa os nomes mais populares por gênero e monta as visualizações
################################################################################
questao2 <- function(){
  limit <- 10
  gender = c('F','M')
  db <- dbConnect(dbDriver("SQLite"), dbname=dataName)
  
  for (g in gender) {
    query <- sprintf("WITH Top10M AS (
      SELECT Name, SUM(Count) AS Total FROM NationalNames 
      WHERE Gender = '%s'
      GROUP BY Name ORDER BY Total DESC LIMIT %s
    ) 
    SELECT NationalNames.Name,NationalNames.Year, NationalNames.Count FROM Top10M 
      JOIN NationalNames ON
        NationalNames.Name = Top10M.Name AND NationalNames.Gender ='%s'", g, limit, g)
    result <- dbGetQuery(db, query)
    
    title <- sprintf("Top %s - Nomes feminismos", limit)
    if(g == 'M'){
      title <- sprintf("Top %s - Nomes masculinos", limit)
    }
    answer_2_plot1(result, sprintf("answer2_%s_v1.png", g), sprintf("%s", title))
    answer_2_plot2(result, sprintf("answer2_%s_v2.png", g), sprintf("%s", title))
  }
  dbDisconnect(db) 
}

################################################################################
# Cria uma visualização com os nomes mais populares dos USA - gráfico 1
################################################################################
answer_2_plot1 <- function(result, filename, i_title){
  plot.title = sprintf("%s", i_title)
  plot.subtitle = "Os nomes mais populares do Estados Unidos"
  
  ggp <- ggplot(result, aes(x=Year, y=Count, fill= Name)) + 
    geom_line(aes(color = Name)) + 
    scale_x_continuous(name='Ano', breaks=seq(1880, 2015, by=15)) + 
    scale_y_continuous(name='Quantidade de registros', breaks = seq(0, 100000, by=25000)) + 
    ggtitle(bquote(atop(bold(.(plot.title)), atop(italic(.(plot.subtitle)))))) + 
    labs(color="Nome")
    
  create_file_png(ggp, paste(dir_img,filename), 680, 400)
}

################################################################################
# Cria uma visualização com os nomes mais populares dos USA - gráfico 2
################################################################################
answer_2_plot2 <- function(result, filename,i_title){
  plot.title = sprintf("%s", i_title)
  plot.subtitle = "Os nomes mais populares do Estados Unidos"

  ggp <- ggplot(result, aes(x=Year, y=Count)) + 
    geom_line(aes(color = Name)) + facet_wrap(~Name, ncol=5) + 
    scale_x_continuous("Ano", breaks=seq(1880,2015,by=45)) + 
    scale_y_continuous("Quantidade de registros", breaks=seq(0, 90000, by=30000)) +
    ggtitle(bquote(atop(bold(.(plot.title)), atop(italic(.(plot.subtitle)))))) + 
    labs(color="Nome")
  create_file_png(ggp, paste(dir_img,filename), 680, 300)
}

################################################################################
# Soma todos os registros de cada ano por gênero e cria o gráfico
################################################################################
questao3 <- function(){
  
  db <- dbConnect(dbDriver("SQLite"), dbname=dataName) 
  query<-"WITH YearOld AS (
    SELECT Year From NationalNames GROUP BY Year
  )
  SELECT NationalNames.Year, NationalNames.Gender, SUM(Count) AS Total FROM NationalNames 
    JOIN YearOld ON 
      YearOld.Year = NationalNames.Year
    GROUP BY NationalNames.Year, Gender"
  result <- dbGetQuery(db, query)
print(result)
  max_count <- summary(result$Total)['Max.']
  plot.title = "Quantidade de registros de cada gênero por ano"
  plot.subtitle = "Registros de 1880 a 2014 dos Estados Unidos"
  
  # Gráfico com barras
  ggp <- ggplot(result, aes(x=Year,y=Total, fill=Gender)) + 
    geom_bar(stat="identity", colour="white") +
    scale_x_continuous("Ano",breaks=seq(1880,2015,by=4)) +
    scale_y_continuous("Quantidade de registros", limits=c(0, max_count)) + 
    ggtitle(bquote(atop(bold(.(plot.title)), atop(italic(.(plot.subtitle)))))) + 
    labs(fill="Gênero") + facet_grid(Gender~.)

  create_file_png(ggp, paste(dir_img,"answer3.png"), 680, 400)
  create_file_csv(result, paste(dir, sprintf("csv/answer3.csv"), sep=''))
  dbDisconnect(db)    
}

################################################################################
# Quantidade de registros divididos em gerações.
################################################################################
questao4 <- function(){
  
  db <- dbConnect(dbDriver("SQLite"), dbname=dataName) 
  query<-"WITH YearOld AS (
    SELECT Year From NationalNames GROUP BY Year
  )
  SELECT NationalNames.Year, NationalNames.Gender, SUM(Count) AS Total, Generation.Name AS Generation 
      FROM NationalNames 
    JOIN YearOld ON YearOld.Year = NationalNames.Year
    JOIN Generation ON NationalNames.Year BETWEEN Generation.YearIni AND Generation.YearEnd
    GROUP BY NationalNames.Year, Gender"
  result <- dbGetQuery(db, query)
  
  max_count <- summary(result$Total)['Max.']
  plot.title = "Gerações Americanas 1880-2015"
  plot.subtitle = "Quantidade de registros de cada gênero por ano divido por gerações"
    
  ggp <- ggplot(data=result, aes(x=Year, y=Total, color=Generation, fill=Gender)) + 
    geom_line(alpha=.25) + 
    geom_point(aes(shape=Gender), size=2) + 
    scale_x_continuous("Ano", breaks=seq(1880, 2015, by=15)) + 
    scale_y_continuous("Quantidade de registros", limits=c(0, max_count)) + 
    ggtitle(bquote(atop(bold(.(plot.title)), atop(italic(.(plot.subtitle)))))) + 
    labs(shape = "Gênero", fill="Gênero",color= "Geração")
  
  create_file_png(ggp, paste(dir_img,"answer4.png"), 680, 400)
  dbDisconnect(db)    
}

################################################################################
# Retorna os X (Limit) nomes mais citados de acordo com a geração (Generation) e gênero(Gender)
# * No contexto nacional.
################################################################################
top_national_generation <- function(Gender, Generation, YearIni, YearEnd, Limit){
  db <- dbConnect(dbDriver("SQLite"), dataName)
  query <- paste("SELECT Name, Gender, SUM(Count) AS Total, '",Generation,"' AS Generation FROM NationalNames 
      WHERE Gender = '", Gender,"' AND Year BETWEEN ", YearIni, " AND ", YearEnd, "
       GROUP BY Name ORDER BY Total DESC LIMIT ", Limit, sep="")  
  result <- dbGetQuery(db, query)
  result$Position <- seq_len(nrow(result))

  return(result)
}


################################################################################
# Para cada gênero selecionamos os nomes que tiveram algumo pico durante algum momento.
# Restrição: 
# * O total de registros do nome deverá ultrapassar 1000 registros.
# * Não poderá ser um registro único.
################################################################################
questao6 <- function(limit=20){

  db <- dbConnect(dbDriver("SQLite"), dataName)
  for (g in type_gender) {
    query <- sprintf('SELECT Name, MIN(Year) AS MinYear, MAX(Year) AS MaxYear,
          MAX(Count) AS MaxCount, SUM(Count) AS SumCount
        FROM NationalNames WHERE Gender="%s"
        GROUP BY Name ORDER BY MaxCount DESC', g)
    result <- dbGetQuery(db,query)
    
    # Inclui uma nova coluna Perc(Percentual)
    result <- result %>% 
      filter(SumCount > 1000, MaxCount != SumCount) %>% 
      mutate(Perc = MaxCount/SumCount) %>% 
      arrange(desc(Perc))
    
    for (i in 1:nrow(head(result, n=limit))) {
      buscar_nome(result$Name[i], g, 680,150)
    }
    create_file_csv(result, paste(dir, sprintf("csv/answer5_%s.csv", g), sep=''))
  }
  dbDisconnect(db)
}

################################################################################
# Realiza uma busca por nome e gênero em nível nacional
################################################################################
buscar_nome <- function(name, gender, width=680,height=150,limit=3){
  
  db <- dbConnect(dbDriver("SQLite"), dbname=dataName) 
  query <- sprintf('SELECT * FROM NationalNames WHERE Name LIKE "%s" AND Gender="%s"', name, gender)  
  result <- dbGetQuery(db,query)
  
  max_year <- summary(result$Year)['Max.']
  min_year <- summary(result$Year)['Min.']
  cor_gender <- ifelse(gender == 'M', 'blue', 'red')

  ggp <- ggplot(result, aes(x=Year, y=Count)) + 
    geom_bar(stat="identity", colour="white", fill=cor_gender) + 
    scale_x_continuous(breaks=seq(1880,2015,by=10),limits = c(1880, 2015)) +
    scale_y_continuous(breaks= pretty_breaks()) + 
    labs(x="Ano", y="Quantidade", title=sprintf("%s %s-%s", name, min_year, max_year), color="Gênero", fill="Gênero")
  create_file_png(ggp, paste(dir_img, sprintf("person/%s/%s_%s.png",gender, name, gender), sep=''),width,height)
  dbDisconnect(db)
}


################################################################################
# Cria um gráfico com a dispersão populacional entre 1910 a 2010
################################################################################
questao11 <- function(){
  db <- dbConnect(dbDriver("SQLite"), dataName)
  dataframe <- data.frame(State=character(),Gender=character(), Total=integer()) 
  
  # 14 Periodos - 1880 a 2015
  for (i in 0:14) {
    year_ini <- 1880 + 10 * i
    year_end <- 1880 + 10 * (i + 1)
    query <- sprintf("WITH TotalYear AS ( 
                     SELECT StateNames.Gender, %s AS YearIni, %s AS YearEnd, SUM(StateNames.Count) AS TotalYear 
                     FROM StateNames WHERE '%s' <= Year AND Year < '%s' GROUP BY YearIni, StateNames.Gender
    )
                     SELECT StateNames.State, StateNames.Gender, LOWER(State.Name) AS region,
                     TotalYear.YearIni,TotalYear.YearEnd, SUM(StateNames.Count) AS Total, TotalYear.TotalYear 
                     FROM StateNames
                     JOIN State ON StateNames.State = State.State
                     JOIN TotalYear ON TotalYear.YearIni <= StateNames.Year AND StateNames.Year < TotalYear.YearEnd AND TotalYear.Gender=StateNames.Gender
                     GROUP BY StateNames.State, StateNames.Gender", year_ini, year_end, year_ini, year_end)
    result <- dbGetQuery(db, query)
    dataframe <- rbind(dataframe, result)
  }
  
  states <- map_data("state")
  dataframe <- dataframe %>% mutate(perc=(Total/TotalYear) * 100)
  dataframe <- merge(states, dataframe, sort = FALSE, by = "region")
  dataframe <- dataframe[order(dataframe$order), ]
  
  plot.title = "Densidade populacional"
  plot.subtitle = "Dispersão populacional dos estados durante 1910 a 2010"
  
  ggp <- ggplot(dataframe, aes(long, lat)) +
    geom_polygon(aes(group = group, fill = perc), color='gray', size=.25) +
    scale_fill_gradient(name="Taxa (%)",low='lightgray', high='darkgreen') + 
    labs(x="Longitude", y="Latitude") + 
    theme(legend.background = element_rect(fill="white", size=0.5, linetype="solid", colour ="gray"), 
          legend.position = "bottom", legend.box = "vertical") + 
    ggtitle(bquote(atop(bold(.(plot.title)), atop(italic(.(plot.subtitle)))))) +
    coord_map("albers",  at0 = 45.5, lat1 = 29.5) + facet_wrap(~YearIni, ncol = 3)
  
  create_file_png(ggp, paste(dir_img, "answer11.png", sep=''),680,600)
  dbDisconnect(db)
}

questao9 <- function(width=680,height=150,limit=3){
  name_list <- "'Acacia','Amaryllis','Aster','Azalea','Blossom','Bluebell','Bryony','Calla','Camellia','Clover','Daffodil','Dahlia','Daisy','Delphine','Fleur','Flora','Gardenia','Garland','Heather','Hyacinth','Ianthe','Iris','Ivy','Jacinta','Jasmine','Jonquil','Lavender','Leilani','Lilac','Lily','Linnea','Lotus','Magnolia','Marguerite','Marigold','Orchid','Pansy','Peony','Petal','Petunia','Poppy','Posey','Primrose','Rose','Senna','Tulip','Violet','Xochitl','Zahara','Zinnia','Alyssa','Cherry','Chrysanthemum','Juniper','Laurel','Myrtle','Tansy'"
  
  db <- dbConnect(dbDriver("SQLite"), dataName)
  
  plot.title = "Nome de bebês inspirados em flores"
  plot.subtitle = "Os dez nomes de bebês mais citados durante 1880-2014 inspirados em flores"
  
  query <- sprintf("WITH top10 AS (
    SELECT Name, Gender, SUM(Count) AS Total
      FROM NationalNames 
      WHERE Gender='F' AND Name IN ('Acacia','Amaryllis','Aster','Azalea','Blossom','Bluebell','Bryony','Calla','Camellia','Clover','Daffodil','Dahlia','Daisy','Delphine','Fleur','Flora','Gardenia','Garland','Heather','Hyacinth','Ianthe','Iris','Ivy','Jacinta','Jasmine','Jonquil','Lavender','Leilani','Lilac','Lily','Linnea','Lotus','Magnolia','Marguerite','Marigold','Orchid','Pansy','Peony','Petal','Petunia','Poppy','Posey','Primrose','Rose','Senna','Tulip','Violet','Xochitl','Zahara','Zinnia','Alyssa','Cherry','Chrysanthemum','Juniper','Laurel','Myrtle','Tansy')
    GROUP BY Name ORDER BY Total DESC LIMIT 10
  )
  SELECT NationalNames.Name, NationalNames.Year, NationalNames.Count, top10.Total FROM NationalNames  
    JOIN top10 ON top10.Name = NationalNames.Name AND top10.Gender = NationalNames.Gender 
    ORDER BY NationalNames.Name, NationalNames.Year", name_list)
  result <- dbGetQuery(db,query)
  print(result)
  
  max_count <- summary(result$Count)['Max.']
  ggp <- ggplot(result, aes(x=Year, y=Count)) + 
    geom_bar(color='pink', fill='pink',stat='identity', position='dodge') +
    scale_x_continuous("Ano",limits = c(1880, 2015)) + 
    scale_y_continuous("Quantidade de registros", limits = c(0, max_count)) +
    ggtitle(bquote(atop(bold(.(plot.title)), atop(italic(.(plot.subtitle)))))) + 
    facet_wrap(~Name, ncol=2)
  create_file_png(ggp, paste(dir_img, "answer9.png", sep=''),680,600)
  
  dbDisconnect(db)
}


################################################################################
# Apresenta a visualização dos registros do nome do presidente eleito durante o 1880-2014
################################################################################
answer9 <- function(){
  
  shortName <- c('Chester','Grover','Benjamin','Grover','William','Theodore','William','Woodrow','Warren','Calvin','Herbert','Franklin','Harry','Dwight','John','Lyndon','Richard','Gerald','James','Ronald','George','William','George','Barack')
  name <- c('Chester Alan Arthur','Grover Cleveland','Benjamin Harrison','Grover Cleveland','William McKinley','Theodore Roosevelt','William Howard Taft','Woodrow Wilson','Warren Gamaliel Harding','Calvin Coolidge','Herbert Clark Hoover','Franklin Delano Roosevelt','Harry S. Truman','Dwight David Eisenhower','John Fitzgerald Kennedy','Lyndon Baines Johnson','Richard Milhous Nixon','Gerald Rudolph Ford','James Earl Carter Jr.','Ronald Wilson Reagan','George Herbert Walker Bush','William Jefferson Clinton','George Walker Bush','Barack Hussein Obama')
  yearIni <- c(1881,1885,1889,1893,1897,1901,1909,1913,1921,1923,1929,1933,1945,1953,1961,1963,1969,1974,1977,1981,1989,1993,2001,2009)
  yearEnd <- c(1885,1889,1893,1897,1901,1909,1913,1921,1923,1929,1933,1945,1953,1961,1963,1969,1974,1977,1981,1989,1993,2001,2009,2014)
  
  president <- data.frame(ShortName=shortName, Name=name, YearIni= yearIni, YearEnd=yearEnd)
  
  db <- dbConnect(dbDriver("SQLite"), dbname=dataName) 
  for(p in 1:nrow(president)){
    
    query <- sprintf("SELECT * FROM NationalNames WHERE Name LIKE '%s' AND Gender = 'M'", president$ShortName[p], president$YearIni[p], president$YearEnd[p])  
    result <- dbGetQuery(db,query)
    max_count <- summary(result$Count)['Max.']
    
    plot.title = sprintf("%s %s-%s",president$Name[p],president$YearIni[p],president$YearEnd[p])
    plot.subtitle = sprintf("O impacto do nome %s em nomes de bebês durante o mandato de %s",president$ShortName[p],president$Name[p])
    
    ggp <- ggplot(result, aes(x=Year, y=Count)) + 
      annotate("rect", fill = "green", alpha = 0.15, xmin=president$YearIni[p], ymin=0, xmax=president$YearEnd[p], ymax=Inf) +
      geom_bar(color='darkgray', fill='gold',stat='identity', position='dodge') +
      scale_x_continuous("Ano",limits = c(1880, 2015)) + 
      scale_y_continuous("Quantidade de registros", limits = c(0, max_count)) +
      ggtitle(bquote(atop(bold(.(plot.title)), atop(italic(.(plot.subtitle))))))
    create_file_png(ggp, paste(dir_img, sprintf("president/%s %s-%s.png",president$YearIni[p],president$YearEnd[p],president$Name[p]), sep=''),680,200)
  }
  dev.off()
  dbDisconnect(db)
}


################################################################################
# Cria a visualização dos principais nomes 'UNISEX'
################################################################################
questao8 <- function(){
  
  limit <- 100

  db <- dbConnect(dbDriver("SQLite"), dataName)
  result <- unisex_names()
  result1 <- result %>% filter((TotalM + TotalF) > 1000) %>%
    mutate(Dif = abs(TotalM/(TotalM + TotalF) - TotalF/(TotalM + TotalF))) %>%
    arrange(Dif)
  
  for (i in 1:nrow(result1)) {
    if(i <= limit){
      query <- sprintf('WITH Top3 AS (
         SELECT Name, State, SUM(Count) AS Total FROM StateNames WHERE Name = "%s"
         GROUP BY State ORDER BY Total DESC)
         SELECT Year, Gender, StateNames.State, Count, Total FROM StateNames 
         JOIN Top3 ON Top3.State = StateNames.State AND Top3.Name = StateNames.Name ', result1$Name[i])
      query <- sprintf('
         SELECT Name, Gender, Year, Count FROM NationalNames WHERE Name = "%s"', result1$Name[i])
      result2 <- dbGetQuery(db,query)
      
      plot.title = sprintf("%s", result1$Name[i])
      plot.subtitle = sprintf("Número de registros de %s por gênero entre 1880 a 2014", result1$Name[i])
      
      max_count <- summary(result2$Count)['Max.']
      ggp <- ggplot(data=result2, aes(x=Year, y=Count, fill=Gender)) +
        geom_bar(stat="identity", colour="white") + 
        scale_x_continuous("Ano", limits=c(1880, 2015)) + 
        scale_y_continuous("Quantidade de registros", limits = c(0, max_count)) +
        labs(title=sprintf("%s", result1$Name[i]),  fill="Gênero") + 
        ggtitle(bquote(atop(bold(.(plot.title)), atop(italic(.(plot.subtitle)))))) + 
        facet_grid(Gender~., scale="free")
      
      create_file_png(ggp, paste(dir_img, sprintf("unisex/%s.png",result1$Name[i]), sep=''),680,300)
    }else{
      break
    } 
  }
  create_file_csv(result1, paste(dir, sprintf("csv/answer8.csv"), sep=''))
  dbDisconnect(db)
}

################################################################################
# Exibe dois gráficos:
# * densidade populacional de 2014.
# * distribuição populacional de 2014.
################################################################################
questao10 <- function(){
  db <- dbConnect(dbDriver("SQLite"), dataName)
  query <- 'SELECT State, Gender, SUM(Count) AS Total FROM StateNames WHERE Year = 2014 GROUP BY State, Gender'
  result <- dbGetQuery(db, query)
  
  grid.newpage()
  plot.title = "Distribuição populacional"
  plot.subtitle = "Distribuição populacional dos estados em 2014"
  ggp1 <- ggplot(result, aes(x=State, y=Total, fill=Gender)) + 
    geom_bar(stat='identity', position='dodge') + 
    ggtitle(bquote(atop(bold(.(plot.title)), atop(italic(.(plot.subtitle)))))) +
    scale_y_continuous('Quantidade de registros', breaks=seq(0, 250000,by=120000)) + 
    labs(x='Estados', fill='Gênero') + coord_flip()
  
  plot.title = "Composição por gênero"
  plot.subtitle = "Composição por gênero em nível estadual em 2014"
  ggp2 <- ggplot(result, aes(x=State, y=Total, fill=Gender)) + 
    geom_bar(stat='identity', position='fill') + 
    ggtitle(bquote(atop(bold(.(plot.title)), atop(italic(.(plot.subtitle)))))) +
    geom_hline(yintercept=.5,  color='white', alpha=.25) + 
    scale_y_continuous('Quantidade de registros', breaks=seq(0, 1, by=.25)) + 
    labs(x='Estados', fill='Gênero') + coord_flip()
  ggp <- grid.arrange(ggp1,ggp2,ncol=2)
  create_file_png(ggp, paste(dir_img,'answer10.png', sep='') , 680, 800)
  
  dbDisconnect(db)
}

answer13 <- function(){
  president <- "'JAMES','JOHN','ANDREW','WILLIAM','BENJAMIN','THOMAS','AARON','ZACHARY','MADISON','RICHARD','GEORGE','ABRAHAM','STEPHEN','MARTIN','JACKSON','CARTER','GRANT','LESLIE','THEODORE','KENNEDY','REAGAN','RONALD','HARRY','CALVIN','DAVIS','NELSON','HUSSEIN','GERALD','LINCOLN'"
  namesBibleM <- "'Aaron','Abel','Abraham','Adam','Andrew','Asher','Barak','Barnabas','Bartholomew','Benjamin','Dan','Elijah','Elon','Ephraim','Ezekiel','Gabriel','Gad','Gideon','Hillel','Hiram','Immanuel','Isaac','Ishmael','Israel','Jabin','Jacob','James','Jared','Jesse','Jesus','Jethro','Joel','John','Jokim','Joseph','Joshua','Josiah','Judah','Levi','Lucas','Luke','Mark','Matthew','Meshach','Micah','Moses','Noah','Paul','Peter','Philip','Reuben','Rufus','Samson','Saul','Seth','Silas','Simon','Solomon','Stephen','Thaddeus','Thomas','Timothy','Zacharias'"
  namesBibleF <- "'Abigail','Ada','Ahlai','Angel','Anna','Apphia','Atarah','Athaliah','Bathsheba','Bilhah','Candace','Chloe','Claudia','Damaris','Deborah','Delilah','Diana','Dinah','Elizabeth','Esther','Eunice','Eve','Hagar','Hannah','Huldah','Jedidah','Jezebel','Joanna','Judith','Julia','Leah','Lois','Lydia','Martha','Mary','Michaiah','Milcah','Miriam','Naarah','Naomi','Orpah','Phebe','Priscilla','Rachel','Rebecca','Ruth','Salome','Sapphira','Sarai','Sherah','Susanna','Tabitha','Tamar','Tirza','Vashti','Zilpah'"
  
  query <- sprintf("SELECT Name, Gender, SUM(Count) AS Total
    FROM NationalNames WHERE Name IN (%s) 
    GROUP BY Name, Gender ORDER BY Total DESC", namesBibleM)
  result <- dbGetQuery(db, query)  
  
  pal1 <- c("#F1B6DA", "#DE77AE", "#C51B7D", "#8E0152")
  pal2 <- brewer.pal(9, "Blues")
  pal2 <- pal2[-(1:4)]
  # Set seed number;
  set.seed(0)
  # Generate word cloud for female baby names 2014;
  wordcloud(result$Name, result$Total, scale = c(7, .5), 10, 60, TRUE, , .15, pal2)
  dbDisconnect(db)
}

################################################################################
################################################################################

questao_1 <- function(){
  
  db <- dbConnect(dbDriver("SQLite"), dataName)
  query <- "SELECT LOWER(State.Name) as region, State.*, SUM(Count) AS Total
  FROM StateNames   
  JOIN State ON State.State = StateNames.State
  WHERE Year = 2014 GROUP BY StateNames.State"
  result <- dbGetQuery(db,query)
  
  if (require("maps")) {
    states <- map_data("state")
    choro <- merge(states, result, sort = FALSE, by = "region")
    choro <- choro[order(choro$order), ]
    
    plot.title = "AAAA A A AAA"
    plot.subtitle = "Número de registros com o gênero Masculino ou Feminino"  
    
    min_count <- summary(result$Count)['Min.']
    max_count <- summary(result$Count)['Max.']
    ggp <- ggplot(choro, aes(long, lat)) +
      geom_polygon(aes(group = group, fill = Total), color='gray', size=.25) +
      scale_fill_gradient(name="Total",low='#EEEEEE', high='darkgreen') + 
      
      #    scale_fill_gradientn(colours = rev(rainbow(7)), limit=c(min_count, max_count),
      #                         breaks = c(2, 4, 10, 100, 1000, 10000),trans = "log10")    
      labs(x="Longitude", y="Latitude") + 
      ggtitle(bquote(atop(bold(.(plot.title)), atop(italic(.(plot.subtitle)))))) + 
      coord_map("albers",  at0 = 45.5, lat1 = 29.5)
    
    png(filename= './usa1.png', width = 680, height = 400)  
    print(ggp)
    dev.off()  
  }
  dbDisconnect(db)
}

################################################################################
# Lista todos os nomes unisex verificando similidade
# Restrição: A quantidade de registro para o gênero Masculino e Feminino deverão ser maior que 0
################################################################################
unisex_names <- function(){
  db <- dbConnect(dbDriver("SQLite"), dataName)
  query <- "WITH FullName AS (
    SELECT NationalNames.Name,
      SUM(CASE WHEN NationalNames.Gender='M' THEN NationalNames.Count ELSE 0 END) AS TotalM, 
      SUM(CASE WHEN NationalNames.Gender='F' THEN NationalNames.Count ELSE 0 END) AS TotalF
    FROM NationalNames 
    WHERE Name NOT LIKE 'Unknown' 
    GROUP BY NationalNames.Name)
  SELECT * FROM FullName
  WHERE FullName.TotalM > 0 AND FullName.TotalF > 0"
  result <- dbGetQuery(db,query)
  
  return(result)
}

################################################################################
# Realiza as chamadas para a criação das tabelas necessárias.
################################################################################
create_tables <- function(){
  location_state()
  generations_american()
}

################################################################################
# Cria e popula uma tabela sobre as gerações com nome, tipo, ano de início e fim.
################################################################################
generations_american <- function(){
  db <- dbConnect(dbDriver("SQLite"), dataName)
  query <- "CREATE TABLE Generation(
    Name TEXT,
    Type TEXT,
    YearIni INT,
    YearEnd INT
  )"
  result <- dbGetQuery(db,query)

  query <- "INSERT INTO Generation VALUES
    ('Lost Generation','Reactive',1883,1900),
    ('G.I. Generation','Civic',1901,1924),
    ('Silent Generation','Adaptive',1925,1942),
    ('Baby Boom Generation','Idealist',1943,1960),
    ('Generation X','Reactive',1961,1981),
    ('Millennial Generation','Civic',1982,2004),
    ('Homeland Generation','Adaptive',2005,2016)"  
  result <- dbGetQuery(db,query)
}

################################################################################
# Cria e popula uma tabela de estados com nome, sigla, latitude e longitude 
# * É utilizado o método 'geocode' para capturar a latitude e longitude
################################################################################
location_state_geocode <- function(){
  db <- dbConnect(dbDriver("SQLite"), dataName)
  query <- "SELECT State FROM StateNames GROUP BY State ORDER BY State"
  result <- dbGetQuery(db,query)
  
  for (i in c) {  
    latlon <- geocode(result[i,1], output='all', messaging=TRUE, override_limit=TRUE)
    result$Lat[i] <- latlon$results[[1]]$geometry$location$lat
    result$Lon[i] <- latlon$results[[1]]$geometry$location$lng
    result$Name[i] <- latlon$results[[1]]$formatted_address
  }
  dbWriteTable(db, "State", result, overwrite = TRUE)  
  dbDisconnect(db)
}

################################################################################
# Cria e popula uma tabela de estados com nome, sigla, latitude e longitude 
# * Latitude e longitude definida.
################################################################################
location_state <- function(){
  db <- dbConnect(dbDriver("SQLite"), dataName)
  query <- "CREATE TABLE State(
    Name TEXT,
    State TEXT,
    Lat REAL,
    Lon REAL)"
  query <- "DELETE FROM State"
  result <- dbGetQuery(db,query)
  
  query <- "INSERT INTO State (Name, State, Lat, Lon) VALUES
      ('Alabama','AL',32.3182314,-86.902298),
      ('Alaska','AK',64.2008413,-149.4936733),
      ('Arizona','AZ',34.0489281,-111.0937311),
      ('Arkansas','AR',35.20105,-91.8318334),
      ('California','CA',36.778261,-119.4179324),
      ('Colorado','CO',39.5500507,-105.7820674),
      ('Connecticut','CT',41.6032207,-73.087749),
      ('Delaware','DE',38.9108325,-75.5276699),
      ('Florida','FL',27.6648274,-81.5157535),
      ('Georgia','GA',32.1656221,-82.9000751),
      ('Hawaii','HI',19.8967662,-155.5827818),
      ('Idaho','ID',44.0682019,-114.7420408),
      ('Illinois','IL',40.6331249,-89.3985283),
      ('Indiana','IN',40.26719,-86.1349),
      ('Iowa','IA',41.8780025,-93.097702),
      ('Kansas','KS',39.011902,-98.4842465),
      ('Kentucky','KY',37.8393332,-84.2700179),
      ('Louisiana','LA',30.9843,-91.96233),
      ('Maine','ME',45.253783,-69.4454689),
      ('Maryland','MD',39.0457549,-76.6412712),
      ('Massachusetts','MA',42.4072107,-71.3824374),
      ('Michigan','MI',44.3148443,-85.6023643),
      ('Minnesota','MN',46.729553,-94.6858998),
      ('Mississippi','MS',32.3546679,-89.3985283),
      ('Missouri','MO',37.9642529,-91.8318334),
      ('Montana','MT',46.8796822,-110.3625658),
      ('Nebraska','NE',41.4925374,-99.9018131),
      ('Nevada','NV',38.8026097,-116.419389),
      ('New Hampshire','NH',43.1938516,-71.5723953),
      ('New Jersey','NJ',40.0583238,-74.4056612),
      ('New Mexico','NM',34.5199402,-105.8700901),
      ('New York','NY',40.7127837,-74.0059413),
      ('North Carolina','NC',35.7595731,-79.0192997),
      ('North Dakota','ND',47.5514926,-101.0020119),
      ('Ohio','OH',40.4172871,-82.907123),
      ('Oklahoma','OK',35.0077519,-97.092877),
      ('Oregon','OR',40.2968979,-111.6946475),
      ('Pennsylvania','PA',41.2033216,-77.1945247),
      ('Rhode Island','RI',47.9608864,-116.8669059),
      ('South Carolina','SC',33.836081,-81.1637245),
      ('South Dakota','SD',43.9695148,-99.9018131),
      ('Tennessee','TN',35.5174913,-86.5804473),
      ('Texas','TX',31.9685988,-99.9018131),
      ('Utah','UT',39.3209801,-111.0937311),
      ('Vermont','VT',44.5588028,-72.5778415),
      ('Virginia','VA',37.4315734,-78.6568942),
      ('Washington DC','DC',38.9071923,-77.0368707),
      ('Washington','WA',47.7510741,-120.7401386),
      ('West Virginia','WV',38.5976262,-80.4549026),
      ('Wisconsin','WI',43.7844397,-88.7878678),
      ('Wyoming','WY',43.0759678,-107.2902839)"  
  result <- dbGetQuery(db,query)
}
