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
# as below. Run this command now: it will take a few seconds to run. 

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
# time to run than the first example. Run this command now.

user <- lookupUsers('seanchrismurphy')

# Again, we need to use the twListToDF function to convert the user object to an actual dataset. From now on I won't make special
# mention of this step. Run this command now. 

user <- twListToDF(user)

# Running the head command will now show the user dataset containing only my user object, as displayed in Figure 3 of the paper. 
head(user)


## Example 3 (page 8)

# This code retrieves one hundred tweets from my timeline (the history of my postings on Twitter). Run both lines below.

timeline <- userTimeline('seanchrismurphy', n = 100)
timeline <- twListToDF(timeline)

# As always, we can take a look at the first 6 of these using the head function.
head(timeline)

# If you look at the environment window, you'll notice that the timeline object only has 25 observations, even though
# we requested 100. This is partly because I don't have 100 tweets in total to retrieve. It's also in part due to the 
# fact that userTimeline, by default, ignores tweets of mine that are retweets of someone else. Usually this is what
# we want, but we can change the arguments to usertimeline to get different behavior if we want. By adding
# the includeRts = TRUE parameter, we'll retrieve all of my timeline, not just my original postings. This need not be run.

timeline <- userTimeline('seanchrismurphy', n = 100, includeRts = TRUE)
timeline <- twListToDF(timeline)

# Notice that there are now 47 observations in the timeline object (at the time of my writing this), which is the total of 
# original tweets and retweets on my timeline.

## Example 4 (page 9)

# This code retrieves my followers and friends. The first line of code retrieves the user information for myself. In this particular
# case, we don't convert it to a dataset, because we're not interested in looking at my user information directly, 
# we want to look at my followers. And the get_Followers and get_Friends functions work directly on the information 
# retrieved from Twitter, before it is converted to a dataset. Run the code below now. 
me <- lookupUsers('seanchrismurphy')


# So long as the previous line of code has been run, the next two lines will retrieve a list of my followers and friends, respectively. 
# Run the two lines below now.
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
# row for each tweet. Run this line now.

redsox_clean <- clean_tweets(redsox, hashtags = "trim", remove.mentions = TRUE)

# Note that there are other options for the hashtags command, 'keep', and 'remove'. If set to 'keep', the hashtags will be left as they are
# with the hash symbol intact (this will prevent dictionary matching but still contribute to the word count). If set to 'remove', they will be
# deleted entirely, not contributing to dictionary matching or word counts. I would recommend either using 'trim' or 'remove' in most cases, 
# depending on what you think the hashtags in your sample are conveying. 

# remove.mentions can be set to FALSE to keep the mentions in the cleaned dataset. This is actually how the create_mentions_network function
# builds ties, under the hood (so to speak). 

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
# of valid words in the tweet, and the proportions of the words that match each dictionary. Run this line now.

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
# Also note that write.csv should be called on datasets, not lists - check that an object is in the 'Data' section of the
# Environment window.
write.csv(redsox_count, "Users/Desktop/red sox clean.csv", row.names = FALSE)

# We can also display just one cleaned tweet and the percentages associated with it, as in Figure 6 from the paper. 
# Note that when a line of R code ends with a comma, R will continue waiting for more code to complete the command. So if
# you highlight both of the below lines of code and run them, it will run to completion. Highlight just the first and click
# run, and R will wait for further input (and may give an error if you try to then run something which doesn't complete
# the first line). 
redsox_count[100, c('clean_text', 'word_count', 'anger_perc', 'anticipation_perc', 'disgust_perc', 'fear_perc', 
                    'joy_perc', 'negative_perc', 'positive_perc', 'sadness_perc', 'surprise_perc', 'trust_perc')]

# Example 7 (Page 11)

# In this example, we are searching Twitter for some new tweets (about blacklivesmatter), cleaning and performing dictionary analysis on 
# these tweets, and then comparing the percent of negative words in these tweets to those in our redsox dataset. Run this line now.
blacklives <- searchTwitter('#blacklives', n = 5000, lang = 'en', resultType = 'recent')

# In this line we strip the retweets from blacklives and turn it into a dataset. Note that the ; allows us to run two separate
# lines of code on a single line - without this, there would be an error. Run this line now.
blacklives <- strip_retweets(blacklives); blacklives <- twListToDF(blacklives)

# Run these two lines to clean and count the tweets, ready to be compared.
blacklives_clean <- clean_tweets(blacklives)
blacklives_count <- dictionary_count(blacklives_clean)

# We are using the $ here to retrieve only the negative_perc variable from each dataset, and then compare them with the t.test function, 
# which performs Welsh's t test. The results of the t test will appear in the Console window, containing the t value, p value, means of 
# each group, and other information. In my case (as reported in the paper) there were many more negative words in the blacklives_count
# dataset than the redsox_count dataset. 
t.test(redsox_count$negative_perc, blacklives_count$negative_perc)

# You can also test the comparison for positive words. In fact, when I run this line I see that the blacklives tweets also have far
# more positive emotion than the redsox tweets. Perhaps baseball is just an unemotional topic! 
t.test(redsox_count$positive_perc, blacklives_count$positive_perc)

# Example 8 (Page 12)

# In this example, we are using a new function, collect_follower_timelines, to take a list of users and gather the timelines of their
# followers. In the first two lines, we gather the user data for our focal individuals, using the lookupUsers function. The first line, 
# for instance, collects user information on Pontifex, DinishDSouza, etc - and stores it in the christian.icons object

