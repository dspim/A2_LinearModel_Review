rm(list = ls())
if (!require("dplyr")) {
  install.packages("dplyr")
}
if (!require("ggplot2")){
  intall.packages("ggplots")
}
if (!require("GGally")){
  install.packages("GGally")
}

setwd("~/Documents/R_scripts/DSP/A2/A2_Review/")

data <- read.table("demo_data_utf8.csv", sep = ",", header = T, stringsAsFactors = F)
n_obs <- dim(data)[1]
n_feature <- dim(data)[2]

# Correct the format of "Date" to "yyyy/mm/dd"
data[, "Date"] <- as.Date(data[, "Date"], format = "%m/%d/%Y")

# Filt out the data we are interested in, which in this case is the 
# observations with field "Family" equal to "運動飲料".
data_drink <- data %>%
            filter(.$Family == "運動飲料") %>%
            filter(.$SalesValue <= 500) %>%
            mutate(avg_SalesValue = SalesValue / Sales_number) %>%
            mutate(dummy_P = ifelse(.$Sales_Status == "P", 1, 0)) %>%
            mutate(dummy_H1 = ifelse(.$Store == "H1", 1, 0)) %>%
            mutate(dummy_S1 = ifelse(.$Store == "S1", 1, 0)) %>%
            mutate(dummy_P_H1 = dummy_P * dummy_H1) %>%
            mutate(dummy_P_S1 = dummy_P * dummy_S1) %>%
            mutate(high_price = ifelse(.$Price >= 21, "Y", "N"))

data_drink$Item_No %>% unique %>% length %>% print

# 我們想分析變數對飲料銷售收入(SalesValue)的影響，
# 什麼變數可能重要呢? 畫圖先!
# 地點? --> 分 Store 畫 histogram (over avg_SalesValue)
# 有無特價? --> 用 dummy_P 畫 histogram (over avg_SalesValue)
# 單價? --> Price vs. avg_SalesValue scatter plot
# 熱賣商品? --> 分 Item_No 畫 histogram (over avg_SalesValue)
# 上午下午? --> hist
# http://everdark.github.io/lecture_ggplot/lecture_ggplot2/index.html

f1 <- ggplot(data_drink, aes(x=SalesValue, y = ..density.., fill = Sales_Status)) 

f1 + geom_bar(position='identity', alpha = .4, binwidth = 30) 
f1 + geom_bar(position='identity', alpha = .4, binwidth = 30) +
  geom_density(kernel = 'gaussian')

ggplot(data_drink, aes(x=Price, y=SalesValue, color=Item_No)) +
  geom_point()

ggplot(data_drink, aes(x=SalesValue, fill = high_price)) +
  geom_bar(position='identity', alpha = .5, binwidth = 20)

ggplot(data_drink, aes(x=SalesValue, fill = Store)) +
  geom_bar(position='identity', alpha = .5, binwidth = 10)

data_drink %>% filter(.$Store == "S1") %>% ggplot(., aes(x=SalesValue, fill = Store)) +
  geom_bar(position='identity', alpha = .5, binwidth = 10)

data_drink %>% filter(.$Store == "T1") %>% ggplot(., aes(x=SalesValue, fill = Store)) +
  geom_bar(position='identity', alpha = .5, binwidth = 10)

data_drink %>% filter(.$Store == "H1") %>% ggplot(., aes(x=SalesValue, fill = Store)) +
  geom_bar(position='identity', alpha = .5, binwidth = 10)

# 如果 Sales_Status 跟 Store 無關，每個區塊應該看起來差不多稠密。
ggplot(data_drink, aes(x = Sales_Status, y = Store, color = Store)) + 
  geom_point(position = 'jitter', alpha = .5)

fit <- lm(SalesValue ~ Price + Time + Store, data = data_drink)
summary(fit)


ind <- sample(1:nrow(data_drink), nrow(data_drink) %/% 10)
small_data <- data_drink[ind, ]
fit_small <- lm(SalesValue ~ Price + Time + Store, data = small_data)
summary(fit_small)

## ggpirs
data(iris)
ggpairs(iris, colour='Species', alpha=0.4, params = c(binwidth = 0.1))
