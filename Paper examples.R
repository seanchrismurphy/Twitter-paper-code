# Before running anything else in this file, you'll want to select these two lines of code and click 'Run'.
# This loads the packages we installed in "Start here.R" so that the functions within them are available.
# These lines of code will need to be run (along with the Twitter authorization in 'Start here.R' whenever
# you restart RStudio).

require(stringr); require(plyr); require(dplyr); require(reshape2); require(tidytext); require(tokenizers)
require(qdapDictionaries); require(igraph); require(RSQLite); require(twitteR); require(twtools)


# First, a quick example of how RStudio and R code works will help as we work through the paper. You make 
# things happen in RStudio by running code. To do that, one way is to highlight the code in this window
# (the "Source" window) and click 'Run'. Another way is to type the code into the "Console" window below,
# and hit Enter. Both have the same effect, but having code in a Source window makes it easier to run 
# again, and it can be saved. 

2 + 2

# As mentioned in the paper, you can use the <- to save the results of a command into an R "Object". 
# This object will then appear in the environment window, in the upper right corner of RStudio. 
a <- 2 + 2

# We can then see the value stored in an object by typing its name.
a

# That's fine when we're looking at single numbers. But datasets tend to be big, and printing the entire thing would
# overwhelm the screen. So usually we use the head function, which by default prints the first 6 rows of a dataset,
# though in this case it will just print the number 4, since that's all there is to print.

head(a)


### Alright, now we're ready to start tackling the examples from the paper. ###

## Example 1 (page 9)

# This code retrieves 5000 tweets about the Boston Red Sox. Provided you managed to complete "Start here.R", you should
# be able to highlight the line of code below in order to run this command. Note that it will take a little while
# to execute, as R must retrieve all 5000 tweets from Twitter. While the code is running, you'll notice a small
# red stop sign symbol appear at the top right of the console window. When the code completes, the stop sign will
# dissappear and the redsox object will appear in the environment window. 

redsox <- searchTwitter(searchString = 'Red Sox', n = 5000, lang = 'en')


# Now, there are one or two further steps that must be taken before we actually have a useful dataset of tweets. 

# First, it's common practice to remove retweets when examining tweet data, because these are copies of other people's 
# statuses and we're usually interested in the statuses posted by each individual (this also cuts down on duplicate tweets). 
# The strip_retweets function removes retweets from the set we've collected. Note that we're essentially overwriting the 
# original redsox object with a new one. 

redsox <- strip_retweets(redsox)

# The second thing we want to do is convert our tweets to a familiar dataset. The searchTwitter function actually 
# gives us a slightly different R object called a list. It's not really important to know what a list is right now, 
# but in order to get our tweet data into a nice dataset with one tweet per row, we need to use the twListToDF command, 
# as below. This command will take a few seconds to run. 

redsox <- twListToDF(redsox)


# Now that our tweets are in the form of a dataset, we can take a look at then with the head command. This will show the first
# few rows (tweets) that we've collected. Notice that this will fill the Console window and you'll likely need to scroll up a 
# little to actually see the tweet text. 

head(redsox)

## Example 2 (page 9)

# This code retrieves a single user object (mine). Because we're only asking for one user, it will take a lot less 
# time to run than the first example. 

user <- lookupUsers('seanchrismurphy')

# Again, we need to use the twListToDF function to convert the user object to an actual dataset. From now on I won't make special
# mention of this step. 

user <- twListToDF(user)

# Running the head command will now show the user dataset containing only my user object, as displayed in Figure 4 of the paper. 
head(user)


## Example 3 (page 10)

# This code retrieves one hundred tweets from my timeline (the history of my postings on Twitter)

timeline <- userTimeline('seanchrismurphy', n = 100)
timeline <- twListToDF(timeline)

# As always, we can take a look at the first 6 of these using the head function.
head(timeline)

# If you look at the environment window, you'll notice that the timeline object only has 25 observations, even though
# we requested 100. This is partly because I don't have 100 tweets in total to retrieve. It's also in part due to the 
# fact that userTimeline, by default, ignores tweets of mine that are retweets of someone else. Usually this is what
# we want, but we can change the arguments to usertimeline to get different behavior if we want. By adding
# the includeRts = TRUE parameter, we'll retrieve all of my timeline, not just my original postings. 

