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

## Example 1 (page 7)

# This code retrieves 5000 tweets about the Boston Red Sox. Provided you managed to complete "Start here.R", you should
# be able to highlight the line of code below in order to run this command. Note that it will take a little while
# to execute, as R must retrieve all 5000 tweets from Twitter. While the code is running, you'll notice a small
# red stop sign symbol appear at the top right of the console window. When the code completes, the stop sign will
# disappear and the redsox object will appear in the environment window. 

redsox <- searchTwitter(searchString = 'Red Sox', n = 5000, lang = 'en')


# Now, there are one or two further steps that must be taken before we actually have a useful dataset of tweets. 

# First, it's common practice to remove retweets when examining tweet data, because these are copies of other people's 
# statuses and we're usually interested in the statuses posted by each individual (this also cuts down on duplicate tweets). 
# The strip_retweets function removes retweets from the set we've collected. Note that we're essentially overwriting the 
# original redsox object with a new one that doesn't have retweets. Run this line of code now, and note that if you look
# at the environment window in the top right, the redsox object will now contain less than 5000 values. 

redsox <- strip_retweets(redsox)

# The second thing we want to do is convert our tweets to a familiar dataset. The searchTwitter function actually 
# gives us a slightly different R object called a list. It's not really important to know what a list is right now, 
# but in order to get our tweet data into a nice dataset with one tweet per row, we need to use the twListToDF command, 
# as below. This command will take a few seconds to run. 

redsox <- twListToDF(redsox)

# Now that our tweets are in the form of a dataset, we can take a look at then with the head command. This is an R function 
# that prints the first few rows of a dataset to the console window to view. 
# Notice that this will fill the Console window and you'll likely need to scroll up a 
# little to actually see the tweet text. 

head(redsox)

# If you want to show the text of the first three tweets, as I did in the paper, then the following command uses the $ symbol
# to select the text variable, and the [1:3] indicator asks R to select (and print) only the first three elements of this variable.
redsox$text[1:3]

# You may notice that many tweets (especially referrencing the redsox) appear to be news items or advertisements referencing URLs.
# If you want to view only tweets without a URL, you can use the following command. This uses regular expressions (with the grepl
# function) to search for 'http', and then uses the ! indicator (which means 'NOT') to print tweets that don't contain URLs. 
redsox$text[!grepl('http', redsox$text)][1:3]

## Example 2 (page 8)

# This code retrieves a single user object (mine). Because we're only asking for one user, it will take a lot less 
# time to run than the first example. 

user <- lookupUsers('seanchrismurphy')

# Again, we need to use the twListToDF function to convert the user object to an actual dataset. From now on I won't make special
# mention of this step. 

user <- twListToDF(user)

# Running the head command will now show the user dataset containing only my user object, as displayed in Figure 3 of the paper. 
head(user)


## Example 3 (page 8)

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

# Notice that there are now 47 observations in the timeline object (at the time of my writing this), which is the total of 
# original tweets and retweets on my timeline.

## Example 4 (page 9)

# This code retrieves my followers and friends. The first line of code retrieves the user information for myself. In this particular
# case, we don't convert it to a dataset, because we're not interested in looking at my user information directly, 
# we want to look at my followers. And the get_Followers and get_Friends functions work directly on the information 
# retrieved from Twitter, before it is converted to a dataset. 
me <- lookupUsers('seanchrismurphy')


# So long as the previous line of code has been run, the next two lines will retrieve a list of my followers and friends, respectively. 
followers <- get_Followers(me)
friends <- get_Friends(me)

# get_Followers and get_Friends return datasets by default, with following and followed_by variables, respectively, so that you
# can tell which user in the input (when there is more than one) a given user in the output is related to.

# We can now use the head function to examine my followers and friends. Note that for each of them, we have retrieved their full user 
# information. 
head(followers)
head(friends)

