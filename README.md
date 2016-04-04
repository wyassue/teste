<h1> US Baby Name </h1>

<h3>Descrição do Problema</h3>
Para mais informações: https://www.kaggle.com/kaggle/us-baby-names

<h3>Objetivo</h3>
Todas as soluções foram implementadas na linguagem R utilizando os recursos disponíveis para coletar, manipular, análisar e visualizar as informações. 


<h3>Dependências</h3>
Para a execução dos algoritmos implementados é necessário instalar as seguintes bibliotecas.
* RSQLite: Biblioteca para realizar as consultas em SQL.
* ggplot2: Apresentar as visualizações dos dados.
* gridExtra: Possibilita a geração de vários gráficos na mesma tela.
* dplyr: Manipular os dataframes.
* maps: Fornece uma base de dados de alta resolução para exibição de mapas.
* ggmap: Exibição e a manipulação de imagens e utilizando coordenadas e afins.
* scales: Apresenta métodos para alterar a parte gráfica como eixos, rótulos e entre outros. 

Obs: Para instalar todas as pendências execute `init_packages()` no arquivo `util.R`

<h3>Considerações</h3>
1. Será exibida apenas as deduções e resultados. Todos os códigos estarão na pasta <i>/code</i>. 
2. Na pasta <i>/img</i> apresentamos todas as imagens.
3. Para algumas questões serão mostradas apenas os principais resultados. Todos os resultados estarão no formato <i>.csv</i> na pasta <i>/csv</i>.

<h3>Data set</h3>
**NationalNames**

Id | Name | Year | Gender | Count
------ | ------ | ------ | ------ | ------:
1 | Mary | 1880 | F | 7065
2 | Anna | 1880 | F | 2604
3 | Emma | 1880 | F | 2003
`obs: 1.825.433 registros`

**StateNames**

Id | Name | Year | Gender | State | Count
------ | ------ | ------ | ------ | ------ | ------:
1 | Mary | 1910 | F | AK | 14
2 | Annie | 1910 | F | AK | 12
3 | Anna | 1910 | F | AK | 10
`obs: 5.647.426 registros`

<h4>Tabela auxiliares</h4>
**State**
- No arquivo `util.R` no método `location_state`.

State | Lat | Lon | Name
------ | ------ | ------ | ------ | ------ | ------:
AK | 64.20084 | -149.49367 | Alaska, USA
AL | 32.31823 | -86.90230 | Alabama, USA
AR | 35.20105 | -91.83183 | Arkansas, USA
`obs: 51 registros`

**Generation**
- No arquivo `util.R` no método `generations_american`.

Name | YearIni | YearEnd
------ | ------ | ------ | ------:
Lost Generation | 1883 | 1900
G.I. Generation | 1901 | 1924
Silent Generation | 1925 | 1942
`obs: 7 registros`

<h3>Respostas</h3>
<h4>Questão 1</h3>
Qual dos gêneros que há a maior variedade de nomes por ano a âmbito nacional?
![alt text][asked1]

<h4>Questão 2</h3>
Quais são os vinte nomes mais populares?
<br></t>2.1 Gênero Masculino

![alt text][asked2_1]
<br></t>2.2 Gênero Feminimo

![alt text][asked2_2]

<h4>Questão 3</h3>
Exiba um gráfico com a contagem total dos registros feitos por ano.
![alt text][asked3]

<h4>Questão 4</h3>
Existe alguma tendência nos nascimentos no decorrer dos anos?
![alt text][asked4]

<h4>Questão 5</h3>
Existe alguma 
![alt text][asked5]

* Durante a campanha de George H.W. Bush (1989-1993), o nome George estava se popularizando até em 1990 quando subitamente houve o declinio devido a Guerra do Golfo causando antipatia com a população diante dos custos de guerra ataque à civis. 
* Recém eleito em 2001, no mandato de George W. Bush (2001-2009) houve o atentado de 11 de setembro iniciando a ofensiva contra o terrorismo
* Em 2007, o nome Barack obteve poucos registros. O aumento repentino no nome Barack foi ocasioado pelo anuncio de Barack Obama a presidência dos Estados Unidos. Avançando até 2009 com a vitória sobre o candidato republicano John McCain.

[asked1]: https://github.com/wyassue/teste/blob/master/img/%20answer1.png "Questão 1"
[asked2_1]: https://github.com/wyassue/teste/blob/master/img/%20answer2_F_v2.png "Questão 2"
[asked2_2]: https://github.com/wyassue/teste/blob/master/img/%20answer2_M_v2.png "Questão 2"
[asked3]: https://github.com/wyassue/teste/blob/master/img/%20answer3.png "Questão 3"
[asked4]: https://github.com/wyassue/teste/blob/master/img/%20answer4.png "Questão 4"
[asked5]: https://github.com/wyassue/teste/blob/master/img/president_full.png "Questão 5"

