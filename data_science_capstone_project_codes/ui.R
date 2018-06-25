#
# Purpose: This is the user-interface of my shiny web application to predict the next word on
# the basis on the last 4 words or less of user's input.
# All numbers and punctuations will be removed from the input sentence.
#

library(shiny)
library(devtools)

shinyUI(
  fluidPage(
    headerPanel("Next Word Prediction"),
    tabsetPanel(
      tabPanel("Input Tab",
        p("This application takes the last 4 or less words of your input string and predicts the next word after removing numbers and punctuations"),
        p("If there is no sentence, empty string is displayed"),
        textInput("input","Please type in your sentence here"),
        #actionButton('submit',"Submit Sentence"),
        tags$h3("The Next Word Is: "),
        verbatimTextOutput("prediction",placeholder=TRUE)
      ),
      tabPanel("About", 
               p('This Shiny Web Application is the last part of the Capston Project in Coursera 
                 Johns Hopkins University Data Science Specialization.',align='left'),
               p('The purpose of this application is to predict the next word on the basis of
                 user input sentence',align='left'),
               p('The source data is the English blogs, news and twitter files from 
                 https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip', 
                 aligh='left'),
               p('It uses these files to create 1, 2, 3, 4 and 5 grams',align='left'),
               p('The Prediction program uses Stupid Backoff model.',align='left'),
               p('The application takes the user input and predicts the next word with the highest probabiliy.',align='left'),
               p('E.g. the input sentence is "I am a very"'),
               p('The 5 gram file contains 3 rows:  I am a very happy; I am a very generous; I am a very good'),
               p('The 4 gram file contains 4 rows:  am a very hungry; am a very thirsty; am a very happy; am a very happy'),
               p('The 3 gram file contains 3 rows:  a very big; a very small; a very happy'),
               p('The 2 gram file contains 3 rows:  very happy; very tall; very small'),
               p('The stupid backoff probability will be:'),
               p('5 gram:   happy: 1/3;   generous: 1/3; good: 1/3'),
               p('4 gram:   hungry: 1/4:  thirsty: 1/4; happy: 2/4'),
               p('3 gram:   big: 1/3; small; 1/3; happy: 1/3'),
               p('2 gram:   happy: 1/3; tall: 1/3; small: 1/3'),
               p('Multiply the probabilies from 4 gram with 0.4, 3 gram with 0.4*0.4, 2 gram with 0.4*0.4*0.4'),
               p('Then select the word with the highest probability')
      )
  )
)
)
    