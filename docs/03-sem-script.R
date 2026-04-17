# ==============================================================
# Sesi 3: Structural Equation Modelling (SEM)
# ISEI Workshop: Analisis Regresi & SEM dengan RStudio
# ==============================================================

# ---- BAGIAN A: CB-SEM dengan lavaan ----

library(tidyverse)
library(readxl)
library(lavaan)
library(semPlot)
library(knitr)
set.seed(2026)

# --- 1. Import Data ---
dat <- read_excel("data/sem/data.xlsx")
dat <- dat |> select(-No)
glimpse(dat)

# --- 2. CFA (Confirmatory Factor Analysis) ---
cfa_model <- '
  PMB  =~ PMB1 + PMB2 + PMB3 + PMB4
  HV   =~ HV1 + HV2 + HV3 + HV4
  ELOY =~ ELOY1 + ELOY2 + ELOY3
'

cfa_fit <- cfa(cfa_model, data = dat)

# Fit indices
fitMeasures(cfa_fit, c("chisq", "df", "pvalue", "cfi", "tli", "rmsea", "srmr"))

# Summary
summary(cfa_fit)

# Standardized factor loadings
parameterEstimates(cfa_fit, standardized = TRUE) |>
  filter(op == "=~") |>
  select(Konstruk = lhs, Indikator = rhs,
         Loading = est, Std.Loading = std.all, p = pvalue) |>
  mutate(Memadai = ifelse(Std.Loading >= 0.50, "Ya", "Tidak")) |>
  kable(digits = 3)

# CR & AVE
std_loadings <- parameterEstimates(cfa_fit, standardized = TRUE) |>
  filter(op == "=~") |>
  select(lhs, std.all)

reliabilitas <- std_loadings |>
  group_by(Konstruk = lhs) |>
  summarize(
    n_items = n(),
    sum_lambda = sum(std.all),
    sum_lambda2 = sum(std.all^2),
    AVE = sum(std.all^2) / n(),
    CR = sum_lambda^2 / (sum_lambda^2 + (n() - sum(std.all^2))),
    .groups = "drop"
  )
reliabilitas |> select(Konstruk, n_items, AVE, CR) |> kable(digits = 3)

# Discriminant validity: Fornell-Larcker
cor_lv <- lavInspect(cfa_fit, "cor.lv")
round(cor_lv, 3)

ave_vals <- reliabilitas$AVE
names(ave_vals) <- reliabilitas$Konstruk
sqrt_ave <- sqrt(ave_vals)
round(sqrt_ave, 3)

# Modification indices
mi <- modindices(cfa_fit, sort = TRUE, minimum.value = 10)
mi |> head(20) |> kable(digits = 3)

# --- 3. Structural Model Tanpa Mediasi ---
sem_direct <- '
  # Measurement model
  PMB  =~ PMB1 + PMB2 + PMB3 + PMB4
  HV   =~ HV1 + HV2 + HV3 + HV4
  ELOY =~ ELOY1 + ELOY2 + ELOY3

  # Structural model (tanpa mediasi)
  ELOY ~ PMB + HV
'

sem_direct_fit <- sem(sem_direct, data = dat)

fitMeasures(sem_direct_fit, c("chisq", "df", "pvalue",
                              "cfi", "tli", "rmsea", "srmr"))

parameterEstimates(sem_direct_fit, standardized = TRUE) |>
  filter(op == "~") |>
  select(DV = lhs, IV = rhs, B = est, SE = se, Z = z,
         p = pvalue, Beta = std.all) |>
  mutate(Sig = ifelse(p < 0.05, "Ya", "Tidak")) |>
  kable(digits = 3)

lavInspect(sem_direct_fit, "r2")

# --- 4. Full SEM dengan Mediasi ---
sem_model <- '
  # Measurement model
  PMB  =~ PMB1 + PMB2 + PMB3 + PMB4
  HV   =~ HV1 + HV2 + HV3 + HV4
  ELOY =~ ELOY1 + ELOY2 + ELOY3

  # Structural model (dengan label untuk mediasi)
  HV   ~ a*PMB
  ELOY ~ c*PMB + b*HV

  # Defined parameters
  indirect := a*b
  total    := c + a*b
'

sem_fit <- sem(sem_model, data = dat, se = "bootstrap", bootstrap = 1000)

# Fit indices
fitMeasures(sem_fit, c("chisq", "df", "pvalue", "cfi", "tli", "rmsea", "srmr"))

