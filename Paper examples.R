# Before running anything else in this file, you'll want to select these two lines of code and click 'Run'
# This loads the packages we installed in 'Start here.R', (though we already loaded them there, I include
# this just to be sure). This makes the functions contained within those packages available. These lines of 
# code will need to be re-run (along with the Twitter authorization in 'Start here.R') whenever you restart
# Rstudio.

sapply(c('devtools', 'stringr', 'plyr', 'dplyr', 'reshape2', 'tokenizers', 'tidytext', 
              'qdap', 'network','RSQLite', 'httr', 'bit64', 'sna', 'ggplot2', 'ggnet', 'network',
              'rtweet', 'twtools'), require, character.only = TRUE)

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

# This code retrieves 1000 tweets about the Boston Red Sox. Provided you managed to complete "Start here.R", you should
# be able to highlight the line of code below in order to run this command. Note that it will take a little while
# to execute, as R must retrieve all 1000 tweets from Twitter. While the code is running, you'll notice a small
# red stop sign symbol appear at the top right of the console window. When the code completes, the stop sign will
# disappear and the redsox object will appear in the environment window. Note that you might get slightly less
# than 1000 tweets

redsox <- search_tweets(q = 'Red Sox', n = 1000, lang = 'en')

# Now, there are one or two further steps that must be taken before we actually have a useful dataset of tweets. 

# First, it's common practice to remove retweets when examining tweet data, because these are copies of other people's 
# statuses and we're usually interested in the statuses posted by each individual (this also cuts down on duplicate tweets). 
# The code below removes retweets from the set we've collected. Note that we're essentially overwriting the 
# original redsox object with a new one that doesn't have retweets. Run this line of code now, and note that if you look
# at the environment window in the top right, the redsox object will now contain less than 1000 values. As I said in
# the paper, the clean_tweets function will do this by default, but it's always good to be safe in case you don't end
# up using that function to do cleaning. 


### Note this may have changed to a TRUE/FALSE by the look of it. 
redsox <- redsox[redsox$is_retweet == 0, ]


### Question. Do we actually want to have all of these extra commands here? Or should they mostly be with the 
### example datasets. I think example datasets. 




## Example 2 (page 8)

# This code retrieves a single user object (mine). Because we're only asking for one user, it will take a lot less 
# time to run than the first example. Run this command now.

user <- lookup_users('seanchrismurphy')

# Running the head command will now show the user dataset containing only my user object, as displayed in Figure 3 of the paper. 
head(user)


## Example 3 (page 8)

# This code retrieves up to two hundred tweets from my timeline (the history of my postings on Twitter). 
# 200 is the smallest number you can request currently, as this is what Twitter returns on each 'page' of
# results. You'll notice that (unless you are running this code quite a while after the paper is published)
# I do not have close to 200 tweets, and so you will likely receive less. 

timeline <- get_timeline('seanchrismurphy', n = 200)
# As always, we can take a look at the first 6 of these using the head function.
head(timeline)


## Example 4 (page 9)

# the next two lines will retrieve a list of my followers and friends, respectively. Run the two lines below now.
followers <- get_followers('seanchrismurphy')
friends <- get_friends('seanchrismurphy')

# get_followers and get_friends return datasets of user ids by default. get_followers returns a set of the ids
# of people who follow the user you asked about (me, in this case) while get_friends returns the set of ids of
# people that I follow. 

# If we want more information on the followers and friends, we can look them up with the lookupusers function.
# This function 'hydrates' (i.e., fills in the full information on) lists of user ids, like those returned
# by get_followers and get_friends. 

followers <- lookup_users(followers)
friends <- lookup_users(friends)

# R allows us to look at a single variable in a dataset using the $ and the variable name. This might be interested if we just wanted to 
# look at the screenName field, to see who my followers are more succinctly. The following line of code, for instance, will show
# only the screenNames of my followers, providing that the previous lines have been run.

followers$screenName


