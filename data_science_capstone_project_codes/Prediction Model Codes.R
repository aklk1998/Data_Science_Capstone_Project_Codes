#
# Name: Preprocess Codes.R
# Author: AK
# Date: Jun 20, 2018
# Purposes: 
# 1.  Read in the 1/2/3/4/5 gram files from the SQL light database.
# 2.  Clean up the input sentence
# 3.  Using the Stupid backoff model:
#     E.g. the input sentence is I am a very
#     The 5 gram file contains 3 rows:  I am a very happy; I am a very generous; I am a very good
#     The 4 gram file contains 4 rows:  am a very hungry; am a very thirsty; am a very happy; am a very happy
#     The 3 gram file contains 3 rows:  a very big; a very small; a very happy
#     The 2 gram file contains 3 rows:  very happy; very tall; very small
#     The stupid backoff probability will be:
#     5 gram:   happy: 1/3;   generous: 1/3; good: 1/3
#     4 gram:   hungry: 1/4:  thirsty: 1/4; happy: 2/4
#     3 gram:   big: 1/3; small; 1/3; happy: 1/3
#     2 gram:   happy: 1/3; tall: 1/3; small: 1/3
#     Multiply the probabilies from 4 gram with 0.4, 3 gram with 0.4*0.4, 2 gram with 0.4*0.4*0.4
#     Then select the word with the highest probability

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

#
# Establish Database connection
#
gramsDBname<-"gramsDB"
gramsDB<-dbConnect(SQLite(),gramsDBname)

#
# Extract the grams tables
#
gram1<-data.frame(dbGetQuery(gramsDB,"select * from gram1"))
gram2<-data.frame(dbGetQuery(gramsDB,"select * from gram2"))
gram3<-data.frame(dbGetQuery(gramsDB,"select * from gram3"))
gram4<-data.frame(dbGetQuery(gramsDB,"select * from gram4"))
gram5<-data.frame(dbGetQuery(gramsDB,"select * from gram5"))

dbDisconnect(gramsDB)

predict <- function (inputtext) {

  predictvalue = data.frame(nextword = 'the')
  
  # clean up the input sentence
  cleaninput <- trimws(stripWhitespace(removeNumbers(removePunctuation(tolower(trimws(inputtext))))))
  if (cleaninput==" "||is.null(cleaninput)||length(cleaninput)==0||cleaninput=="")
  {
      return(" ")
  }
  #print (cleaninput)
  inputwords = unlist(strsplit(cleaninput,' '))
  
  if(length(inputwords)>=4){
    predictvalue = rbind(gram5predict(inputwords[(length(inputwords)-3):length(inputwords)]),
                         gram4predict(inputwords[(length(inputwords)-2):length(inputwords)])%>% transform(prob=prob*.4),
                         gram3predict(inputwords[(length(inputwords)-1):length(inputwords)])%>% transform(prob=prob*.4*.4),
                         gram2predict(inputwords[length(inputwords)])%>% transform(prob=prob*.4*.4*.4))
    predictvalue = predictvalue[order(-predictvalue$prob),]
  } 
  
  else if(length(inputwords)==3){
    predictvalue = rbind(gram4predict(inputwords[(length(inputwords)-3):length(inputwords)]),
                         gram3predict(inputwords[(length(inputwords)-2):length(inputwords)])%>% transform(prob=prob*.4),
                         gram2predict(inputwords[(length(inputwords)-1):length(inputwords)])%>% transform(prob=prob*.4*.4))
    predictvalue = predictvalue[order(-predictvalue$prob),]
  }
  
  else if(length(inputwords)==2){
    predictvalue = rbind(gram3predict(inputwords[(length(inputwords)-1):length(inputwords)]),
                         gram2predict(inputwords[length(inputwords)])%>% transform(prob=prob*.4))
    predictvalue = predictvalue[order(-predictvalue$prob),]
    
  }
  
  else if(length(inputwords)==1){
    predictvalue = gram2predict(inputwords[length(inputwords)])
    predictvalue = predictvalue[order(-predictvalue$prob),]
    
  }
  
  else {
  } 
  
  if (nrow(predictvalue)==0) {
    return("the")
  }
  else{
    return(predictvalue[1,"nextword"])  
  }
  
  
}

gram5predict <- function(fourwords){
  
  temp<-gram5[gram5$word0==paste(fourwords,collapse=' '),]
  return (temp)
}


gram4predict <- function(threewords){
  temp<-gram4[gram4$word0==paste(threewords,collapse=' '),]
  return (temp)
}


gram3predict <- function(twowords){
  temp<-gram3[gram3$word0==paste(twowords,collapse=' '),]
  return (temp)
}

gram2predict <- function(oneword){
  temp<-gram2[gram2$word0==oneword,]
  return (temp)
}