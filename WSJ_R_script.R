## Import the scraped WSJ data

## Word cloud of titles, articles

## graph showing articles per day over past few months
## articles per section
## top authors, top comments??, 
## time of day of articles
## % of articles updated, depends on length(?)

## words near "trump" / "clinton"
## text analysis of those words and of the average article
## changed over time?

## text blob - phrases?

WSJ = read.csv("WSJ_articles.csv")
head(WSJ)
str(WSJ)

head(WSJ$date, 300)
WSJ$updated = ifelse(grepl("Updated", WSJ$date), 1, 0)

WSJ$date = (gsub('\n |Updated | Updated | ET\n','', WSJ$date))
WSJ$date = sapply(strsplit(WSJ$date, split='ET', fixed=TRUE), function(x) (x[1]))
WSJ$date = trimws(WSJ$date)
WSJ$puredate = WSJ$date
WSJ$puredate
WSJ$puredate = (gsub('September ','9/', WSJ$puredate))
WSJ$puredate = (gsub('August ','8/', WSJ$puredate))
WSJ$puredate = (gsub(', ','/', WSJ$puredate))
WSJ$puredate = (gsub('Sept. ','9/', WSJ$puredate))
WSJ$puredate = (gsub('Aug. ','8/', WSJ$puredate))
WSJ$puredate = (gsub('Nov. ','11/', WSJ$puredate))
WSJ$puredate = sapply(strsplit(WSJ$puredate, split=' ', fixed=TRUE), function(x) (x[1]))
WSJ$puredate = as.Date(WSJ$puredate, format = "%m/%d/%Y")

library(dplyr)
library(ggplot2)

counts = WSJ %>%
  select(puredate) %>%
  group_by(puredate) %>%
  filter(puredate <= "2016-09-02") %>%
  summarize(count = n())

counts = as.data.frame(counts)
  
ggplot(counts, mapping = aes((puredate), count)) + 
  geom_bar(stat = "identity", col = "white",
           fill = "steelblue") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
#  coord_flip() +
  labs(title = "Total Number of Articles Published By Date", 
       x = "", 
       y = "")

WSJ$weekday = weekdays(as.Date(WSJ$puredate))

weekdays = WSJ %>%
  select(weekday, puredate) %>%
  group_by(weekday) %>%
  filter(puredate <= "2016-08-29") %>%
  summarize(count = round(n()/2))

weekdays = as.data.frame(weekdays)

weekdaygraph <- data.frame(day = c("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"), 
                     count = c(116, 206, 245, 266, 264, 194, 68), 
                     order = seq(1:7))

ggplot(weekdaygraph, mapping = aes(reorder(day, order), count)) + 
  geom_bar(stat = "identity", col = "white",
           fill = "steelblue") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  #  coord_flip() +
  labs(title = "Average Number of Articles Published By Weekday", 
       x = "", 
       y = "")

str(WSJ)
WSJ$title2 = as.character(WSJ$title)
WSJ$title2 = (gsub('â€™',"'", WSJ$title2))
WSJ$title2 = (gsub('â€˜',"'", WSJ$title2))
WSJ$title2 = (gsub('â€”',"-", WSJ$title2))
WSJ$title2 = (gsub('Ã³',"ó", WSJ$title2))
WSJ$title2 = (gsub('Â',"", WSJ$title2))
WSJ$title2 = trimws(WSJ$title2)


Photos of the Day
"Winning numbers drawn in 'Pick 10' game"
"What's News: Business & Finance" 


library(tm)
library(SnowballC)
library(wordcloud)
wsjCorpus <- Corpus(VectorSource(WSJ$title2))
wsjCorpus <- tm_map(wsjCorpus, content_transformer(tolower))
wsjCorpus <- tm_map(wsjCorpus, removePunctuation)
wsjCorpus <- tm_map(wsjCorpus, PlainTextDocument)   
wsjCorpus <- tm_map(wsjCorpus, removeWords, stopwords('english'))
wsjCorpus <- tm_map(wsjCorpus, removeWords, c("what", "number", "news", "win", "drawn", "pick", "game", "new")) 
wsjCorpus <- tm_map(wsjCorpus, stemDocument)

wordcloud(wsjCorpus, max.words = 200, random.order = FALSE) #colors = "navy")

docs <- tm_map(wsjCorpus, PlainTextDocument)
dtm <- DocumentTermMatrix(docs)  
freq <- colSums(as.matrix(dtm)) 
ord <- order(freq)  
dtms <- removeSparseTerms(dtm, 0.1) # This makes a matrix that is 10% empty space, maximum.   
inspect(dtms) 
freq[tail(ord, 15)]
freq <- sort(colSums(as.matrix(dtm)), decreasing=TRUE)   
head(freq, 14)
wf <- data.frame(word=names(freq), freq=freq)   
head(wf) 


