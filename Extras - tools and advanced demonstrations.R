#### Extensions beyond the paper examples ####

# Throughout the paper there are points at which I mention that something is possible outside of the context of an 
# example. I will now elaborate on those points. 

### Building cumulative datasets

# First, I mentioned that the twitteR package provides functionality to help cumulatively build up a dataset of tweets. 
# It does this using SQL, which stands for 'Structured Query Language'. Essentially, .SQL files are efficient ways of
# storing data. The register_sqlite_backend function tells Rstudio which .sql file you want to store your tweets in. If
# that file doesn't exist, it will be created the first time you run the line of code below. 

register_sqlite_backend("/Users/Desktop/storage.sql")

# Once you've run the code above to register an SQL file, you can use the search_twitter_and_store function. This is similar
# to searchTwitter, but instead of saving the resulting tweets to a database, it saves them to the sql file. The biggest
# advantage of this technique is that this function will add new tweets to the .sql file each time it is run, storing the previous
# ones. That is, if you run the line of code below over and over, the 'blacklives' table will fill up over time with more and more
# tweets. The table_name argument determines which table the searches tweets get stored in. If you use a new table name, a new 
# table will be created, but for an existing table name, tweets will be added to that table. 

search_twitter_and_store(searchString = '#blacklives', n = 10000, lang = 'en', resultType = 'recent', table_name = 'black_lives')

# Notice that no objects appear in the environment when you run search_twitter_and_store. That's because the tweets are being saved
# outside of R. When you want to load the tweets you've collected into a dataset, use load_tweets_db and specify the table_name. This
# will retrieve all the tweets you have stored in our .sql file. 
blacklivesload <- load_tweets_db(table_name = 'black_lives')

# The code below, when run, tells you which tables are active in your currently connected SQL file, in case you forget. 
dbListTables(twitteR:::get_db_backend())

# You can use search_twitter_and_store to collect tweets automatically over time too, without having to start it running repeatedly. 
# The following code is an R loop, which will run 20 times, storing 3000 new tweets each time and then waiting 1800 seconds (30 minutes).
# To successfully run an R loop, you will need to select all of the lines below, from 'for' to the '}' line, and click run. At the moment
# this code will run for 10 hours (i.e. overnight), collecting tweets all the while. By changing the number 20 (how many times it runs)
# or the number 1800 (how long it waits between runs) you can alter this number. 

for (i in 1:20) {
  # Interestingly, #alllives finds less than #alllivesmatter. I didn't realise it was non-greedy.
  search_twitter_and_store(searchString = '#blacklivesmatter', n = 3000, lang = 'en', resultType = 'recent', table_name = 'blacklives')
  Sys.sleep(1800)
}

### Searching within a geographic range

# I mention in the paper that there are arguments that allow you to restrict searchTwitter to only search within a certain
# geographic or date range. The first of these can accomplished with the geocode argument. This restricts the search to only
# tweets that are tagged within a certain geographic radius. For instance, in the code below, I have input the longitude and
# latitude of the city of boston "41.8818, -87.6231", and a radius (100mi). Note that these need to be entered exactly as
# below (no spaces, and a comma between them). If you run this code, you will notice that the API will probably not be
# able to return 5000 tweets - you will get a message saying that it would only return X tweets. This is because the majority
# of tweets are not geocoded. Twitter will first check for users who GPS shows is within your search area, then it will fall
# back on user described location (finding people who have marked their hometown as Boston in the location field). But many users
# have no location or cannot be matched easily to a location, and so searching by geocode will likely result in slimmer pickings
# than a normal search. You can specify a geocode argument to search_twitter_and_store, however, so it is possible to build
# up a dataset of tweets within a specific area over time. 
bostonsox <- searchTwitter('Red Sox', n = 5000, lang = 'en', resultType = 'recent', geocode = "41.8818,-87.6231,100mi")

### Searching within a date range

# Searching tweets within a date range is less useful to use because the API only allows us to search a week back in time at
# most anyway. However, if you wanted to capture the tweets for a specific day only (perhaps a day the Red Sox won), you
# can use the since and until arguments to set the oldest and most recent tweets you will accept, respectively. Note that this
# does not conflict with the resultType argument - that simply specifies that we don't want 'popular' tweets to be mixed in with
# our searches. Both since and until must by of the format "YYYY-MM-DD". You will need to change the values here, most likely, as
# they will fall outside the one week search window by the time you read this paper. If your until range is more than a week ago
# you will get a Warning message saying that 5000 tweets were requested but the API can only return 0. 
bostontoday <- searchTwitter('Red Sox', n = 5000, lang = 'en', resultType = 'recent', since = "2016-08-30", until = "2016-08-31")


### Using the get_timelines function for lab studies

# I mention in the paper that lab studies of the form conducted by Qiu, Lin, Ramsey and Yang (2012) could be conducted with
# the get_timelines function (part of the twtools package). The get_timelines function works similarly to userTimeline, but
# with a list of users, instead of just one, making it easier for this kind of study. nstatus determines how many tweets we 
# attempt to retrieve from each user - set it as high as you like (if you are studying high-intensity Twitter users, there
# may by the full 3200 available). In the next two lines, we clean the tweets and use dictionary_count with type = 'timeline', 
# as we did in the christian tweets example in the paper (because we're working with timelines). However, if you just wanted to
# export the timelines straight to LIWC to do the cleaning, you could do that too (with write.csv after the get_timelines function
# is run). 

users <- c('seanchrismurphy', 'katiehgreenaway', 'JoCeccato')
timelines <- get_timelines(users, nstatus = 200)

timelines <- clean_tweets(timelines)
timelines <- dictionary_count(timelines, type = 'timeline')

# What if you've collected the usernames of a number of Twitter users in the lab and have them in an SPSS dataset, and don't want 
# to enter them by hand? Assuming you can save your SPPS dataset as a .csv file, the following code will read a .csv in
# (providing you give it the right location) and set users to be the 'username' variable in that dataset (using $username - 
# change this to whatever you've called your username variable). 

userdata <- read.csv('Users/You/yourfilenamehere.csv', stringsAsFactors = FALSE)
users <- userdata$username

# Having imported your usernames from a .csv file, the following code will use get_timelines to retrieve those users' timelines and save
# them in a new .csv, which you can then use however you wish. 
timelines <- get_timelines(users, nstatus = 200)
write.csv(timelines, 'Users/You/yourtimelines.csv', row.names = FALSE)
