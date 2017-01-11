### Note. Make sure you have the latest version of R (not RStudio) installed before running this code, as some packages
### may not be available in older versions. These lines of code will simply install and load the required packages
### for the paper. You can ignore them and just proceed down to 'twitter_tokens'

packages <- c('devtools', 'stringr', 'plyr', 'dplyr', 'reshape2', 'tokenizers', 'tidytext', 
              'qdap', 'network','RSQLite', 'httr', 'bit64', 'sna', 'ggplot2', 'ggnet', 'network')

if (length(setdiff(packages, installed.packages())) > 0) {
  install.packages(setdiff(packages, installed.packages()))
}

sapply(packages, require, character.only = TRUE)
install_github("mkearney/rtweet")
install_github("seanchrismurphy/twtools")
require(rtweet); require(twtools)

### Below is where you need to input the codes from authenticating your app.

twitter_tokens <- create_token(app = "Your App Name here",
                               consumer_key = "Your consumer key here", 
                               consumer_secret = "Your secret key here")

get_tokens()

### You can safely ignore the below if you just want to work through the tutorial ###

# If you'd like to save your tokens permanently so they don't have to be reloaded every time you restart
# Rstudio, see: https://github.com/mkearney/rtweet/blob/master/vignettes/tokens.Rmd