# R allows us to look at a single variable in a dataset using the $ and the variable name. This might be interested if we just wanted to 
# look at the screenName field, to see who my followers are more succinctly. The following line of code, for instance, will show
# only the screenNames of my followers, providing that the previous lines have been run.

followers$screenName

# Example 5 (Page 10)

# In this example, we are using the clean_tweets function to tokenize the redsox dataset, cleaning the tweets and separating them out into their
# individual words so that we can then perform dictionary analysis. When you select and run this command, you'll notice that the redsox_clean
# dataset appears in the global environment. It has many more observations than redsox, because there is now a row for each word, rather than a 
# row for each tweet. 
redsox_clean <- clean_tweets(redsox, hashtags = "trim", remove.mentions = TRUE)


# The code below illustrates how the cleaning process changes the first tweet in the redsox dataset. Without going into too much detail, the first
# line uses "Subsetting" to select the text of the first tweet in the original dataset. The second line uses more complex subsetting to find the
# words from that tweet in the cleaned dataset. More information on subsetting can be found in the guides to R linked in the SOM. 
redsox[1, 'text']
redsox_clean[redsox_clean$id %in% redsox[1, 'id'], 'word']

# Example 6 (Page 11)

# In this example, we are using the dictionary_count function to take the cleaned redsox dataset and count the number of words in each tweet
# that match a number of emotion dictionaries. This will take a few moments to run, as this involves a fair amount of computation. When it is
# complete, you will see the redsox_count dataset appear in the environment window. Note that this dataset once again has less rows, because
# it has now been aggregated at one row per tweet. Each row includes the original tweet information, as well as the cleaned tweet text, number
# of valid words in the tweet, and the proportions of the words that match each dictionary. 

redsox_count <- dictionary_count(redsox_clean)

# To look at all the variables that are in the new redsox_count dataset, you can either use head again, or use the colnames function
# to just get a list of variable names.
head(redsox_count)
colnames(redsox_count)

# If you want to look at individual emotion variables, you can again use $. For instance, the code below will show the percent of positive 
# emotion words for each tweet in the redsox_count dataset

redsox_count$negative_perc

# It's more useful if we get a summary statistic, of course. The mean function will give us the mean proportion of negative words in the data. In my case,
# it's about 2.55. So 2.55% of the words used about the red sox can be classified as 'negative.'
mean(redsox_count$negative_perc)

# We could examine whether emotional intensity tends to be general by testing the correlation between negative and positive emotion. If it is positive, 
# it means that tweets with more positive emotion words also had more negative emotion words. In my case, there was no significant correlation, as indicated
# by the results that printed to the console with a p value above .05.

cor.test(redsox_count$negative_perc, redsox_count$positive_perc)


# Let's say you wanted to export this dataset with cleaned tweets and import it into a more familiar program, such as LIWC, to continue your text analysis.
# R doesn't have a drop-down menu to save data, but it does have commands to export it. The write.csv command, below, takes the redsox_count dataset
# and exports it to a .csv file, which is an excel spreadsheet-style format that can be opened by almost all statistical software programs. You
# will need to replace the "file" argument with the directory path indicating where you would like to save the .csv file. Make sure that this still
# ends with ".csv". The row.names = FALSE argument just tells the function not to include a separate variable for row names.
write.csv(redsox_count, "Users/Desktop/red_sox_clean.csv", row.names = FALSE)


# Example 7 (Page 12)

# In this example, we are searching Twitter for some new tweets (about blacklivesmatter), cleaning and performing dictionary analysis on 
# these tweets, and then comparing the percent of negative words in these tweets to those in our redsox dataset. 
blacklives <- searchTwitter('#blacklives', n = 5000, lang = 'en', resultType = 'recent')

# In this line we strip the retweets from blacklives and turn it into a dataset. Note that the ; allows us to run two separate
# lines of code on a single line - without this, there would be an error.
blacklives <- strip_retweets(blacklives); blacklives <- twListToDF(blacklives)

