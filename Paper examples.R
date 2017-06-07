# Before running anything else in this file, you'll want to select the lines of code below (from 7 to 23) and
# click 'Run' in the top right of this window. This will check if you have all the required packages, and
# install and load them if not, ensuring that you'll be able to work through the examples, even if you haven't
# worked through the authentication SOM and run Start here.R. These lines of code will need to be re-run
# (along with the Twitter authorization in 'Start here.R', if relevant to you) whenever you restart Rstudio.

packages <- c('devtools', 'stringr', 'plyr', 'dplyr', 'reshape2', 'tokenizers', 'tidytext',
              'qdap', 'network','RSQLite', 'httr', 'bit64', 'sna', 'ggplot2', 'network')

if (length(setdiff(packages, installed.packages())) > 0) {
  install.packages(setdiff(packages, installed.packages()))
}


require(devtools)
if (!('rtweet' %in% installed.packages())) {
  install_github("mkearney/rtweet")
}

if (!('twtools' %in% installed.packages())) {
  install_github("seanchrismurphy/twtools")
}

# Note: If you receive an error message from qdap about RJava failing to load, you will need to go
# to this site to download and install the Java development tools 
# http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html
# then restart R and try install.packages(rJava); require(rJava). If you still get an error message
# try running install.packages("rJava",,"http://rforge.net/",type="source") and following the prompts.


if (!('ggnet' %in% installed.packages())) {
  install_github("briatte/ggnet")
}

sapply(c(packages, 'twtools', 'rtweet', 'ggnet'), require, character.only = TRUE)

# Once that's done, let's start with a quick example of how RStudio and R code works will help as we work
# through the paper. You make things happen in RStudio by running code. To do that, one way is to highlight
# the code in this window (the "Source" window) and click 'Run'. Another way is to type the code into the
# "Console" window below, and hit Enter. Both have the same effect, but having code in a Source window makes
# it easier to run again, and it can be saved.

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


### Alright, now we're ready to start tackling the code from the paper. ###

# This first section just covers the commands I walk through in the 'What data can you get?' section of
# the paper. These are the basic commands to retrieve data from Twitter, and are part of the rtweet
# package, written by Michael Kearney. I will go into a little more detail here about exactly what you
# can expect to receive from these commands, and how to view the results.

# If you haven't registered a Twitter app and authenticated yourself using 'Start here.R', you won't be
# able to run the commands in this section, but I would still recommend reading through the comments to learn
# a little about how R works, before proceeding to the 'Paper examples' section.

## Downloading tweets

# As mentioned in the paper, this line of code will download 1000 tweets about the Boston Red Sex. If you
# have completed "Start here.R", you'll be able to run this line of code by highlighting it and clicking
# 'Run' in the top right.Note that it will take a little while
# to execute, as R must retrieve all 1000 tweets from Twitter. While the code is running, you'll notice a small
# red stop sign symbol appear at the top right of the console window. When the code completes, the stop sign will
# disappear and the redsox object will appear in the environment window.

redsox <- search_tweets(q = 'Red Sox', n = 1000, lang = 'en')

# You might get slightly less than 1000 tweets, if there aren't enough tweets about the Red Sox in the
# previous week. The search terms are also fairly specific - searching for "Red Sox" won't get you 'RedSox',
# for instance. See https://dev.twitter.com/rest/public/search for more details. That page also has
# information about some other parameters you can input into search_tweets - for instance, you can specify a
# certain geographic range.


## Downloading users

# This code retrieves a single user object (mine). Because we're only asking for one user, it will take a lot less
# time to run than the first example. I've changed the line from the paper slightly to actually save the retrieved
# data in an object called user, so you can take a look at it if you like.

user <- lookup_users('seanchrismurphy')

# Running the head command will now show the user dataset containing only my user object, as displayed in Figure 3 of the paper.
# You'll notice that viewing R datasets like this isn't particularly pretty, especially when some variables contain very
# wide blocks of text (like the columns containing url links to my profile image).
head(user)

