# library(nortest)
library("psych")
library("ltm")
library("nFactors")
options(digits = 3)
opar <- par(no.readonly=TRUE)

dt <- read.table("data.csv", sep = ";", header = TRUE)
dt <- dt[, c(-1, -3)]
dt$Пол <- factor(dt$Пол, levels = c(1, 2), labels = c("Мужской", "Женский"))
dt$Возрастная.группа <- factor(dt$Возрастная.группа, levels = c(1, 2), labels = c("1986.1988", "1999.1992"))
desc.stats <- psych::describe(dt, skew = FALSE)
print(desc.stats)
pie(table(dt$Пол))

# Проверка соответствия нормальному закону распределения
norm.test.out <- t(sapply(dt[3:15], FUN = function(x) shapiro.test(x)[1:2]))
colnames(norm.test.out) <- c("W", "p")
print(norm.test.out)

# различия в группах по полу
gender.test.out <- t(sapply(dt[,4:15], FUN = function(x) wilcox.test(x ~ dt$Пол, data = dt)[c(1,3)]))
colnames(gender.test.out) <- c("W", "p")
print(gender.test.out)
gender.means <- aggregate(dt[4:15], by = list(dt$Пол), FUN = mean, na.rm = TRUE)[-1]
rownames(gender.means) <- c("Мужчины", "Женщины")
print(t(gender.means))
par(mar=c(7, 2, 4, 0) + 0.1, xpd = TRUE)
barplot(t(gender.means), beside=T, col = rainbow(12), ylim = 0:1)
title(main = "Средние значения в группах\nмужчин и женщин")
legend(-3, -0.15, legend = names(gender.means), lty = 1, lwd = 3, col = rainbow(12), bty = "n", ncol = 3)
par(opar)

# Корреляционный анализ
cor.matrix <- rcor.test(as.matrix(dt[,4:15]), method = "spearman")
print(cor.matrix)

# Факторный анализ
ev <- eigen(cor(dt[,4:15]))
ap <- parallel(subject=nrow(dt),var=ncol(dt[,4:15]), rep=1000,cent=.05)
nS <- nScree(ev$values, ap$eigen$qevpea)
print(nS)
plotnScree(nS)
fa.parallel(dt[,4:15], fm = "pa")
fit <- fa(dt[,4:15], nfactors=5, rotate="promax", fm="ml")
print(fit)
print(fit$loadings, digits=2, cutoff=.2, sort=TRUE)