library(rvest)
library(RSelenium)
library(tidyverse)
library(wdman)

appstore_url <- "http://quotes.toscrape.com/scroll"

# eCaps <- list(chromeOptions = list(
#   args = c('--headless', '--window-size=1280,800'),
#   binary = "C:/Program Files (x86)/Google/Chrome/Application/Chrome.exe"
# ))

##-- Instead of using "latest" for version, put the version number
##-- solve the issue chrome driver was not able to support version 81
##-- No installation of Docker and chrome driver works
rD<- rsDriver(port = 4567L, browser = c("chrome"), verbose=TRUE, version = "3.141.59",
              chromever = "81.0.4044.69")

remDr <- rD$client

#navigate to your page
remDr$navigate(appstore_url)
#scroll down 5 times, waiting for the page to load at each time
for(i in 1:5){
  #remDr$navigate(appstore_url)
  remDr$executeScript(paste("scroll(0,",i*10000,");"))
  Sys.sleep(3)
}

#get the page html
remDr$getPageSource()[[1]]
page_source<-remDr$getPageSource()

main_page<-read_html(unlist(remDr$getPageSource()),encoding="UTF-8")
review_author <- main_page %>%
  html_nodes(".author") %>%
  html_text() %>%
  str_trim() 

review_text <- main_page %>%
  html_nodes(".quote") %>%
  html_text() %>%
  str_trim()

review_tags <- main_page %>%
  html_nodes(".tags") %>%
  html_text() %>%
  str_trim()

review_result <- data.frame(title = review_author, 
                            content = review_text, 
                            rating = review_tags)

remDr$close()
#rD$server$stop()
rm(remDr, rD)
gc()


