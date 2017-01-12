#### Extensions beyond the paper examples ####

# In the discussion, and main SOM, I discuss a few things that researchers will need to deal with when
# conducting Twitter research that I couldn't go into depth with in the paper. These include things like
# the streaming API, rate limiting, and storing your data. I also mention in the 'data limitations' section
# and in Table 2 of the paper, that it's often a good idea to visualise the most common words or hashtags
# in your tweet datasets to get an idea of what's going on.

# In this extras file, I delve briefly into these issues, providing a few tools that may help researchers
# to get started in dealing with them.


### Visualising common words ###

# While I didn't get a chance to go over these in the paper, the twtools package contains a few functions
# I write to make it easier to see what's happening in the text of your tweet data. There are four such
# functions - most.common.tokens, most.common.words, most.common.hashtags, and most.common.mentions.
# Each of these, if given a dataset of tweets, will break it down and print out the most common forms
# of whatever the function references (tokens means anything, words means anything that isn't a hashtag
# or a mention). For example, if you have the monday dataset loaded:

most.frequent.words(monday)

# On that particular dataset, this won't be particularly informative. But in live tweet data, these functions
# can be very helpful in identifying trends or anomalies in the data. I hope you find them useful.
most.frequent.tokens(monday)
most.frequent.hashtags(monday)
most.frequent.mentions(monday)



### Rate limiting ###

# As I mentioned in the paper, Twitter implements rate limiting to make sure you don't ask for data faster
# than it can handle. Well, really so the global population of users doesn't ask for data faster than it can
# handle. At present, if you ask for too much data in a single request, you may receive an error (however,
# the rtweet package is under active development and in the near future may handle this more gracefully).
# Without going into too much detail, a common way to avoid rate limits is to tell R to 'pause' in between
# requests, using the Sys.sleep function. This will pause R for a number of seconds. For instance, the
# command below will pause R for 60 seconds.

Sys.sleep(60)

# There are more advanced ways to handle rate limiting - the rtweet package has a rate_limits() function
# to help with this. You can read the documentation for the rtweet package here:
# https://github.com/mkearney/rtweet

### Streaming and storing data ###

# Another thing that I mentioned in the footnotes of the paper was the streaming API for twitter. This
# is designed to allow you to connect to Twitter and listen passively for tweets that you're interested
# in, without having to specifically search. More information in using the streaming API can be found
# in the rtweet documentation. But the general idea is that you connect to the streaming API with a
# query, and receive all information relevant to that query as long as you stay connected.

# However, doing this means that you will likely need to store the data at regular intervals, lest you lose it
# in a computer crash. As I mentioned in the paper, storage of data is often a primary concern when working
# with Twitter, as you will often be collecting data over time and need to keep it safe.

# One of the best ways to store data received from Twitter is to use SQL, which stands for 'Structured Query
# Language'. Essentially, .SQL files are efficient ways of storing data. The dbConnect function
# will allow you to create or connect to an SQL file from R, which you can use to store your tweets.

# For instance, assuming that you change the file name in the line of code below to a valid location on your
# system, Rstudio will create an SQL file and connect to it (or just connect to it, if it already exists).
# We can then use 'con' (the connection) to connect to our SQL file.

require(rtweet); require(RSQLite); library(twitteR); library(httr)
con <- dbConnect(RSQLite::SQLite(), "/Users/Sean/My first storage file.sql")

# You can then use the dbWriteTable function to write datasets into the SQL file. Then you can later use
# the dbReadTable function to retrieve the data.

# You will need to specify the name of a table within the SQL file (each SQL file can have many tables
# to store different kinds of data. You could have a different table for each day that you collect data,
# for instance). For example, if you have the 'monday' tweet dataset loaded into Rstudio, the following
# commands will save it to the SQL file we just created, into the 'days' table.

RSQLite::dbWriteTable(con, name = 'days', monday, append = TRUE)

# And then this command will read it back out.
RSQLite::dbReadTable(con, name = 'days')

# The benefit of this is that you can continually write data to an SQL file using the same commands, and it
# won't overwrite the previous data, it will just add the new data. So if you are streaming data from Twitter
# for a long period of time, regularly writing the new data to SQL is a great way to store it. Then, when your
# code is done running, you can retrieve it to analyse.


# A common use case for this is that you wish to stream a certain search time from Twitter, saving
# data periodically. I have provided the code below to help you get started with this. While too complicated
# to explain in detail, it essentially connects to Twitter and collects the live stream of tweets for a
# given amount of time, saving data periodically to SQL. You can set how long it runs by changing the
# minutes parameter, and change the search term by putting it into the quotations marks
# after 'stream_tweets'. If you change the line of code below first to create your own SQL file, this will
# continuously stream and store tweets of interest in that SQL file until you are ready to retrieve them.

con <- dbConnect(RSQLite::SQLite(), "/Users/Sean/test.sql")

# This will run for i minutes.
for (i in 1:minutes) {

  e <- stream_tweets("", timeout = 60, clean_tweets = FALSE)

  e_users <- users_data(e)

  # Note that this breaks if 0 tweets are returned.
  e_tweets <- longlat(tweets_data(e))

  # This removes non-english users for efficiency of storage
  e_tweets <- e_tweets[e_tweets$lang %in% 'en', ]
  e_users <- e_users[e_users$lang %in% 'en', ]

  # This writes the tweets and the users table to the SQL dataframe.

  RSQLite::dbWriteTable(con, name = 'tweets', e_tweets, append = TRUE)
  RSQLite::dbWriteTable(con, name = 'users', e_users, append = TRUE)
}

### Searching within a geographic range

# While I didn't mention these in the paper, there are arguments that allow you to restrict search_tweets
# to only search within a certain geographic or date range. The first of these can accomplished
# with the geocode argument. This restricts the search to only tweets that are tagged within a certain
# geographic radius. For instance, in the code below, I have input the longitude and latitude of the city of
# boston "41.8818, -87.6231", and a radius (100mi). Note that these need to be entered exactly as below (no
# spaces, and a comma between them). If you run this code, you will notice that the API will probably not be
# able to return 5000 tweets. This is because, as I say in the paper, the majority of tweets are not geocoded.
# Twitter will first check for users who GPS shows is within your search area, then it will fall back on other
# location fields (such as places tagged in the tweet). However, searching by geocode will likely still result
# in slimmer pickings than a normal search. You can specify a geocode argument to search_twitter_and_store,
# however, so it is possible to build up a dataset of tweets within a specific area over time.
bostonsox <- search_tweets('Red Sox', n = 5000, lang = 'en', geocode = "41.8818,-87.6231,100mi")

### Searching within a date range

# Searching tweets within a date range is less useful,  because the API only allows us to search a week back in time at
# most anyway. However, if you wanted to capture the tweets for a specific day only (perhaps a day the Red Sox won), you
# can use the since and until arguments to set the oldest and most recent tweets you will accept, respectively. Note that this
# does not conflict with the resultType argument - that simply specifies that we don't want 'popular' tweets to be mixed in with
# our searches. Both since and until must by of the format "YYYY-MM-DD". You will need to change the values here, most likely, as
# they will fall outside the one week search window by the time you read this paper. If your until range is more than a week ago
# you will get a Warning message saying that 5000 tweets were requested but the API can only return 0.
bostontoday <- search_tweets('Red Sox', n = 5000, lang = 'en', since = "2016-08-30", until = "2016-08-31")

