# Twitter Data
# Aug 26, 2015
# Yichu Li

require(rjson)
setwd('C:/Users/Yichu/Desktop/Data_Analytics_Business_Insight')

rm(list=ls())

test_data	 <- fromJSON(file='Data/tweet_NYC_20150826.json')