ggplot(subset(wf, freq > 50), aes(x=reorder(word, freq), y = freq)) +
  geom_bar(stat = "identity", col = "white",
           fill = "steelblue") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  coord_flip() +
  labs(title = "Top Words in WSJ Titles", 
       x = "", 
       y = "Word Frequency")

#trump word corr data
trumpwords = findAssocs(dtm, c("trump"), corlimit=0.12)
trumpwords = (trumpwords)[[1]]
class(trumpwords)
trumpwords = data.frame(labels(trumpwords), unname(trumpwords))
colnames(trumpwords) = c("word", "corr")

#trump words graph
ggplot(trumpwords, aes(x= reorder(word, corr), y = corr)) +
  geom_bar(stat = "identity", col = "white",
           fill = "steelblue") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  coord_flip() +
  labs(title = "Words Correlated with 'Trump'", 
       x = "", 
       y = "Correlation")

#clinton word corr data
clintonwords = findAssocs(dtm, c("clinton"), corlimit=0.12)
clintonwords = (clintonwords)[[1]]
class(clintonwords)
clintonwords = data.frame(labels(clintonwords), unname(clintonwords))
colnames(clintonwords) = c("word", "corr")

#clinton words graph
ggplot(clintonwords, aes(x= reorder(word, corr), y = corr)) +
  geom_bar(stat = "identity", col = "white",
           fill = "steelblue") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  coord_flip() +
  labs(title = "Words Correlated with 'Clinton'", 
       x = "", 
       y = "Correlation")

#split section on comma
WSJ$puresections <- gsub("\\,.*","",WSJ$sections) #remove everything after ","
WSJ$puresections <- gsub("\n","",WSJ$puresections) 
WSJ$puresections <- trimws(WSJ$puresections)
WSJ$puresections <- gsub("^$", "AP", WSJ$puresections)

str(WSJ)

justsections = WSJ %>%
  select(puresections, title2) %>%
  group_by(puresections) %>%
  summarize(count = n(), title_length = mean(nchar(title2))) %>%
  arrange(desc(count))

justsections = as.data.frame(justsections)
justsections$count_per = justsections$count/sum(justsections$count)
  

ggplot(justsections[0:24,], aes(x= reorder(puresections, count), y = count)) +
  geom_bar(stat = "identity", col = "white",
           fill = "steelblue") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  coord_flip() +
  labs(title = "Articles By Section", 
       x = "", 
       y = "")

ggplot(justsections[0:24,], aes(x= reorder(puresections, title_length), y = title_length)) +
  geom_bar(stat = "identity", col = "white",
           fill = "steelblue") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  coord_flip() +
  labs(title = "Average Title Length (Characters)", 
       x = "", 
       y = "")

wsjtitles = WSJ$title2
wsjtitles = gsub("[[:punct:]]", "", wsjtitles)
wsjtitles = gsub("[[:digit:]]", "", wsjtitles)
wsjtitles = gsub("[ \t]{2,}", " ", wsjtitles)
wsjtitles = gsub("^\\s+|\\s+$", "", wsjtitles)
try.error = function(x)
{
  y = NA
  try_error = tryCatch(tolower(x), error=function(e) e)
  if (!inherits(try_error, "error"))
    y = tolower(x)
  return(y)
}

wsjtitles = sapply(wsjtitles, try.error)
wsjtitles = wsjtitles[!is.na(wsjtitles)]
names(wsjtitles) = NULL

class_emo = classify_emotion(wsjtitles, algorithm="bayes", prior=1.0)
emotion = class_emo[,7]
emotion[is.na(emotion)] = "unknown"
class_pol = classify_polarity(wsjtitles, algorithm="bayes")
polarity = class_pol[,4]


sent_df = data.frame(text=wsjtitles, emotion=emotion,
                     polarity=polarity, stringsAsFactors=FALSE)
sent_df = within(sent_df,
                 emotion <- factor(emotion, levels=names(sort(table(emotion), decreasing=TRUE))))

ggplot(sent_df, aes(x=emotion)) +
  geom_bar(aes(y=..count.., fill=emotion)) +
  scale_fill_brewer(palette="Dark2") +
  labs(title = "Sentiment Analysis of Article Titles", x="", y="") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggplot(sent_df, aes(x=polarity)) +
  geom_bar(aes(y=..count..), fill="steel blue")  +
  labs(title = "Sentiment Analysis, Polarity Categories", x="", y="") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
  

#missingness
library(VIM)
aggr(WSJ) #A graphical interpretation of the missing values and their
#combinations within the dataset.

library(mice) #Load the multivariate imputation by chained equations library.
md.pattern(sleep) #Can also view this information from a data perspective.