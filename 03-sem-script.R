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
fitMeasures(cfa_fit, c("chisq", "df", "pvalue", "cfi", "tli", "rmsea", "srmr"))

# Standardized loadings
standardizedSolution(cfa_fit) |>
  filter(op == "=~") |>
  select(konstruk = lhs, indikator = rhs, loading = est.std, p = pvalue)

# CR & AVE
std_load <- standardizedSolution(cfa_fit) |>
  filter(op == "=~") |>
  select(konstruk = lhs, loading = est.std)

std_load |>
  summarize(
    CR  = sum(loading)^2 / (sum(loading)^2 + sum(1 - loading^2)),
    AVE = mean(loading^2),
    .by = konstruk
  )

# Fornell-Larcker: korelasi antar konstruk
cor_matrix <- lavInspect(cfa_fit, "cor.lv")
cor_matrix

# --- 3. Full SEM dengan Mediasi ---
sem_model <- '
  PMB  =~ PMB1 + PMB2 + PMB3 + PMB4
  HV   =~ HV1 + HV2 + HV3 + HV4
  ELOY =~ ELOY1 + ELOY2 + ELOY3

  HV   ~ a*PMB
  ELOY ~ c*PMB + b*HV

  # Indirect & total effects
  indirect := a*b
  total := c + a*b
'

sem_fit <- sem(sem_model, data = dat, se = "bootstrap", bootstrap = 1000)

# Fit indices
fitMeasures(sem_fit, c("chisq", "df", "pvalue", "cfi", "tli", "rmsea", "srmr"))

# Path coefficients
parameterEstimates(sem_fit, standardized = TRUE) |>
  filter(op == "~") |>
  select(DV = lhs, IV = rhs, B = est, SE = se, Z = z, p = pvalue, Beta = std.all)

# R-squared
lavInspect(sem_fit, "r2")

# Mediation
parameterEstimates(sem_fit) |>
  filter(op == ":=")

# Path diagram
semPaths(sem_fit, whatLabels = "std", layout = "tree2",
  edge.label.cex = 0.8, sizeMan = 6, sizeLat = 8,
  style = "lisrel", residuals = FALSE, rotation = 2, nCharNodes = 4)


# ---- BAGIAN B: PLS-SEM dengan seminr ----

library(seminr)

# --- 4. Import Data ---
mobi <- read_excel("data/plssem/sem_mobi.xlsx")
glimpse(mobi)

# --- 5. Spesifikasi & Estimasi Model ---
mm <- constructs(
  composite("IMAG", multi_items("IMAG", 1:5)),
  composite("CUEX", multi_items("CUEX", 1:3)),
  composite("PERQ", multi_items("PERQ", 1:7)),
  composite("PERV", multi_items("PERV", 1:2)),
  composite("CUSA", multi_items("CUSA", 1:3)),
  composite("CUSCO", single_item("CUSCO")),
  composite("CUSL", multi_items("CUSL", 1:3))
)

sm <- relationships(
  paths(from = "IMAG",  to = c("CUEX", "CUSA", "CUSL")),
  paths(from = "CUEX",  to = c("PERQ", "PERV", "CUSA")),
  paths(from = "PERQ",  to = c("PERV", "CUSA")),
  paths(from = "PERV",  to = "CUSA"),
  paths(from = "CUSA",  to = c("CUSCO", "CUSL")),
  paths(from = "CUSCO", to = "CUSL")
)

pls_model <- estimate_pls(data = mobi,
  measurement_model = mm, structural_model = sm)
pls_summary <- summary(pls_model)

# --- 6. Evaluasi Outer Model ---
pls_summary$reliability
pls_summary$loadings
pls_summary$validity$htmt
pls_summary$validity$fl_criteria
pls_summary$validity$cross_loadings

# --- 7. Bootstrap ---
set.seed(2026)
boot <- bootstrap_model(pls_model, nboot = 5000)
boot_sum <- summary(boot)
boot_sum$bootstrapped_paths

# --- 8. Inner Model ---
pls_summary$paths
pls_summary$fSquare

# --- 9. Mediasi ---
med <- specific_effect_significance(boot,
  from = "IMAG", through = "CUSA", to = "CUSL")
med

# --- 10. PLS-Predict ---
pred <- tryCatch(
  predict_pls(
    model = pls_model,
    technique = predict_DA,
    noFolds = 10,
    reps = 10
  ),
  error = function(e) {
    message("PLS-Predict error (sering terjadi pada model dengan single-item construct): ", e$message)
    NULL
  }
)
if (!is.null(pred)) summary(pred)

# --- 11. Path Diagram ---
plot(pls_model)
