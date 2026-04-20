
# IMPORT DATA FROM Sheet "Main Data", save sebagai "dataregresi"

#Korelasi dan Statistik Deskriptif Variabel
data1 = dataregresi[,c(4:8)]
round(cor(data1),3)
summary(data1)

#scatterplot variabel dependen dan masing-masing variabel independen

plot(data1$PADPC, data1$PTR, xlab="PAD per kapita (Rp)", ylab="Rasio murid-guru SD Negeri", main="Scatterplot PTR vs PADPC")
abline(lm(PTR ~ PADPC, data = data1), col = "blue")

plot(data1$DemandSD, data1$PTR, xlab="Murid SDN per 1000 penduduk usia 7-12", ylab="Rasio murid-guru SD Negeri", main="Scatterplot PTR vs DemandSD")
abline(lm(PTR ~ DemandSD, data = data1), col = "red", lwd=2)

plot(data1$SupplySD, data1$PTR, xlab="SDN per 1000 penduduk usia 7-12", ylab="Rasio murid-guru SD Negeri", main="Scatterplot PTR vs SupplySD")
abline(lm(PTR ~ SupplySD, data = data1), col = "chocolate")


#boxplot variabel dependen utk masing-masing kategori dummy
boxplot(data1$PTR ~ data1$Dkabkota, main="PTR menurut kelompok Kabupaten dan Kota", 
        col = c("lightblue","lightpink"),
        xlab ="", ylab = "Rasio murid-guru SD Negeri")

#estimasi REGRESI DENGAN 1 VARIABEL BEBAS
regresi1 = lm(PTR ~ PADPC, data=data1)
print(regresi1)
summary(regresi1)
anova(regresi1)

#estimasi REGRESI DENGAN BEBERAPA VARIABEL BEBAS KUANTITATIF
regresi2 = lm(PTR ~ PADPC + DemandSD + SupplySD, data=data1)
summary(regresi2)
anova(regresi2)

#menampilkan beberapa hasil dari model regresi
regresi2$residuals
regresi2$fitted.values
regresi2$coefficients

#assumption: Homoskedasticity
install.packages("lmtest")
library(lmtest)
lmtest::bptest(regresi2)

#assumption: No autocorrelation of residuals
lmtest::dwtest(regresi2)

#assumption: No perfect multicollinearity
install.packages("car")
library(car)
car::vif(regresi2)

#resolving heteroskedasticity and/or autocorrelation:  robust standard error
install.packages("sandwich")
library(sandwich)
coeftest(regresi2, vcov = vcovHAC)


#PENERAPAN TRANSFORMASI LOGARITMA (FULL LOG-LOG)
regresi3 = lm(log(PTR) ~ log(PADPC) + log(DemandSD) + log(SupplySD), data=data1)
summary(regresi3)
anova(regresi3)

#assumption: Homoskedasticity
lmtest::bptest(regresi3)

#assumption: No autocorrelation of residuals
lmtest::dwtest(regresi3)

#assumption: No perfect multicollinearity
car::vif(regresi3)

#resolving heteroskedasticity and/or autocorrelation:  robust standard error
coeftest(regresi3, vcov = vcovHAC)


#PENERAPAN TRANSFORMASI LOGARITMA (LOG-LINIER)
regresi4 = lm(log(PTR) ~ log(PADPC) + DemandSD + SupplySD, data=data1)
summary(regresi4)
anova(regresi4)

#assumption: Homoskedasticity
lmtest::bptest(regresi4)

#assumption: No autocorrelation of residuals
lmtest::dwtest(regresi4)

#assumption: No perfect multicollinearity
car::vif(regresi4)

#resolving heteroskedasticity and/or autocorrelation:  robust standard error
coeftest(regresi4, vcov = vcovHAC)



#PENERAPAN REGRESI KUADRATIK (LEVEL-LEVEL)