# To view the variables contained in this user object, you can use the colnames function, by running the
# command below. This makes it easier to tell what information is available. As mentioned in the paper,
# there's quite a bit of meta-data (see the paper for a link to the Twitter API page that describes each
# data field in more detail)
colnames(user)


## Downloading users - timelines

# This code retrieves up to two hundred tweets from my timeline (the history of my postings on Twitter). While
# we're only asking for 20, 200 is the smallest number the API will return, as this is what Twitter counts as
# one 'page' of results. You'll notice that (unless you are running this code quite a while after the paper is
# published) I do not have close to 200 tweets. That means that when the 'timeline' object appears in the
# upper right hand window of Rstudio, it will likely have less than 200 rows, as each row is one tweet.

timeline <- get_timeline('seanchrismurphy', n = 20)

# As before, we can take a look at the first 6 tweets using the head function.
head(timeline)


## Downloading users - followers and friends

# the next two lines will retrieve a list of my followers and friends (people I follow), respectively. You can
# run the two lines of code below now.

followers <- get_followers('seanchrismurphy')
friends <- get_friends('seanchrismurphy')

# If you examine the followers and friends objects using the head function, you'll see that they just contain
# a string of user ids. To be efficient, Twitter only gives us the IDs of users when we ask for things like
# followers and friends. Then, if we want more information in my followers, for instance, we can ask Twitter
# To 'hydrate' these user ids into a dataset of full information. We do this with the lookup_users function.


# Running either of the below lines of code will retrieve the full dataset of user information about my
# followers and friends, respectively. Note that when we use the left arrow in R, we are assigning data to
# be held in an object, as I said before. That means that the lines below are replacing the existing
# followers object, for example, with the result of 'lookup_users(followers)'. Essentially, replacing the
# object that contained just IDs, with a new object containing more information.

followers <- lookup_users(followers)
friends <- lookup_users(friends)

# R allows us to look at a single variable in a dataset using the $ and the variable name. This might be
# interested if we just wanted to look at the screenName field, to see who my followers are more succinctly.
# The following line of code, for instance, will show only the screenNames of my followers, providing that the
# previous lines have been run.

followers$screen_name

### Paper examples ###

# Now it's time to load up the example data used in the paper. The first two datasets we'll load in are
# example datasets of tweets about #Monday and #Friday (These are artificially generated - for details,
# see the main SOM).

# In order to load in this data, you will need to change your 'working directory' - the place that R looks
# for data by default. The easiest way to do that is using the dropdown menus in RStudio. Simple select
# 'Session' from the menu at the top of the screen, then 'Set Working Directory' and then 'Choose Directory.'
# You will then need to navigate to the folder where you downloaded the Twitter paper code, and select
# the 'Example data' folder. Then click OK.

# If you've done this correctly, then when you run the following line of code, you should see the names of
# the three example datasets appear.
list.files()

# Assuming that you've successfully set that up, you can then highlight and run the following two lines of
# code. This will load in both example datasets we'll work through.

load('Example dataset 1 - Monday tweets.RData')
load('Example dataset 2 - Friday tweets.RData')

# Each dataset contains 100 example tweets - mainly just the text, without other details. You can view these
# tweets using the head command, as before. Notice that this will fill the Console window and you'll likely
# need to scroll up a little to actually see the tweet text.
head(monday)

# Ignoring the missing data, you'll see that the first few columns have some basic meta-data, as well as the
# text, which will be the key focus in this tutorial.

# In R, the '$' symbol allows you to select a specific variable, and square brackets can be used to specify a
# range. for, for instance, if you want the text of the first five tweets, as I showed in the paper, then you
# can run the following command uses the $ symbol to select the text variable, and the [1:5] indicator asks R
# to select (and print) only the first five elements of this variable.

monday$text[1:5]

