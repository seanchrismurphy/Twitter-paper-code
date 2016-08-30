love <- twListToDF(searchTwitter(searchString = '#love', n = 10, lang = 'en', resultType =  'recent'))
head(love, 4)



user <- twListToDF(lookupUsers(c('seanchrismurphy', 'JSherlock92', 'katiehgreenaway', 'aksaeri')))
head(user, 4)



timeline <- twListToDF(userTimeline('seanchrismurphy', n = 10, includeRts = TRUE))
head(timeline, 10)

no.rts <- timeline[!timeline$isRetweet, ]


me <- lookupUsers('seanchrismurphy')[[1]]
followers <- twListToDF(me$getFollowers())
friends <- twListToDF(me$getFriends())




Blacklives <- searchTwitter('#blacklives', n = 5000, resulttype = 'recent')
Alllives <- searchTwitter ("#alllivesmatter", n = 5000, resulttype = 'recent')
Blacklives <- category_count(clean_tweets(Blacklives))
Alllives <- category_count(clean_tweets(Alllives))
t.test(Blacklives["Anger"], Alllives["Anger"])


love_clean <- clean_tweets(love, hashtags = "trim", remove.mentions = TRUE)


lovecounts <- category_count(love_clean, group = "tweet") 
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

christians <- category_count(christians, type = 'timeline')
atheists <- category_count(atheists, type = 'timeline')

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

write.csv(blacklivesgraph, 'blacklivesnetwork.csv', row.names = FALSE)