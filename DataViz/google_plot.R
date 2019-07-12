library(ggplot2)
library(dplyr)
library(corrplot)

setwd("/home/pranav/Downloads/Telegram Desktop/")

df = read.csv("csv_with_range.csv")

df

df %>% group_by(dUtile) %>% summarise(count = n()) %>% mutate(count=count/nrow(df)) -> df_utile
p=df_utile$count[1]/sum(df_utile$count)
df_utile$ci <- sqrt(p*(1-p)/nrow(df)*1.96)
df_utile$ci[1] = df_utile$count[1] + df_utile$ci[1]
df_utile$ci[2] = df_utile$count[1] - df_utile$ci[2]
df_utile$name <- "Utile"
df_utile$voto <- df_utile$dUtile

df %>% group_by(dInt) %>% summarise(count = n()) %>% mutate(count=count/nrow(df)) -> df_Int
p=df_Int$count[1]/sum(df_Int$count)
df_Int$ci <- sqrt(p*(1-p)/nrow(df)*1.96)
df_Int$ci[1] = df_Int$count[1] + df_Int$ci[1]
df_Int$ci[2] = df_Int$count[1] - df_Int$ci[2]
df_Int$name <- "Intuitiva"
df_Int$voto <- df_Int$dInt

df %>% group_by(dCh) %>% summarise(count = n()) %>% mutate(count=count/nrow(df)) -> df_Ch
p=df_Ch$count[1]/sum(df_Ch$count)
df_Ch$ci <- sqrt(p*(1-p)/nrow(df)*1.96)
df_Ch$ci[1] = df_Ch$count[1] + df_Ch$ci[1]
df_Ch$ci[2] = df_Ch$count[1] - df_Ch$ci[2]
df_Ch$name <- "Chiara"
df_Ch$voto <- df_Ch$dCh

df %>% group_by(dIn) %>% summarise(count = n()) %>% mutate(count=count/nrow(df)) -> df_In
p=df_In$count[1]/sum(df_In$count)
df_In$ci <- sqrt(p*(1-p)/nrow(df)*1.96)
df_In$ci[1] = df_In$count[1] + df_In$ci[1]
df_In$ci[2] = df_In$count[1] - df_In$ci[2]
df_In$name <- "Interessante"
df_In$voto <- df_In$dIn

df %>% group_by(dB) %>% summarise(count = n()) %>% mutate(count=count/nrow(df)) -> df_B
p=df_B$count[1]/sum(df_B$count)
df_B$ci <- sqrt(p*(1-p)/nrow(df)*1.96)
df_B$ci[1] = df_B$count[1] + df_B$ci[1]
df_B$ci[2] = df_B$count[1] - df_B$ci[2]
df_B$name <- "Bella"
df_B$voto <- df_B$dB

df %>% group_by(dT) %>% summarise(count = n()) %>% mutate(count=count/nrow(df)) -> df_T
p=df_T$count[1]/sum(df_T$count)
df_T$ci <- sqrt(p*(1-p)/nrow(df)*1.96)
df_T$ci[1] = df_T$count[1] + df_T$ci[1]
df_T$ci[2] = df_T$count[1] - df_T$ci[2]
df_T$name <- "Totale"
df_T$voto <- df_T$dT

total <- rbind(df_Int[,-1],df_utile[,-1],df_Ch[,-1],
               df_In[,-1],df_B[,-1],df_T[-1])

total$voto <- factor(total$voto, levels = c("[4-6]","[1-3]"))

ggplot(total) + 
  geom_bar(aes(x=name,y=count,fill=voto),stat='identity') +
  geom_errorbar(aes(x=name,ymax=ci,ymin=ci)) +
  xlab("Domanda") + ylab("Popolazione relativa")+
  coord_flip()

ggplot(total) + 
  geom_bar(aes(x=name,y=count,fill=voto),stat='identity') +
  geom_errorbar(aes(x=name,ymax=ci,ymin=ci)) +
  xlab("Domanda") + ylab("Popolazione relativa")+
  coord_flip()

M <- cor(df[2:7])
corrplot(cor(df[2:7]),type="lower",addCoef.col = "black",
         tl.srt=45,method = "ellipse",diag = T)

library(GGally)

my_fn <- function(data, mapping, method="p", use="pairwise", ...){
  
  # grab data
  x <- eval_data_col(data, mapping$x)
  y <- eval_data_col(data, mapping$y)
  
  # calculate correlation
  corr <- cor(x, y, method=method, use=use)
  
  # calculate colour based on correlation value
  # Here I have set a correlation of minus one to blue, 
  # zero to white, and one to red 
  # Change this to suit: possibly extend to add as an argument of `my_fn`
  colFn <- colorRampPalette(c("red", "white", "blue"), interpolate ='spline')
  fill <- colFn(100)[findInterval(corr, seq(-1, 1, length=100))]
  
  ggally_cor(data = data, mapping = mapping, ...) + 
    theme_void() +
    theme(panel.background = element_rect(fill=fill))
}
ggpairs(df[2:7],label = TRUE,upper = list(continuous = my_fn),
        lower = list(continuous = "smooth"))