blacklives_clean <- clean_tweets(blacklives)
blacklives_count <- dictionary_count(blacklives_clean)

# We are using the $ here to retrieve only the negative_perc variable from each dataset, and then compare them with the t.test function, 
# which performs Welsh's t test. The results of the t test will appear in the Console window, containing the t value, p value, means of 
# each group, and other information. In my case (as reported in the paper) there were many more negative words in the blacklives_count
# dataset than the redsox_count dataset.
t.test(redsox_count$negative_perc, blacklives_count$negative_perc)


# Example 8 (Page 13)

# In this example, we are using a new function, collect_follower_timelines, to take a list of users and gather the timelines of their
# followers. In the first two lines, we gather the user data for our focal individuals, using the lookupUsers function. The first line, 
# for instance, collects user information on Pontifex, DinishDSouza, etc - and stores it in the christian.icons object

christian.icons <- lookupUsers(c('Pontifex', 'DineshDSouza', 'JoyceMeyer', 'JoelOsteen', 'RickWarren'))
atheist.icons <- lookupUsers(c('RichardDawkins', 'SamHarrisOrg', 'ChrisHitchens', 'Monicks', 'MichaelShermer')) 

# These lines use the collect_follower_timeslines function to retrieve the timelines of followers for these individuals. The collect_follower_timelines
# function takes a number of arguments to specify how many followers of each person to look for (defaults to 100), how many of their tweets to download
# (defaults to 200) and a minimum number of tweets a user must have to be included in the final dataset (defaults to 20). Type ?collect_follower_timelines
# in the console for more information on how to change these. 

christians <- collect_follower_timelines(christian.icons)
atheists <- collect_follower_timelines(atheist.icons)

# In this line, we clean the christians dataset and the atheists dataset using clean_tweets. 
christians <- clean_tweets(christians); atheists <- clean_tweets(atheists)

christians <- dictionary_count(christians, type = 'timeline')
atheists <- dictionary_count(atheists, type = 'timeline')

# Now we use a t test to compare the percentage of positive words used by atheists versus christians 
t.test(atheists$positive_perc, christians$positive_perc)

# Example 9 (Page 17)

# Now we move on to social networks. 

usernames <- c('seanchrismurphy', 'aksaeri', 'matti_wilks', 'JessieSunPsych', 'katiehgreenaway', 
               'adamdbulley', 'morgantear', 'claireknaughtin', 'VivianTa22', 'jordanaxt', 
               'iamstillmad', 'antlee53', 'LydiaHayward2', 'JoCeccato', 'JSherlock92')
network <- create_closed_network(usernames)

linkmap <- graph_from_edgelist(as.matrix(network))

# By default, this approach will create a network that doesn't have a node for individuals who have no links 
# to anyone else, because they won't be represented in the network dataset. The code below searches for
# individuals who were in usernames but are not in the network, and adds them to the network as isolates.
isolates <- setdiff(usernames, vertex.attributes(linkmap)$name)
linkmap <- add.vertices(linkmap, nv = length(isolates), name = isolates, value = isolates)
plot(linkmap)

degree(linkmap)

closeness(linkmap, normalized = TRUE, mode = 'all')

# Example 10 (Page 18)

mentions <- create_mentions_network(blacklives)
mentionmap <- graph_from_edgelist(as.matrix(mentions))

write.csv(mentions, 'blacklives mentions network.csv', row.names = FALSE)



blacklivesmentions <- create_mentions_network(blacklives)



require(igraph)
blacklivesgraph <- graph_from_edgelist(as.matrix(blacklivesmentions))
blacklivesgraph <- simplify(blacklivesgraph, remove.multiple = FALSE, remove.loops = TRUE)
plot(blacklivesgraph)

# This network is too big to visualise easily in igraph, but we can write.csv to export it to a file
# that gephi can import.

write.csv(blacklivesmentions, 'blacklivesnetwork.csv', row.names = FALSE)

