require('RSQLite')

# This command creates a .sql file in the location that you specify, or if it already exists, it locates it. From now on, each time
# (until you restart R) that you run search_twitter_and_store, the tweets will be stored in this .sql file. They will stay there
# perpetually, and so the file will get bigger over time if you continue to run search_twitter_and_store to store tweets there.
# You can choose a table using the table_name command (in this example it's set to 'blacklives'). Then load_tweets_db retrieves
# whichever table you specify and loads it into a dataset (in this case blacklivestweets). Therefore, highlighting and running
# the code below multiple times will result in a forever-growing dataset of tweets. 

register_sqlite_backend("Users/You/tweet_storage.sql")

require(twitteR)

search_twitter_and_store(searchString = '#blacklivesmatter', n = 5000, lang = 'en', resultType = 'recent', table_name = 'blacklives')

blacklivestweets <- load_tweets_db(as.data.frame = TRUE, table_name = 'blacklives')