# Text mining of Tweets
# Yichu Li
# Sep 21, 2015

require(rmongodb)
require(SnowballC)
require(tm)
require(wordcloud)

setwd("C:/Users/Yichu/Desktop/Data_Analytics_Business_Insight")

rm(list=ls())

# Parameter setting
#NS			<-	"twitter.tweets_sample"
NS			<-	"twitter.tweets"
time_begin	<-	'Wed Aug 30 21:00:00 +0000 2015'
time_end	<-	'Wed Aug 30 23:59:59 +0000 2015'

# Converting time to unix time
time_begin_unix	<-	as.character(as.numeric(as.POSIXct(strptime(time_begin, format="%a %b %d %H:%M:%S %z %Y"))))
time_end_unix	<-	as.character(as.numeric(as.POSIXct(strptime(time_end, format="%a %b %d %H:%M:%S %z %Y"))))

# Remember to run MongoDB daemon on localhost before running the code below!
mongo	<-	mongo.create()
mongo.is.connected(mongo)

# get text from MongoDB
count	<-	mongo.count(mongo=mongo, ns=NS, query=list('timestamp_ms'=list('$lte'=time_end_unix), 'timestamp_ms'=list('$gt'=time_begin_unix)))
Sys.time()
test	<-	mongo.find.all(mongo=mongo, ns=NS, query=list('timestamp_ms'=list('$lte'=time_end_unix), 'timestamp_ms'=list('$gt'=time_begin_unix)), fields=list('text'=1L,'created_at'=1L), limit=0, data.frame=TRUE)
Sys.time()

# Pre-Processing
# step 1: to lower case. simple :)
Text		<-	tolower(test$text)


# step 2: remove punctuation except... 
#gsub("[^A-Za-z0-9#]","","abc*&#$%1230A|")
#Text		<-	sub("[#]|[[:punct:]]", "\\1", Text)


# step 3: tokenize. only space, need to consider tab and enter
Text		<-	strsplit(Text, split=c(" "), fixed=FALSE)

myStopwords	<-	stopwords('english')

Text		<-	sapply(Text, function(x)
					{
						x						<-	x[!x %in% myStopwords] # remove stop words
						nm						<-	x
						x						<-	gsub("[^a-z0-9#@ ]", "", x) # keep only alphabetic letter, number, hashtag, at and space
						x[grep("http", x=x)]	<-	 "http" # normalize http
						x[grep("@", x=x)]		<-	 "atsbd" # normalize @
						nm						<-	nm[nchar(x)>0]
						x						<-	x[nchar(x)>0] # remove word that has 0 character
						
						# step 5: stemming
						
						x						<-	wordStem(x, language="english")
						names(x)				<-	nm
						return(x)
					}, simplify=FALSE)

# need to remove weird characters
# need to keep hashtag feature
# need to normalize http and @
# need to enlarge stop word list
# need to study retweets

# rebuilt the text
Text.whole	<-	sapply(Text, function(x)
					{
						return(paste(x, collapse=' '))
					}, simplify=FALSE)					
Text.whole	<-	do.call("rbind", Text.whole)
myCorpus	<-	Corpus(VectorSource(Text.whole))
myDtm 		<-	TermDocumentMatrix(myCorpus, control = list(minWordLength = 1)) # build document term matrix
inspect(myDtm[10:20,10:20])
findFreqTerms(myDtm, lowfreq=10)
findAssocs(myDtm, '#newyork', 0.30)

findAssocs(myDtm, '#sheskindahotvma', 0.3)

Text.whole[grepl("#sheskindahotvma", Text.whole) & grepl("#galaxylif", Text.whole)]




# vectorize
if (FALSE)
{
Vocabulary	<-	read.table("Data/vocab.txt", header=FALSE, sep='\t', stringsAsFactors=FALSE)[,2]
#Text.mat	<-	matrix(0, nrow=length(Text), ncol=length(Vocabulary))
Text.pos	<-	sapply(Text, function(x)
					{
						return(sort(na.omit(match(x, Vocabulary)))) # return the position in vocabulary
					}, simplify=FALSE)
}

Word.count	<-	data.frame(Word="a", count=0)
Text.pos	<-	sapply(Text, function(x)
					{
						#count		<<-	count+1
						pos			<-	sort(na.omit(match(x, Word.count$Word)))
						if (length(pos)>0)
							Word.count$count[pos]	<<-	Word.count$count[pos]+1
						#print(count)
						if (length(pos)<length(x))
							Word.count	<<-	rbind(Word.count, data.frame(Word=x[!(x %in% Word.count$Word)], count=1))
					}, simplify=FALSE)
Word.count	<-	Word.count[order(Word.count$count, decreasing=TRUE),]
wordcloud(Word.count$Word[-c(1,2)], Word.count$count[-c(1,2)], min.freq=300, scale=c(2,0.2))

write.table(Word.count$Word, "Data/stoplist.txt", quote=FALSE, row.names=FALSE, col.names=FALSE)