# One thing that you'll notice is that this doesn't look exactly like the output in the paper. The emojis
# are missing, and instead we see strange looking codes. These codes are actually UTF-8 codes, used to
# represent things like emojis in systems that can't easily display them. However, there is a workaround
# to display emojis in R, using the cat function. If you run the line of code below, it will show the
# output as it appears in the paper.

cat(paste(monday$text[1:5], collapse = '\n'))


# Alright, let's get to work analyzing the text in these example tweets. From here on out, we'll be mostly
# using functions from the 'twtools' package - a package I wrote to help clean and analyze tweet data, as
# well as make it easier to build networks and do a few othe rthings.


# As a first step, we'll want to use clean_tweets to clean the text in the monday data, as in the paper.
# As I said in the paper, clean_tweets strips many types of noise from tweet text and returns a dataset
# with a 'clean_text' column attached. It does this by tokenizing the tweets (breaking them down into their
# components), stripping out certain tokens, and then stitching them back together. I haven't gone too much
# into the details of tokenization in the paper, but you can see Kern et al (2016) for an overview, though
# this tokenizer is somewhat simpler than the ones they describe.

# Run this line of code now
monday <- clean_tweets(monday)

# After running clean_tweets, you can run the head() command again to see what's changed in the monday
# dataset.
head(monday)

# You'll notice that there's a clean_text column (it looks like Figure 5 in the paper). There's also a
# word count (which only counts the words in this new clean text column). In addition, there's a column
# for emojis (which clean_tweets removes, but saves here in case you want to recode them for use in dictionary
# analysis, a strategy I discuss in Table 2 of the paper). And emoji_count gives a count of the emojis in
# the original tweet, which can be useful as a control variable in dictioanary analyses, since users with
# many emojis might use less emotion words.

# Note that clean_tweets also removes retweets by default. This is common practice when examining tweet data,
# because these are copies of other people's statuses and we're usually interested in the statuses posted by
# each individual (this also cuts down on duplicate tweets). There are arguments that can be specified to
# change this (or other) features of clean_tweets. You can type ?clean_tweets to see the help page which
# describes these in more detail if you are interested.

# At this point, if you are more comfortable working outside of R, the monday data frame is ready to be
# exported for analysis in LIWC or other programs (see main SOM for details on LIWC). R doesn't have a
# drop-down menu to save data, but it does have commands to export it. The write.csv command, below, takes the
# monday dataset and exports it to a .csv file, which is an excel spreadsheet-style format that can be opened
# by almost all statistical software programs. You will need to replace the "file" argument with the directory
# path indicating where you would like to save the .csv file.
write.csv(monday, 'tweets for LIWC.csv')

# Presuming we continue on within R, we can now use the dictionary_count function on the monday data. Run
# the line of code below.
monday <- dictionary_count(monday)

# Now use head to take a look at what's changed about the monday dataframe.
head(monday)

# As you can see, there are now counts, for each tweet, of how many tokens (e.g. words) match each of the NRC
# lexica. In the paper, we're most interested in the negative counts. To look at just this column, you can
# use the $ operator, as we did before.
monday$negative_count

# Now we're just about ready to run our final analysis, but we need to clean and count the friday tweets
# as well. So highlight and run the lines of code below.

# Cleaning and counting friday tweets
friday <- clean_tweets(friday)
friday <- dictionary_count(friday)

# Looking at the negative count of Friday tweets, you can already see that they're quite a bit lower (I
# made them this way, after all).
friday$negative_count

# Now we can run a t.test to compare across the two datasets. This tests whether the values in the monday
# dataset for negative word count are significantly different to the values in the friday dataset for the
# same thing. You can ignore the var.equal = TRUE argument for now.
t.test(monday$negative_count, friday$negative_count, var.equal = TRUE)

# If you've followed along correctly, you should get the same results as I do in the paper - a t value
# of 7.32, df = 198, p value 5.81e-12 (That just means .0000(etc)0581). The difference is highly
# significant.

