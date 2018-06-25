#
# Name: Stupid Backoff Frequency Calculation.R
# Author: AK
# Date: Jun 23, 2018
# Purposes: 
# 1.  Read in the grams files one by one
# 2.  Calculates the probability using stupd backoff algorthim for the 5, 4, 3, 2, 1 gram files.
#     e.g.  The 5 gram file contains 3 rows:  I am a very happy; I am a very generous; I am a very good
#           The probability of the word of happy is:   1/3 (there are 3 I am a very and only 1 happy)
#

options(java.parameters = "-Xmx3072m") #increase the Java Heap Space

#
# Loading of required packages
#
library(ggplot2)
library(tm)
library(RWeka)
library(dplyr)
library(ngram)
library(stringr)
library(RSQLite)
library(data.table)
library(sqldf)

#
# Establish Database connection
#
gramsDBname<-"gramsDB"
gramsDB<-dbConnect(SQLite(),gramsDBname)

#
# Extract the grams tables
#
gram1<-data.frame(dbGetQuery(gramsDB,"select * from gram1"))
gram1$word0<-gram1$word
gram1$nextword<-gram1$word
gram1$prob<-gram1$freq/sum(gram1$freq)
gram1<-gram1[order(gram1$word0,-gram1$prob),]
dbWriteTable(gramsDB,"gram1",gram1,overwrite=T)
remove(gram1)

gram2<-data.frame(dbGetQuery(gramsDB,"select * from gram2"))
first<-gram2$word %>% strsplit(" ")  %>% sapply("[",1) # the [ function is used to pick up the 1 element in the list e.g. split[[1]][1]
second<-gram2$word %>% strsplit(" ")  %>% sapply("[",2) # the [ function is used to pick up the 2 element in the list e.g. split[[1]][2]
gram2$word0<-first
gram2$nextword<-second
s1 <- sqldf("select word0, sum(freq) as total from gram2 where word0 is not null group by word0")
s2 <- sqldf("select a.word, a.freq, a.nextword, a.word0, b.total from gram2 a, s1 b where a.word0 = b.word0")
s2$prob<-s2$freq/s2$total
gram2<-gram2[order(gram2$word0,-gram2$prob),]
dbWriteTable(gramsDB,"gram2",s2,overwrite=T)
remove(gram2, first, second, s1, s2)

gram3<-data.frame(dbGetQuery(gramsDB,"select * from gram3"))
first<-gram3$word %>% strsplit(" ")  %>% sapply("[",1)
second<-gram3$word %>% strsplit(" ")  %>% sapply("[",2)
third<-gram3$word %>% strsplit(" ")  %>% sapply("[",3)
gram3$word0<-paste(first,second)
gram3$nextword<-third
s1 <- sqldf("select word0, sum(freq) as total from gram3 where word0 is not null group by word0")
s2 <- sqldf("select a.word, a.freq, a.nextword, a.word0, b.total from gram3 a, s1 b where a.word0 = b.word0")
s2$prob<-s2$freq/s2$total
gram3<-gram3[order(gram3$word0,-gram3$prob),]
dbWriteTable(gramsDB,"gram3",s2,overwrite=T)
remove(gram3, first, second, third, s1, s2)

gram4<-data.frame(dbGetQuery(gramsDB,"select * from gram4"))
first<-gram4$word %>% strsplit(" ")  %>% sapply("[",1)
second<-gram4$word %>% strsplit(" ")  %>% sapply("[",2)
third<-gram4$word %>% strsplit(" ")  %>% sapply("[",3)
fourth<-gram4$word %>% strsplit(" ")  %>% sapply("[",4)
gram4$word0<-paste(first,second,third)
gram4$nextword<-fourth
s1 <- sqldf("select word0, sum(freq) as total from gram4 where word0 is not null group by word0")
s2 <- sqldf("select a.word, a.freq, a.nextword, a.word0, b.total from gram4 a, s1 b where a.word0 = b.word0")
s2$prob<-s2$freq/s2$total
gram4<-gram4[order(gram4$word0,-gram4$prob),]
dbWriteTable(gramsDB,"gram4",s2,overwrite=T)
remove(gram4, first, second, third, fourth, s1, s2)

gram5<-data.frame(dbGetQuery(gramsDB,"select * from gram5"))
first<-gram5$word %>% strsplit(" ")  %>% sapply("[",1)
second<-gram5$word %>% strsplit(" ")  %>% sapply("[",2)
third<-gram5$word %>% strsplit(" ")  %>% sapply("[",3)
fourth<-gram5$word %>% strsplit(" ")  %>% sapply("[",4)
fifth<-gram5$word %>% strsplit(" ")  %>% sapply("[",5)
gram5$word0<-paste(first,second,third,fourth)
gram5$nextword<-fifth
s1 <- sqldf("select word0, sum(freq) as total from gram5 where word0 is not null group by word0")
s2 <- sqldf("select a.word, a.freq, a.nextword, a.word0, b.total from gram5 a, s1 b where a.word0 = b.word0")
s2$prob<-s2$freq/s2$total
gram5<-gram5[order(gram5$word0,-gram5$prob),]
dbWriteTable(gramsDB,"gram5",s2,overwrite=T)
remove(gram5, first, second, third, fourth, fifth, s1, s2)

dbDisconnect(gramsDB)
