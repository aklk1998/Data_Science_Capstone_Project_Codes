Data Science Capstone Project README.md

The requirement of the Data Science Capstone Project is to develop a Shiny application to predict the next word of multiple words input by the user.
The prediction model is based on the Stupid Backoff Natural Language Processing (NLP) algorithm. This program uses 3 documents (corpus) (blogs, news, twitter) provided by [Swiftkey] (https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip) to build n grams tables (1 to 5). Next calculate the frequency and respective probabilities which are used for prediction.
For example, A 3 grams table contains 2 lines: (1) I work hard and (2) I work late. P(late|I work) is 1/2.

Data Preparations:
1.  Read in the 3 English version of the Swiftkey documents (blogs, news, twitter).
2.  Clean up the data by first converting them to lower case and ASCII coding, then removing the punctuations, the numbers, the extra white spaces, stop words and the leading and trailing blanks.
3.  Combine the 3 files into one.
4.  Due to the RAM size and processing power, only 10% of the data is used to build a single corpus.
5.  Build n grams (1 to 5) tables from the corpus.
6.  Calculate the probabilities based on the frequency.
7.  Store the results to a SQL Light database.

How Does the Shiny Application Work:
1.  Reload the n gram tables from the SQL Light database.
2.  Clean up the user input
3.  Based on the Stupid Backoff Model, extract the last 4/3/2/1 words from the cleaned up input and then apply them to the respective n gram tables for prediction and discount the respective probabilities. For example, input is : Ha I am going to
    * 'am going to' to 5 grams table to predict the 5th word and extract the probabiliy.
      'am going to' to 4 grams table to predict the 4th word and multiply the probability with 0.4.
      'going to' to 3 grams table to predict the 3rd word and multiply the probability with 0.16.
      'going' to 2 grams table to predict the 2nd word and multiply the probability with 0.064
4.  Pick the next word with highest probability, return 'the' if nothing is retured.

URL of the [Shiny Application](https://aklk1998.shinyapps.io/Data_Science_Capstone_Project/)

1.  It will take 30 to 60 seconds to initialize the application.
2.  Due to data size, respond time requires more work.

File Descriptions:

1.  gramsDB: The SQL database containing n grams (1 to 5) tables.
2.  Preprocess Codes.R: Codes used to read and cleanup the 3 text files and construct the n grams tables and save them to the database.
3.  Stupid Backoff Frequency Calculation.R: Calculate the probabilities
4.  Prediction Model Codes.R: Predict the next word.
5.  ui.R: User Interface
6.  server.R: Server Program - call the routine 'Predict' and displays the output