### Somewhere in here will need to be a setwd command, though I should walk them through the drop-down menus
### because those were way easier for my students to understand last time. 
setwd('/Users/Sean/Dropbox/Post-Doc/Manuscripts/Twitter paper/Revise and Resubmit/SOM/Example data')

### Alright, from here the paper examples file will change a fair bit, because I'm using the example tweets
### now. I should probably go and finish those off before continuing. 

load('Example dataset 1 - Monday tweets.RData')
load('Example dataset 2 - Friday tweets.RData')

# We can take a look at our tweets with the head command. This is an R function that prints the first few rows 
# of a dataset to the console window to view. Notice that this will fill the Console window and you'll likely need to scroll up a 
# little to actually see the tweet text. 

cat(paste(monday$text[1:5], collapse = '\n'))

# If you want to show the text of the first three tweets, as I did in the paper, then the following command uses the $ symbol
# to select the text variable, and the [1:3] indicator asks R to select (and print) only the first three elements of this variable.
redsox$text[1:3]


cat(paste(friday$text[1:5], collapse = '\n'))



# Example 5 (Page 10)

# In this example, we are using the clean_tweets function to tokenize the redsox dataset, cleaning the tweets and separating them out into their
# individual words so that we can then perform dictionary analysis. When you select and run this command, you'll notice that the redsox_clean
# dataset appears in the global environment. It has many more observations than redsox, because there is now a row for each word, rather than a 
# row for each tweet. Run this line now.

# Cleaning monday tweets
monday <- clean_tweets(monday)

# Could now export to LIWC if we wanted to (see other SOM for more). 
write.csv(monday, 'tweets for LIWC.csv')

# Counting Monday tweets
monday <- dictionary_count(monday)

# Cleaning and counting friday tweets
friday <- clean_tweets(friday)
friday <- dictionary_count(friday)


t.test(monday$negative_count, friday$negative_count, var.equal = TRUE)


t.test(monday$negative_count/monday$word_count, friday$negative_count/friday$word_count, var.equal = TRUE)

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

christian.icons <- c('Pontifex', 'DineshDSouza', 'JoyceMeyer', 'JoelOsteen', 'RickWarren')
atheist.icons <- c('RichardDawkins', 'SamHarrisOrg', 'ChristHitchens', 'Monicks', 'MichaelShermer')


### As mentioned in the paper, the following lines of code will download a dataset of tweets from followers
### of the relevant icons. Note that these lines of code will take some time to run (perhaps 20 minutes), 
### as this is a fairly intensive process.

# These lines use the collect_follower_timeslines function to retrieve the timelines of followers for these individuals. The collect_follower_timelines
# function takes a number of arguments to specify how many followers of each person to look for (defaults to 100), how many of their tweets to download
# (defaults to 200) and a minimum number of tweets a user must have to be included in the final dataset (defaults to 20). Type ?collect_follower_timelines
# in the console for more information on the default values and how to alter them. 

# Note that this example will take quite a while to run at the default setting (potentially an hour or so), and will take longer if nfollowers 
# and nstatus are set higher than the default, as well as if more users are used as input. If you're in a hurry, you can
# change the nfollowers argument, like so: collect_follower_timelines(christian.icons, nfollowers = 20). Then run both lines.

### Last time I ran this it hit an error in the rate limiting line, which I've fixed. 
christians <- collect_follower_timelines(christian.icons, nfollowers = 10)
atheists <- collect_follower_timelines(atheist.icons, nfollowers = 10)

# In this line, we clean and count the christians dataset and the atheists dataset using clean_tweets. Run these lines.
christians <- clean_tweets(christians); christians <- dictionary_count(christians)
atheists <- clean_tweets(atheists); atheists <- dictionary_count(atheists)

### Explain the aggregation code
# when we're looking at user timelines where many tweets are available for each user, 
# this will calculate the dictionary counts at the user timeline level instead of the tweet level. We wouldn't want to analyse
# timelines at the tweet level, at least not without properly accounting for non-independence with multi-level modelling. Run both
# of the lines below.

christians <- group_by(christians, user_id) %>% select(word_count, positive_count) %>% summarize_all(sum)
atheists <- group_by(atheists, user_id) %>% select(word_count, positive_count) %>% summarize_all(sum)

