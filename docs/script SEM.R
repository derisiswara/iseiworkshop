#install.packages("lavaan")
#install.packages("semPlot")
library(lavaan)  
library(semPlot)

#import data, name: datasem
datasem = read_excel("data/datasem.xlsx")

model = "
  SQ  =~ SQ1 + SQ2 + SQ3 + SQ4
  PV  =~ PV1 + PV2 + PV3 + PV4
  TR  =~ TR1 + TR2 + TR3 + TR4
  SAT =~ SAT1 + SAT2 + SAT3 + SAT4
  LOY =~ LOY1 + LOY2 + LOY3 + LOY4

  TR  ~ SQ + PV
  SAT ~ SQ + PV
  LOY ~ TR + SAT + PV
"
fit = sem(model, data = datasem, estimator="MLR")
summary(fit, fit.measures = TRUE, standardized=TRUE)

semPaths(fit)
semPaths(fit, "std", layout="spring", color = list(lat = "green", man = "yellow"), edge.color="black")


## ESTIMASI EFEK MODERASI (DIRECT-INDIRECT EFFECT)
model_med = '
  # Measurement model
  SQ  =~ SQ1 + SQ2 + SQ3 + SQ4
  PV  =~ PV1 + PV2 + PV3 + PV4
  TR  =~ TR1 + TR2 + TR3 + TR4
  SAT =~ SAT1 + SAT2 + SAT3 + SAT4
  LOY =~ LOY1 + LOY2 + LOY3 + LOY4

  # Structural model
  TR  ~ a1*SQ + a2*PV
  SAT ~ b1*SQ + b2*PV
  LOY ~ c1*TR + c2*SAT + c3*PV

  # Indirect effects
  ind_SQ_TR_LOY  := a1*c1
  ind_SQ_SAT_LOY := b1*c2

  ind_PV_TR_LOY  := a2*c1
  ind_PV_SAT_LOY := b2*c2

  # Total indirect effects
  ind_SQ_total := (a1*c1) + (b1*c2)
  ind_PV_total := (a2*c1) + (b2*c2)

  # Direct effects
  dir_PV_LOY := c3

  # Total effects
  tot_PV_LOY := c3 + (a2*c1) + (b2*c2)
  tot_SQ_LOY := (a1*c1) + (b1*c2)
'
fit_med = sem(model_med, data = datasem, estimator = "MLR")
summary(fit_med, fit.measures = TRUE, standardized = TRUE, rsquare = TRUE)


## SEM DENGAN TAMBAHAN VARIABEL KONTROL
model_control = '
  SQ  =~ SQ1 + SQ2 + SQ3 + SQ4
  PV  =~ PV1 + PV2 + PV3 + PV4
  TR  =~ TR1 + TR2 + TR3 + TR4
  SAT =~ SAT1 + SAT2 + SAT3 + SAT4
  LOY =~ LOY1 + LOY2 + LOY3 + LOY4

  TR  ~ SQ + PV + age + usage_months
  SAT ~ SQ + PV + age + usage_months
  LOY ~ TR + SAT + PV
'
fit_control = sem(model_control, data = datasem, estimator = "MLR")
summary(fit_control, fit.measures = TRUE, standardized = TRUE, rsquare = TRUE)


## MODELLING BERDASARKAN GENDER
datasem$gender = factor(datasem$gender,levels = c(1, 2), labels = c("Laki-laki", "Perempuan"))
table(datasem$gender)

fit = sem(model, data = datasem, estimator="MLR")
summary(fit, fit.measures = TRUE, standardized=TRUE)
fit_gender = sem(model, data = datasem, estimator="MLR", group="gender")
summary(fit_gender, fit.measures = TRUE, standardized=TRUE)


## SEM BERDASARKAN PENDIDIKAN
table(datasem$education)
datasem$edu_group = ifelse(datasem$education %in% c(1,2), "Non-sarjana", "Sarjana_ke_atas")
datasem$edu_group = factor(datasem$edu_group, levels = c("Non-sarjana", "Sarjana_ke_atas"))
table(datasem$edu_group)

fit_edu = sem(model, data = datasem, estimator = "MLR", group = "edu_group")
summary(fit_edu, fit.measures = TRUE, standardized = TRUE)