# Now, dictionary count returns the raw counts of words that match each dictionary. But often you'll want
# to run analyses on percentages of words that match. This has the benefit of control for different numbers
# of words in different tweets (and this becomes more important when you're looking at user timelines, where
# the number of words available may differ dramatically). To do this, you can create a 'percentage' column
# in the data like this:
monday$perc_negative <- monday$negative_count/monday$word_count
friday$perc_negative <- friday$negative_count/friday$word_count

# And then test the difference between them. In this case, the results are pretty similar (t = 8.11). But
# it's usually good practice to check both types of analysis, to make sure that different numbers of words
# aren't driving your results.
t.test(monday$perc_negative, friday$perc_negative, var.equal = TRUE)


# Note that, as I mention in the paper, at this point the data is ready to be exported to analyse in your
# favored package of choice (e.g. SPSS) if you'd rather not run your t tests and other analyses in R.
# To do this simply, we just need to create a condition code so that we know which dataset each tweet
# came from, and then join the data together into a single file. We can export it with write.csv (much
# as with the LIWC example). From here it is ready to be imported into SPSS or other analytic programs.
monday$set <- 'Monday hashtags'
friday$set <- 'Friday hashtags'
combined <- rbind(monday, friday)
write.csv(combined, 'combined monday and friday hashtags.csv')


### Ritter and colleagues conceptual replication ###

# Now we take a break from working with the example data to walk through the code to conceptually replicate
# some findings from Ritter and colleagues (2013). You won't be able to run this code if you haven't created
# your own Twitter app and authenticated using Start here.R. Even if you have, it will take some time to run,
# so you may wish to skip actually running it. But the commands are here for illustration and, if you wish,
# you should be able to replicate the findings if you run them and wait a while.

# This example uses a new function, collect_follower_timelines, to take a list of users and gather the timelines of their
# followers. In the first two lines, we save the usernames for our focal individuals.

# Run both the below lines now.
christian.icons <- c('Pontifex', 'DineshDSouza', 'JoyceMeyer', 'JoelOsteen', 'RickWarren')
atheist.icons <- c('RichardDawkins', 'SamHarrisOrg', 'ChrisHitchens', 'Monicks', 'MichaelShermer')

# As mentioned in the paper, the following lines of code will download a dataset of tweets from followers
# of the relevant icons.

# These lines use the collect_follower_timeslines function to retrieve the timelines of followers for these
# individuals. The collect_follower_timelines function takes a number of arguments to specify how many
# followers of each person to look for (it defaults to 90), how many of their tweets to download (defaults to
# 200) and a minimum number of tweets a user must have to be included in the final dataset (defaults to 20).
# Type ?collect_follower_timelines in the console for more information on the default values and how to alter
# them.

# Note that this example will take quite a while to run at the default setting (potentially an hour or so), and
# so I have set nfollowers to 10, which should allow it to run in a reasonable time, though it might not collect
# enough data to yield significant results.

christians <- collect_follower_timelines(christian.icons, nfollowers = 10)
atheists <- collect_follower_timelines(atheist.icons, nfollowers = 10)

# collect_follower_timelines essentially creates a large dataset of tweets, with one row for each tweet. It will
# contain a number of tweets (at least 20) for each follower that was randomly chosen. For all that, though, it still has
# the same shape as a normal tweet dataset, so we can use clean_tweets and dictionary_count just as before.

# In this line, we clean and count the christians dataset and the atheists dataset using clean_tweets. Run these lines.
christians <- clean_tweets(christians); christians <- dictionary_count(christians)
atheists <- clean_tweets(atheists); atheists <- dictionary_count(atheists)

# At this stage it's important to aggregate. Because we have many tweets from each user, we don't want to
# treat them as independent units (that would violate the assumption of independence). Instead, we can
# use the code below. This selects the key columns of interest (word_count and positive_count, in this case)
# and then averages them to give a single value for each of the users whose tweets we downloaded. If you
# wanted to look at different count variables, you'd change positive_count to a different count before
# running the code (or you could add more count variables after positive_count).