# Now we use a t test to compare the percentage of positive words used by atheists versus christians 
t.test(christians$positive_count, atheists$positive_count)

# Note that because dictionary count returns a word count column, we could divide the raw counts by the 
# word counts to analyse percentages instead of raw numbers. This is usually a good idea, given that the
# number of valid words, especially across an entire user timeline, can vary dramatically and otherwise 
# confound an analysis like this
christians$positive_perc <- christians$positive_count/christians$word_coun
atheists$positive_perc <- atheists$positive_count/atheistsword_count

# Now we can run the t test
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
# The plot command will display a figure similar to Figure 7 from the paper in the plot window to the bottom right of RStudio
plot(linkmap)


### Create_closed_network downloads the friends list of each 
### user in turn, then creates a network within those users based on friendship ties. Create_closed_network
### will pause after each user in order not to exceed Twitter's rate limiting. Because we can get the details
### of friends for 15 users per 15 minutes, create_closed_network takes about 1 minute to run per user that
### you input. For larger networks (say, more than a few thousand users) you may need to alter the code
### slightly so that you can save your progress in intervals. The code for the twtools package is available
### on github (at seanchrismurphy/twtools) and so you are free to download the source files for the 
### functions presented here and modify the code as you wish. 

celebs <- c('taylorswift13', 'lilyallen', 'katyperry', 'edsheeran', 
            'lilyallen','lorde', 'elliegoulding', 'IGGYAZALEA', 'drake', 
            'sia', 'rihanna', 'theweeknd', 'BrunoMars', 'Adele', 'Skrillex')

network <- create_closed_network(celebs)


### the ggnet2 package allows for plotting networks in R. This function implements a variety of options
### in order to tweak the network graph for the paper. You can tinker with them at your discretion to 
### achieve different effects. For even more power to visualise networks, you can export the resulting
### graph to Gephi, open source software that excels in network visualisation. I have provided a walkthrough
### of those process in the written SOM. 

ggnet2(network, size = 7, node.color = 'orange', label.color = 'blue', 
       edge.color = 'grey', edge.size = .5, arrow.size = 8, arrow.gap = 0.015,
       label = TRUE, label.size = 4.5)


### Will this work for a network graph?
# The degree command will display degree of the network. This is one of the ways mentioned in the paper to 
# characterise the centrality of actors in a network. You can also save this information using the left arrow 
# operator, as usual.
degree(linkmap)

# Note that the saved_degrees object will appear in the environment if this line of code is run. 
saved_degrees <- degree(linkmap)


# The closeness command calculates closeness. Notice that we have set normalized to TRUE (this scales closeness from 0 to 1), and
# mode to 'all'. The mode to 'all' argument essentially treats links from and individual in the same way as links to them, basically
# treating network ties as if they are always unidirectional. You can change this to 'in', or 'out', if you like, and it will give
# closeness scores based on distances calculated on ties going only one way (from or to an individual). 
closeness(linkmap, normalized = TRUE, mode = 'all')

# Example 10 (Page 16)


# In the final example from the paper, we create a mentions network from the blacklives tweets in example dataset 3.
blm <- read.csv('example dataset 3 - black lives matter.csv')

# create_mentions_network searches for mentions between users and creates a network based on these, where
# one user has mentioned another. 

mentionmap <- create_mentions_network(blm)

# As before, ggnet2 allows us to visualise this mentions network within R. 
ggnet2(mentionmap, size = 'degree', max_size = 6, node.color = 'black', 
       edge.color = 'grey', size.min = 4) + guides(size = FALSE)

# To export this network for visualisation in other probrams, like Gephi, run the below code 
# (changeing the directory to one of 
# your choosing). In the SOM I show how to import this network into Gephi. Run this line now if you want to 
# export data to Gephi.
write.csv(mentions, '/Users/Sean/Desktop/blacklives mentions network.csv', row.names = FALSE)

# This is the end of the paper examples - for some additional commands and information, you can now open 'SOM extra examples.R'