# Run both the below lines now.
christian.icons <- lookupUsers(c('Pontifex', 'DineshDSouza', 'JoyceMeyer', 'JoelOsteen', 'RickWarren'))
atheist.icons <- lookupUsers(c('RichardDawkins', 'SamHarrisOrg', 'ChrisHitchens', 'Monicks', 'MichaelShermer')) 

# These lines use the collect_follower_timeslines function to retrieve the timelines of followers for these individuals. The collect_follower_timelines
# function takes a number of arguments to specify how many followers of each person to look for (defaults to 100), how many of their tweets to download
# (defaults to 200) and a minimum number of tweets a user must have to be included in the final dataset (defaults to 20). Type ?collect_follower_timelines
# in the console for more information on the default values and how to alter them. 

# Note that this example will take quite a while to run at the default setting (potentially an hour or so), and will take longer if nfollowers 
# and nstatus are set higher than the default, as well as if more users are used as input. If you're in a hurry, you can
# change the nfollowers argument, like so: collect_follower_timelines(christian.icons, nfollowers = 20). Then run both lines.

christians <- collect_follower_timelines(christian.icons)
atheists <- collect_follower_timelines(atheist.icons)

# In this line, we clean the christians dataset and the atheists dataset using clean_tweets. Run these lines.
christians <- clean_tweets(christians); atheists <- clean_tweets(atheists)

# You may notice that dictionary_count has an extra argument below, type. Usually, dictionary_count has a default value for 
# the type argument, set to 'tweet'. This tells it to break tweets into word tokens, count them, then aggregate back up to
# the tweets that it started with. If type is set to 'timeline', the counts are aggregated at the user level instead. This won't
# make much difference for most datasets, but when we're looking at user timelines where many tweets are available for each user, 
# this will calculate the dictionary counts at the user timeline level instead of the tweet level. We wouldn't want to analyse
# timelines at the tweet level, at least not without properly accounting for non-independence with multi-level modelling. Run both
# of the lines below.

christians <- dictionary_count(christians, type = 'timeline')
atheists <- dictionary_count(atheists, type = 'timeline')

# Now we use a t test to compare the percentage of positive words used by atheists versus christians 
t.test(atheists$positive_perc, christians$positive_perc)

# Example 9 (Page 14)

# Now we move on to social networks. The code below collects a series of usernames in the usernames object 
# (this is technically known as a vector since it is a single column). Then it uses the create_closed_network
# function to build a follower network out of these individuals by searching for their followers. Then we 
# can turn this dataset of links (network) into a 'graph' object in R, using graph_from_edgelist. We use
# the as.matrix command because graph_from_edgelist expects a matrix, which is slightly different to a 
# data frame (which our datasets usually are). Run all the lines, up to and including 'linkmap <- graph_from_edgelist(as.matrix(network))'

usernames <- c('seanchrismurphy', 'aksaeri', 'matti_wilks', 'JessieSunPsych', 'katiehgreenaway', 
               'adamdbulley', 'morgantear', 'claireknaughtin', 'VivianTa22', 'jordanaxt', 
               'iamstillmad', 'antlee53', 'LydiaHayward2', 'JoCeccato', 'JSherlock92')
network <- create_closed_network(usernames)

linkmap <- graph_from_edgelist(as.matrix(network))


# This little bit of code is extra. It won't matter for the example run here, but if we run it with a different
# list of users, there may be individuals who have no ties to anyone else. 
# By default, graph_from_edgelist will create a network that doesn't have a node for individuals who have no links 
# to anyone else, because they won't be represented in the network dataset. The code below searches for
# individuals who were in usernames but are not in the network, and adds them to the network as isolates, with no
# links to anyone else. 
isolates <- setdiff(usernames, vertex.attributes(linkmap)$name)
linkmap <- add.vertices(linkmap, nv = length(isolates), name = isolates, value = isolates)

# The plot command will display a figure similar to Figure 7 from the paper in the plot window to the bottom right of RStudio
plot(linkmap)

# The degree command will display degree of the network as shown in the paper. You can also save this information using the 
# left arrow operator, as usual.
degree(linkmap)

# Note that the saved_degrees object will appear in the environment if this line of code is run. 
saved_degrees <- degree(linkmap)


# The closeness command calculates closeness. Notice that we have set normalized to TRUE (this scales closeness from 0 to 1), and
# mode to 'all'. The mode to 'all' argument essentially treats links from and individual in the same way as links to them, basically
# treating network ties as if they are always unidirectional. You can change this to 'in', or 'out', if you like, and it will give
# closeness scores based on distances calculated on ties going only one way (from or to an individual). 
closeness(linkmap, normalized = TRUE, mode = 'all')

# Example 10 (Page 16)

# In the final example from the paper, we create a mentions network from the blacklives tweet dataset we downloaded earlier.
# create_mentions_network searches for mentions between users and creates a network based on these. Technically, we only need
# to run the first line of code below (creating the mentions dataset of links) and then we can run write.csv to export it to
# Gephi. Mentionmap creates the network within R, but notice that if you run plot(mentionmap) the resulting plot is so 
# crowded that it becomes hard to read. Run the first line now.
mentions <- create_mentions_network(blacklives)
mentionmap <- graph_from_edgelist(as.matrix(mentions))

# To export this network for visualisation in Gephi, run the below code (changeing the directory to one of 
# your choosing). In the SOM I show how to import this network into Gephi. Run this line now if you want to 
# export data to Gephi.
write.csv(mentions, '/Users/Sean/Desktop/blacklives mentions network.csv', row.names = FALSE)

# This is the end of the paper examples - for some additional commands and information, you can now open 'SOM extra examples.R'