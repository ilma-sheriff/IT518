#Step 1: Load the required packages (including rtweet) in RStudio


install.packages("tm")
install.packages("RCurl")

install.packages("twitterR")
install.packages("rtweet")

install.packages("wordcloud")
install.packages("tidyverse")

install.packages("ggplot2")
install.packages("syuzhet")
install.packages("gridExtra")

library("syuzhet")
library("tidytext")
library(ggplot2)
library(rtweet)
require(gridExtra)
require(twitteR)
require(RCurl)
require(tm)
require(wordcloud)
require(plyr)


# Authenticate using your credentials to Twitter’s API by creating an access token. Steps on getting Twitter access tokens:

consumer_key  <- 'GztFKJWXi7BPZT4JmSTcbFV51'
consumer_secret  <- 'GbykWkjsytL1Un3nKt7xw3PEwmrEgdLlpMRKdEwYgH7e1yVMZ9'
access_token  <- '77672394-PLjdWj5mqKiMkiYOL4AyDMRafoAI2bM6Xl5tfX4OT'
access_secret  <- 'TXqiY4lVAj7uFXfgskqftVNOxbtAGrjSreA61tZ4ZxkSR'
setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)

#Step 3: Search tweets on the topic of your choice; narrow the number of tweets as you see 
#fit and decide on whether or not to include retweets. I decided to include 
#1500 tweets

p_tweets <- searchTwitter('python',  n=1500, lang="en")
p_tweets <- twListToDF(p_tweets)

#View(p_tweets)


p_text <- p_tweets$text
p_tweets <- tolower(ag_text)
p_tweets <- gsub("rt", "", p_tweets)
p_tweets <- gsub("@\\w+", "", p_tweets)
p_tweets <- gsub("[[:punct:]]", "", p_tweets)
p_tweets <- gsub("http\\w+", "", p_tweets)
p_tweets <- gsub("[ |\t]{2,}", "", p_tweets)
p_tweets <- gsub("^ ", "", p_tweets)
p_tweets <- gsub(" $", "", p_tweets)
p_tweets <- gsub("and", "", p_tweets)
p_tweets <- gsub("the", "", p_tweets)
p_tweets <- gsub("[^\x01-\x7F]", "", p_tweets)



p_bd_corpus = Corpus(VectorSource(p_tweets))
# Inspect the corpus
inspect(p_bd_corpus[1:10])


# Clean the corpus by removing punctuation, numbers, and white spaces

p_bd_corpus_bd_clean <- tm_map(p_bd_corpus,  tolower) 
p_bd_corpus_bd_clean  <- tm_map(p_bd_corpus, removePunctuation)
p_bd_corpus_bd_clean  <- tm_map(p_bd_corpus, removeNumbers)
p_bd_corpus_bd_clean  <- tm_map(p_bd_corpus, removeWords, stopwords("en"))
p_bd_corpus_bd_clean  <- tm_map(p_bd_corpus, stripWhitespace)
p_bd_corpus_bd_clean  <- iconv(p_bd_corpus,to="utf-8-mac")
p_bd_corpus_bd_clean <- tm_map(p_bd_corpus, removeWords, c("python", "Python"))



# Modify your Word Cloud
par(bg = "black")
wordcloud(p_bd_corpus_bd_clean,
          min.freq = 20,
          colors=brewer.pal(8, "Dark2"),
          random.color = TRUE,
          max.words = 100,
          scale = c(6, 0.5))


#sentiment analysis

mysentiment_p <- get_nrc_sentiment((p_text))

#calculationg total score for each sentiment
Sentimentscores_p <- data.frame(colSums(mysentiment_p[,]))

names(Sentimentscores_p)<-"Score"
Sentimentscores_p<-
  cbind("sentiment"=rownames(Sentimentscores_p),Sentimentscores_p)
rownames(Sentimentscores_p)<-NULL



#plotting the sentiments with scores
ggplot(data=Sentimentscores_p,aes(x=sentiment,y=Score))+geom_bar(aes(fill=sentiment),stat = "identity")+
  theme(legend.position="none")+
  xlab("Sentiments")+ylab("scores")+ggtitle("Sentiments of people behind the tweets on Python Programming")
