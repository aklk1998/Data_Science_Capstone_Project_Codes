#
# Name: Preprocess Codes.R
# Author: AK
# Date: Jun 20, 2018
# Purposes: 
# 1.  Read in English versions of blogs, news and twitter files from https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip
# 2.  Creation of a sample file (10% of the input files)
# 3.  Clean up of the sample file (remove numbers, remove punctuation, remove extra white space, convert them to lower case)
# 4.  Creation of 1,2,3,4,5 grams tables and write them to a SQL database for the Shiny application.
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

#
# Set default Directory
#
#setwd("C:/Data Files/Coursea/Capstone Project/Data_Science_Capstone_Project/")

#
# Read in the 3 files - blogs, news and twitter
#
blogs <- readLines("en_US.blogs.txt",encoding="UTF-8",skipNul=TRUE,warn=FALSE)
con <- file("en_US.news.txt", open = "rb")
news <- readLines(con,encoding="UTF-8",skipNul=TRUE,warn=FALSE)
close(con)
twitter <- readLines("en_US.twitter.txt",encoding="UTF-8",skipNul=TRUE,warn=FALSE)

set.seed(12345)

#
# Only select 10% of the input data
#
sample_size <- 0.1

blogs1<-sample(blogs,length(blogs)*sample_size)
news1<-sample(news,length(news)*sample_size)
twitter1<-sample(twitter,length(twitter)*sample_size)

#
# Samples Cleanup
#
blogs2 <- iconv(blogs1,"latin1", "ASCII",sub="")
news2 <- iconv(news1,"latin1", "ASCII",sub="")
twitter2 <- iconv(twitter1,"latin1", "ASCII",sub="")

sample_file <- as.data.frame(c(blogs2,news2, twitter2))

remove(blogs, blogs1, blogs2, news, news1, news2, twitter, twitter1, twitter2)
gc()

#
# Creation of a Corpus
#
corpus <- VCorpus(VectorSource(sample_file),readerControl=list(reader=readPlain,language="en")) # create the Vcorpus

#
# Corpus Cleanup
#
corpus <- tm_map(corpus, removeWords, stopwords("english"),lazy=TRUE)
corpus<-VCorpus(VectorSource(corpus))
corpus <- tm_map(corpus, removePunctuation)
corpus<-VCorpus(VectorSource(corpus))
corpus <- tm_map(corpus, removeNumbers)
corpus<-VCorpus(VectorSource(corpus))
corpus <- tm_map(corpus, content_transformer(tolower))
corpus<-VCorpus(VectorSource(corpus))
corpus <- tm_map(corpus, stripWhitespace)
corpus<-VCorpus(VectorSource(corpus))
corpus <- tm_map(corpus, PlainTextDocument)
corpus<-VCorpus(VectorSource(corpus))

#
# Define Tokenization Functions
#
OneTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 1, max = 1))
TwoTokenizers <- function(x) NGramTokenizer(x, Weka_control(min = 2, max = 2))
ThreeTokenizers <- function(x) NGramTokenizer(x, Weka_control(min = 3, max = 3))
FourTokenizers <- function(x) NGramTokenizer(x, Weka_control(min = 4, max = 4))
FiveTokenizers <- function(x) NGramTokenizer(x, Weka_control(min = 5, max = 5))

#
# Set up Database Connection
#
gramsDBname<-"gramsDB"
gramsDB<-dbConnect(SQLite(),gramsDBname)

#
# Creation of 1 gram frequency table and write it to the SQL database for future processing.
# Also remove rows with frequency <= 1
#
low_freq = 1
One_matrix <- TermDocumentMatrix(corpus, control = list(tokenize = OneTokenizer))
frequency <- sort (rowSums(as.matrix(removeSparseTerms(One_matrix, 0.999))),decreasing=TRUE)
gram1 <- data.frame(word=names(frequency),freq=frequency)
rownames(gram1)<-c(1:nrow(gram1))
gram1<-gram1[gram1$freq>low_freq,]
dbWriteTable(gramsDB,"gram1",gram1,overwrite=T)
remove(One_matrix,gram1)
gc()

#
# Creation of 2 gram frequency table and write it to the SQL database for future processing.
#
Two_matrix <- TermDocumentMatrix(corpus, control = list(tokenize = TwoTokenizers))
frequency <- sort (rowSums(as.matrix(removeSparseTerms(Two_matrix, 0.999))),decreasing=TRUE)
gram2 <- data.frame(word=names(frequency),freq=frequency)
rownames(gram2)<-c(1:nrow(gram2))
gram2<-gram2[gram2$freq>low_freq,]
dbWriteTable(gramsDB,"gram2",gram2,overwrite=T)
remove(Two_matrix,gram2)
gc()

#
# Creation of 3 grams frequency table and write it to the SQL database for future processing.
#
Three_matrix <- TermDocumentMatrix(corpus, control = list(tokenize = ThreeTokenizers))
frequency <- sort (rowSums(as.matrix(removeSparseTerms(Three_matrix, 0.999))),decreasing=TRUE)
gram3 <- data.frame(word=names(frequency),freq=frequency)
rownames(gram3)<-c(1:nrow(gram3))
gram3<-gram3[gram3$freq>low_freq,]
dbWriteTable(gramsDB,"gram3",gram3,overwrite=T)
remove(Three_matrix,gram3)
gc()

#
# Creation of 4 grams frequency table and write it to the SQL database for future processing.
#

Four_matrix <- TermDocumentMatrix(corpus, control = list(tokenize = FourTokenizers))
frequency <- sort (rowSums(as.matrix(removeSparseTerms(Four_matrix, 0.999))),decreasing=TRUE)
gram4 <- data.frame(word=names(frequency),freq=frequency)
rownames(gram4)<-c(1:nrow(gram4))
gram4<-gram4[gram4$freq>low_freq,]
dbWriteTable(gramsDB,"gram4",gram4,overwrite=T)
remove(Four_matrix,gram4)
gc()

#
# Creation of 5 grams frequency table and write it to the SQL database for future processing.
#
Five_matrix <- TermDocumentMatrix(corpus, control = list(tokenize = FiveTokenizers))
frequency <- sort (rowSums(as.matrix(removeSparseTerms(Five_matrix, 0.999))),decreasing=TRUE)
gram5 <- data.frame(word=names(frequency),freq=frequency)
rownames(gram5)<-c(1:nrow(gram5))
gram5<-gram5[gram5$freq>low_freq,]
dbWriteTable(gramsDB,"gram5",gram5,overwrite=T)
head(gram5,5)
remove(Five_matrix,gram5)
gc()

#
# Disconnect from the database
#
dbDisconnect(gramsDB)

remove(frequency,corpus)
gc()