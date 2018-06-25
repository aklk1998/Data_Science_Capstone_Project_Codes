
#
# Purpose: This is the server logic of my shiny web application to predict the next word on
# the basis on the last 4 words or less of user's input.
#
# Using 5 Ngram model, first take the last 4 words of the input sentence
# if 4 words found in the 5 gram pick the next work with the highest score
# if not found in the 5 gram model, pick the next word in the 4 gram file (the last 3 words of the input sentence) with the highest score
# if not found in the 4 gram model, pick the next word in the 3 gram file (the last 2 words of the input sentence) with the highest score
# if not found in the 3 gram model, pick the next word in the 2 gram file (the last 1 word of the input sentence) with the highest score
# if not found in the 2 gram model, return the word with the highest probability in the one gram file.
#

library(shiny)
library(NLP)
library(tm)
library(RWeka)
source("Prediction Model Codes.R")  # the codes used to predict the next word.


shinyServer(
  function(input, output) {
    #output$inputsentence <- renderPrint({input$input})
    #observeEvent(input$submit, {
     #output$prediction <- renderPrint({predict(input$input)})
      output$prediction <- renderText({predict(input$input)})
    #})
    
    
    
  }
)