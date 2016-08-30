packages <- c('devtools', 'stringr', 'plyr', 'dplyr', 'reshape2', 'tokenizers', 'tidytext', 
              'qdapDictionaries', 'igraph','RSQLite')

if (length(setdiff(packages, installed.packages())) > 0) {
  install.packages(setdiff(packages, installed.packages()))
}

install_github('geoffjentry/twitteR')
install_github('seanchrismurphy/twtools')

library(twitteR)

# Replace the values in quotes with your keys retrieved from https://apps.twitter.com/
setup_twitter_oauth(consumer_key = "R2Sxxxxxxxxxxxxxx", 
                    consumer_secret = "Dd0xxxxxxxxxxxxxxxxxxxxxx",
                    access_token = "279xxxxxxxxxxxxxxxxxxxxxxxx",
                    access_secret = "bRnHrTxxxxxxxxxxxxxxxxxx")

twitteR:::get_authenticated_user()
