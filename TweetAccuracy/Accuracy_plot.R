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
  #geom_text(aes(label=round(accuracy,2)),hjust=-1.7 ,vjust=0.5, color="black", size=4)+
  geom_pointrange(aes(x=name,ymax=accuracy+ci,ymin=accuracy-ci),color="black") +
  geom_errorbar(aes(x=name,ymax=accuracy+ci,ymin=accuracy-ci),color="black",width=0.2) +
  geom_text(aes(label=round(accuracy,2)),hjust=1.2 ,vjust=1.5, color="white", size=4) +
  guides(fill=FALSE) +
  ylab("Accuracy") + xlab("Entity Extraction Model")