christians <- group_by(christians, user_id) %>% select(word_count, positive_count) %>% summarize_all(sum)
atheists <- group_by(atheists, user_id) %>% select(word_count, positive_count) %>% summarize_all(sum)

# Now, just as in our Monday/Friday example, we can use a t test to compare the percentage of
# positive words used by atheists versus christians (but this time on real data). Depending on how
# many tweets you downloaded, you may or may not get a significant result, but I have found this difference
# to be fairly reliable.
t.test(christians$positive_count, atheists$positive_count)

# And, as before, we could convert the raw counts to percentages and test those, which is what Ritter
# and colleagues did.
christians$positive_perc <- christians$positive_count/christians$word_count
atheists$positive_perc <- atheists$positive_count/atheists$word_count

# Now we can run the t test
t.test(atheists$positive_perc, christians$positive_perc)

### Black lives matter mentions ###

# In the next example from the paper, we create a mentions network from the blacklives tweets in example dataset 3.
blm <- read.csv('Example dataset 3 - Blacklivesmatter mentions.csv')

# For details on how this network was created, see the main SOM. You'll notice that if you use the head function
# on this dataset, none of the usernames look real - that's because they've been anonymized.

# The create_mentions_network searches for mentions, where one user mentions another in their tweet. It then
# creates link between users where one has mentioned the other, and builds a network based on this.

mentionmap <- create_mentions_network(blm)

# As before, ggnet2 allows us to visualise this mentions network within R. Here I've used different settings
# because this graph is much bigger than the celebrity example - the 'size.min = 4' option removes many of the
# nodes with few connections, allowing us to more easily see the central cluster of users.
ggnet2(mentionmap, size = 'degree', max_size = 6, node.color = 'black',
       edge.color = 'grey', size.min = 4) + guides(size = FALSE)

### Social networks - celebrity example ###

# Now we move on to social networks. In this example, we build a toy network by tracking who follows who among
# a set of pop musicians on twitter. The code below saves the usernames of these musicians in the usernames
# object.
celebs <- c('taylorswift13', 'lilyallen', 'katyperry', 'edsheeran',
            'lilyallen','lorde', 'elliegoulding', 'IGGYAZALEA', 'drake',
            'sia', 'rihanna', 'theweeknd', 'BrunoMars', 'Adele', 'Skrillex')

# Having done this, we can then use the create_closed_network function to build a follower network for these
# individuals. This function downloads the friends list of each user in turn, then creates a network within
# those users based on friendship ties. Note that, as before, you'll only be able to run this if you've
# authenticated with Twitter.

network <- create_closed_network(celebs)

# Note that this function pauses after each user in order not to exceed Twitter's rate limiting (see main SOM
# for more on that). Because we can get the details of friends for 15 users per 15 minutes, this function
# takes about 1 minute to run per user that you input. For larger networks (say, more than a few thousand
# users) you may need to alter the code slightly so that you can save your progress in intervals. The code for
# the twtools package is available on github (at seanchrismurphy/twtools) and so you are free to download the
# source files for the functions presented here and modify the code as you wish.

# Having created the network, you can use the ggnet2 function to re-create the graph from the paper.
# This function implements a variety of options
# in order to tweak the network graph for the paper. You can tinker with them at your discretion to
# achieve different effects. With larger networks, you may wish to use specific software packages to visualise
# them. The primary software for network visualisation at the moment is Gephi.

ggnet2(network, size = 7, node.color = 'orange', label.color = 'blue',
       edge.color = 'grey', edge.size = .5, arrow.size = 8, arrow.gap = 0.015,
       label = TRUE, label.size = 4.5)

# This is the end of the paper examples - for some additional commands and information, you can now open
# the last .R file, 'Extras - tools and advanced demonstrations.R'
