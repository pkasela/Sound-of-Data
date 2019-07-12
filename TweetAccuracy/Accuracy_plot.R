library(ggplot2)

setwd("/home/pranav/Desktop/Sound-of-Data/TweetAccuracy/")
df <- read.csv("tweet_accuracy.csv") 

#IC 95 per la media:
#calcoli standard deviation dei dati -> sd
# è media +- 1.96 sd/sqrt(n)

df_our <- data.frame(name = "OUR_FUNCTION", accuracy = mean(df$Our_Accuracy)*100)
df_our$ci <- 1.96*sd(df$Our_Accuracy)/sqrt(nrow(df))*100
df_IBM <- data.frame(name = "IBM_WATSON", accuracy = mean(df$IBM_Accuracy)*100)
df_IBM$ci <- 1.96*sd(df$IBM_Accuracy)/sqrt(nrow(df))*100

ggplot(rbind(df_our,df_IBM),aes(x=name,y=accuracy,fill=name)) + 
  geom_bar(stat='identity') +
  geom_pointrange(aes(x=name,ymax=accuracy+ci,ymin=accuracy-ci),color="black") +
  geom_errorbar(aes(x=name,ymax=accuracy+ci,ymin=accuracy-ci),color="black",width=0.2) +
  geom_text(aes(label=round(accuracy,2)),hjust=1.2 ,vjust=1.5, color="white", size=4) +
  guides(fill=FALSE) +
  ylab("Musical Accuracy") + xlab("Entity Extraction Model")

df_freq <- data.frame(musical_or_not = factor(c("yes","no"),levels=c("yes","no")) ,
                                              frequency = c(60,40))
#è una prova binomiale quindi si usa sqrt(p*(1-p)/N)*1.96 con p = 0.6
df_freq$ci <- sqrt(0.6*(1-0.6)/100)*1.96*100

ggplot(df_freq,aes(x=musical_or_not,y=frequency,fill=musical_or_not)) + 
  geom_bar(stat='identity') +
  geom_pointrange(aes(x=musical_or_not,ymax=frequency+ci,ymin=frequency-ci),color="black") +
  geom_errorbar(aes(x=musical_or_not,ymax=frequency+ci,ymin=frequency-ci),
                color="black",width=0.2) +
  guides(fill=FALSE) +
  ylab("Percentage") + xlab("Is Tweet Musical?")
