# ==============================================================
# Sesi 3: Structural Equation Modelling (SEM)
# ISEI Workshop: Analisis Regresi & SEM dengan RStudio
# ==============================================================

# ---- BAGIAN A: CB-SEM dengan lavaan ----

library(lavaan)
library(semPlot)
library(dplyr)

# --- 1. Import Data ---
dat <- read.csv("data/sem_ecommerce.csv")
glimpse(dat)

# --- 2. CFA (Confirmatory Factor Analysis) ---
model_cfa <- '
  SQ =~ SQ1 + SQ2 + SQ3 + SQ4
  PV =~ PV1 + PV2 + PV3
  TR =~ TR1 + TR2 + TR3 + TR4
  CS =~ CS1 + CS2 + CS3 + CS4
  CL =~ CL1 + CL2 + CL3
  RI =~ RI1 + RI2 + RI3
'

fit_cfa <- cfa(model_cfa, data = dat)
fitMeasures(fit_cfa, c("chisq", "df", "pvalue", "cfi", "tli", "rmsea", "srmr"))

# Standardized loadings
standardizedSolution(fit_cfa) |>
  filter(op == "=~") |>
  select(konstruk = lhs, indikator = rhs, loading = est.std, p = pvalue)

# CR & AVE
std_load <- standardizedSolution(fit_cfa) |>
  filter(op == "=~") |>
  select(konstruk = lhs, loading = est.std)

std_load |>
  summarize(
    CR  = sum(loading)^2 / (sum(loading)^2 + sum(1 - loading^2)),
    AVE = mean(loading^2),
    .by = konstruk
  )

# --- 3. Full SEM ---
model_sem <- '
  SQ =~ SQ1 + SQ2 + SQ3 + SQ4
  PV =~ PV1 + PV2 + PV3
  TR =~ TR1 + TR2 + TR3 + TR4
  CS =~ CS1 + CS2 + CS3 + CS4
  CL =~ CL1 + CL2 + CL3
  RI =~ RI1 + RI2 + RI3
  CS ~ SQ + PV + TR
  CL ~ CS + TR
  RI ~ CS + CL
'

fit_sem <- sem(model_sem, data = dat)

# Path coefficients
parameterEstimates(fit_sem, standardized = TRUE) |>
  filter(op == "~") |>
  select(DV = lhs, IV = rhs, B = est, SE = se, Z = z, p = pvalue, Beta = std.all)

# R-squared
lavInspect(fit_sem, "r2")[c("CS", "CL", "RI")]

# Path diagram
semPaths(fit_sem, what = "std", layout = "tree2",
  edge.label.cex = 0.9, sizeMan = 7, sizeLat = 9,
  style = "lisrel", residuals = FALSE, edge.color = "darkblue")


# ---- BAGIAN B: PLS-SEM dengan seminr ----

library(seminr)

# --- 4. Import Data ---
dat_pls <- read.csv("data/sem_innovation.csv")
glimpse(dat_pls)

# --- 5. Spesifikasi & Estimasi Model ---
mm <- constructs(
  composite("IC", multi_items("IC", 1:4), weights = mode_B),
  composite("MO", multi_items("MO", 1:3), weights = mode_B),
  composite("EO", multi_items("EO", 1:3), weights = mode_B),
  composite("CA", multi_items("CA", 1:4), weights = mode_A),
  composite("FP", multi_items("FP", 1:4), weights = mode_A)
)

sm <- relationships(
  paths(from = c("IC", "MO", "EO"), to = "CA"),
  paths(from = c("CA", "IC"), to = "FP")
)

pls_model <- estimate_pls(data = dat_pls,
  measurement_model = mm, structural_model = sm)
model_sum <- summary(pls_model)

# --- 6. Evaluasi Model Pengukuran ---
model_sum$loadings
model_sum$reliability
model_sum$weights
model_sum$validity$vif_items

# --- 7. Bootstrap ---
set.seed(2026)
boot_model <- bootstrap_model(pls_model, nboot = 1000)
boot_sum <- summary(boot_model)
boot_sum$bootstrapped_paths

# --- 8. R² dan f² ---
model_sum$paths
model_sum$fSquare

# --- 9. Path Diagram ---
plot(pls_model)