# Path coefficients (uji hipotesis)
parameterEstimates(sem_fit, standardized = TRUE) |>
  filter(op == "~") |>
  select(DV = lhs, IV = rhs, B = est, SE = se, Z = z,
         p = pvalue, Beta = std.all) |>
  mutate(Sig = ifelse(p < 0.05, "Ya", "Tidak")) |>
  kable(digits = 3)

# R-squared
lavInspect(sem_fit, "r2")

# Analisis mediasi
parameterEstimates(sem_fit) |>
  filter(op == ":=") |>
  select(Label = label, Estimate = est, SE = se, Z = z,
         p = pvalue, CI.Lower = ci.lower, CI.Upper = ci.upper) |>
  kable(digits = 3)

# Path diagram
semPaths(sem_fit, whatLabels = "std", layout = "tree2",
  edge.label.cex = 0.8, sizeMan = 6, sizeLat = 9,
  style = "lisrel", residuals = FALSE, rotation = 2, nCharNodes = 4)


# ---- BAGIAN B: PLS-SEM dengan seminr ----

library(seminr)

# --- 5. Import Data ---
mobi <- read_excel("data/plssem/sem_mobi.xlsx")
glimpse(mobi)

# --- 6. Spesifikasi & Estimasi Model ---
# Measurement model (berbagai tipe konstruk)
mm <- constructs(
  composite("Image",        multi_items("IMAG", 1:3)),
  composite("Value",        multi_items("PERV", 1:2)),
  higher_composite("Satisfaction",
                   dimensions = c("Image", "Value"),
                   method = two_stage),
  composite("Quality",      multi_items("PERQ", 1:3), weights = mode_B),
  composite("Complaints",   single_item("CUSCO")),
  reflective("Loyalty",     multi_items("CUSL", 1:3))
)

# Structural model
sm <- relationships(
  paths(from = "Quality",      to = "Satisfaction"),
  paths(from = "Satisfaction", to = c("Complaints", "Loyalty"))
)

# Estimasi
pls_model <- estimate_pls(
  data = as.data.frame(mobi),
  measurement_model = mm,
  structural_model = sm
)

# Workaround bug seminr: HOC dimensions perlu ada di rawdata
hoc_dims <- c("Image", "Value")
stage1_scores <- pls_model$first_stage_model$construct_scores
pls_model$rawdata <- cbind(pls_model$rawdata,
                           stage1_scores[, hoc_dims, drop = FALSE])

pls_summary <- summary(pls_model)

# --- 7. Evaluasi Outer Model ---
pls_summary$reliability
pls_summary$loadings
pls_summary$validity$htmt
pls_summary$validity$fl_criteria
pls_summary$validity$cross_loadings

# --- 8. Bootstrap ---
set.seed(2026)
boot <- bootstrap_model(pls_model, nboot = 100, cores = 1)
boot_sum <- summary(boot)
boot_sum$bootstrapped_paths

# --- 9. Inner Model ---
pls_summary$paths
pls_summary$fSquare

# --- 10. Analisis Mediasi ---
# Quality -> Satisfaction -> Loyalty
med1 <- specific_effect_significance(boot,
  from = "Quality", through = "Satisfaction", to = "Loyalty")
med1

# Quality -> Satisfaction -> Complaints
med2 <- specific_effect_significance(boot,
  from = "Quality", through = "Satisfaction", to = "Complaints")
med2

# --- 11. PLSpredict (model sederhana tanpa HOC) ---
mm_simple <- constructs(
  composite("Quality",      multi_items("PERQ", 1:3), weights = mode_B),
  composite("Satisfaction", multi_items("IMAG", 1:3)),
  composite("Complaints",   single_item("CUSCO")),
  reflective("Loyalty",     multi_items("CUSL", 1:3))
)
sm_simple <- relationships(
  paths(from = "Quality",      to = "Satisfaction"),
  paths(from = "Satisfaction", to = c("Complaints", "Loyalty"))
)
pls_simple <- estimate_pls(data = as.data.frame(mobi),
                           measurement_model = mm_simple,
                           structural_model = sm_simple)
set.seed(2026)
pred <- predict_pls(pls_simple, technique = predict_DA, noFolds = 10)
pred_sum <- summary(pred)
pred_sum

# --- 12. Path Diagram ---
plot(boot)
save_plot("plsem.png")
