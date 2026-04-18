install.packages("lavaan")
install.packages("semPlot")
library(lavaan)  
library(semPlot)  

# import data, name: datasem0

attach(datasem0)
table(A1)
barplot(table(A1)) 

sem.model = "
faktor =~ A1 + A2 + A3 + A4
permintaan =~ B1 + B2  
industri =~ C1 + C2  
strategi =~ D1 + D2 + D3 + D4
regulasi =~ E1 + E2 + E3 + E4 + E5 + E6
kesempatan =~ F1 + F2 + F3 + F4
kesempatan ~ faktor + permintaan + industri + strategi + regulasi"

sem.fit = sem(sem.model, data = datasem0)
summary(sem.fit, fit.measures=TRUE, standardized=TRUE)

semPaths(sem.fit)
semPaths(sem.fit, "std", layout="tree", color = list(lat = "green", man = "yellow"), edge.color="black")


## LATIHAN MANDIRI
## dengan menggunakan data yang sama
## buat model SEM dari variabel laten dan manifes sbg berikut:
## laten exogenous  : faktor (A5,A6,A7,A8), permintaan (B1,B2), industri (C1,C2)
## laten exogenous  : strategi (D1,D2,D3,D4), regulasi (E7,E8,E9,E10,E11,E12)
## laten endogenous : kesempatan (F5,F6,F7,F8)