timeline <- userTimeline('seanchrismurphy', n = 100, includeRts = TRUE)
timeline <- twListToDF(timeline)

# Notice that there are now 47 observations in the timeline object, which is the total of original tweets and retweets on
# my timeline.



me <- lookupUsers('seanchrismurphy')

get_Followers <- function(list) {
  lapply(list, function(x) x$getFollowers())
}

get_Friends <- function(list) {
  lapply(list, function(x) x$getFriends())
}

hold <- get_followers(lookupUsers(c('seanchrismurphy', 'katiehgreenaway')))

sapply(me, function(x) x$getFollowers())

followers <- twListToDF(me$getFollowers())
friends <- twListToDF(me$getFriends())




Blacklives <- searchTwitter('#blacklives', n = 5000, resulttype = 'recent')
Alllives <- searchTwitter ("#alllivesmatter", n = 5000, resulttype = 'recent')
Blacklives <- dictionary_count(clean_tweets(Blacklives))
Alllives <- dictionary_count(clean_tweets(Alllives))
t.test(Blacklives["Anger"], Alllives["Anger"])


love_clean <- clean_tweets(love, hashtags = "trim", remove.mentions = TRUE)


lovecounts <- dictionary_count(love_clean, group = "tweet") 
summary(love)

write.csv(lovecounts, "Users/Directory/yourfilenamehere.csv", row.names = FALSE)

blacklives <- searchTwitter('#blacklivesmatter', n = 5000, lang = en, resultType = 'recent')
alllives <- searchTwitter('#alllivesmatter', n = 5000, lang = en, resultType = 'recent')

redsox <- searchTwitter(searchString = 'Red Sox', n = 1000, lang = 'en')


redsox <- twListToDF(redsox)
redsox <- strip_retweets(redsox)
redsox[!redsox$isRetweet, ]
head(redsox[!redsox$isRetweet & !grepl('http', redsox$text), 'text'])


blacklives <- searchTwitter('#blacklivesmatter', n = 5000, lang = en, resultType = 'recent')
blacklives <- clean_tweets(blacklives)
blacklives <- dictionary_count(blacklives)

t.test(redsox$negative_prop, blacklives$negative_prop)





christian.icons <- lookupUsers(c('Pontifex', 'DineshDSouza', 'JoyceMeyer', 'JoelOsteen', 'RickWarren'))
atheist.icons <- lookupUsers(c('RichardDawkins', 'SamHarrisOrg', 'ChrisHitchens', 'Monicks', 'MichaelShermer')) 

christians <- collect_follower_timelines(christian.icons, N = 200)
atheists <- collect_follower_timelines(atheist.icons, N = 200)

christians <- clean_tweets(christians); atheists <- clean_tweets(atheists)

christians <- dictionary_count(christians, type = 'timeline')
atheists <- dictionary_count(atheists, type = 'timeline')

mentions <- build_mentions_network(christians)
mentionmap <- graph_from_edgelist(as.matrix(mentions))



usernames <- c('seanchrismurphy', 'aksaeri', 'matti_wilks', 'JessieSunPsych', 'katiehgreenaway', 
               'adamdbulley', 'morgantear', 'claireknaughtin', 'VivianTa22', 'jordanaxt', 
               'iamstillmad', 'antlee53', 'LydiaHayward2', 'JoCeccato', 'JSherlock92')
network <- create_closed_network(usernames)

linkmap <- graph_from_edgelist(as.matrix(network))
isolates <- setdiff(usernames, vertex.attributes(linkmap)$name)
linkmap <- add.vertices(linkmap, nv = length(isolates), name = isolates, value = isolates)
plot(linkmap)

degree(linkmap)
closeness(linkmap, normalized = TRUE)



# Mentions network
blacklivesmentions <- create_mentions_network(blacklives)
  
require(igraph)
blacklivesgraph <- graph_from_edgelist(as.matrix(blacklivesmentions))
blacklivesgraph <- simplify(blacklivesgraph, remove.multiple = FALSE, remove.loops = TRUE)
plot(blacklivesgraph)

# This network is too big to visualise easily in igraph, but we can write.csv to export it to a file
# that gephi can import.

write.csv(blacklivesmentions, 'blacklivesnetwork.csv', row.names = FALSE)