PTR_DemandSD = lm(PTR ~ DemandSD + I(DemandSD^2), data=data1)
xgrid = seq(min(data1$DemandSD), max(data1$DemandSD), length.out=200)
yhat = predict(PTR_DemandSD, newdata = data.frame(DemandSD = xgrid))
plot(data1$DemandSD, data1$PTR,
     xlab="Murid SDN per 1000 penduduk usia 7-12",
     ylab="Rasio murid-guru SD Negeri",
     main="Scatterplot PTR vs DemandSD")
lines(xgrid, yhat, col="blue", lwd=2)

regresi5 = lm(PTR ~ PADPC + DemandSD + I(DemandSD^2) + SupplySD, data=data1)
summary(regresi5)
anova(regresi5)

regresi5a = lm(PTR ~ PADPC + I(PADPC^2) + DemandSD + SupplySD, data=data1)
summary(regresi5a)
regresi5b = lm(PTR ~ PADPC + I(PADPC^2) + DemandSD + I(DemandSD^2) + SupplySD, data=data1)
summary(regresi5b)

#assumption: Homoskedasticity
lmtest::bptest(regresi5)

#assumption: No autocorrelation of residuals
lmtest::dwtest(regresi5)

#assumption: No perfect multicollinearity
car::vif(regresi5)

#resolving H & A:  robust standard error
coeftest(regresi5, vcov = vcovHAC)



#PENERAPAN REGRESI KUADRATIK (LOG-LOG)
regresi6 = lm(log(PTR) ~ log(PADPC) + log(DemandSD) + I(log(DemandSD)^2) + log(SupplySD), data=data1)
summary(regresi6)
anova(regresi6)

#assumption: Homoskedasticity
lmtest::bptest(regresi6)

#assumption: No autocorrelation of residuals
lmtest::dwtest(regresi6)

#assumption: No perfect multicollinearity
car::vif(regresi6)

#resolving H & A:  robust standard error
coeftest(regresi6, vcov = vcovHAC)



#REGRESI DENGAN DUMMY VARIABEL X (Y dalam LOG)
regresi7 = lm(log(PTR) ~ log(PADPC) + log(DemandSD) + log(SupplySD) + Dkabkota, data=data1)
summary(regresi7)
anova(regresi7)

#assumption: Homoskedasticity
lmtest::bptest(regresi7)

#assumption: No autocorrelation of residuals
lmtest::dwtest(regresi7)

#assumption: No perfect multicollinearity
car::vif(regresi7)

#resolving H & A:  robust standard error
coeftest(regresi7, vcov = vcovHAC)

#regresi dgn dummy vs statistik deskriptif
aggregate(PTR ~ Dkabkota, data = data1, FUN = mean)



#BONUS COMBO : REGRESI DENGAN DUMMY VARIABEL X ditambah KUADRATIK (Y dalam LOG)
regresi8 = lm(log(PTR) ~ log(PADPC) + log(DemandSD) + I(log(DemandSD)^2) + log(SupplySD) + Dkabkota, data=data1)
summary(regresi8)
anova(regresi8)

#assumption: Homoskedasticity
lmtest::bptest(regresi8)

#assumption: No autocorrelation of residuals
lmtest::dwtest(regresi8)

#assumption: No perfect multicollinearity
car::vif(regresi8)

#resolving H & A:  robust standard error
coeftest(regresi8, vcov = vcovHAC)



## REGRESI LOGISTIK (MODEL LOGIT) : Variabel Dependen Kualitatif

#import data
# IMPORT DATA, save sebagai "datalogit"

logit1 = glm(admit ~ test + ipk + rank, data = datalogit, family = binomial(link = "logit"))
summary(logit1)
round(exp(coef(logit1)),5)

datalogit$prob_lulus = predict(logit1, type = "response")
datalogit$pred_class = ifelse(datalogit$prob_lulus >= 0.5, 1, 0)

tab = table(Prediksi = datalogit$pred_class, Aktual = datalogit$admit)
accuracy = sum(diag(tab)) / sum(tab)
tab
accuracy

#prediksi peluang
skenario1 = data.frame(test = 75, ipk = 3.5, rank = 0)
pred_peluang = predict(logit1, newdata = skenario1, type = "response")
pred_peluang
