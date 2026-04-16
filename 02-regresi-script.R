# ==============================================================
# Sesi 2: Analisis Regresi
# ISEI Workshop: Analisis Regresi & SEM dengan RStudio
# ==============================================================

set.seed(2026)

library(tidyverse)
library(readxl)
library(broom)
library(car)
library(lmtest)
library(sandwich)
library(knitr)

# --- 1. Import & Pembersihan Data ---

wvs <- read_excel("data/regresi/wvs1.xlsx")

dat <- wvs |>
  select(kepuasan_hidup, kepuasan_finansial, religiusitas,
         kebebasan_memilih, usia, jenis_kelamin, negara) |>
  drop_na()

nrow(dat)

# --- 2. Regresi Sederhana (m1) ---

m1 <- lm(kepuasan_hidup ~ kepuasan_finansial, data = dat)
tidy(m1, conf.int = TRUE)
glance(m1) |> select(r.squared, adj.r.squared, AIC)

# --- 3. Regresi Berganda 2 Prediktor (m2) ---

m2 <- lm(kepuasan_hidup ~ kepuasan_finansial + kebebasan_memilih,
         data = dat)
tidy(m2, conf.int = TRUE)

# --- 4. Regresi Berganda Penuh Numerik (m3) ---

m3 <- lm(kepuasan_hidup ~ kepuasan_finansial + kebebasan_memilih +
           religiusitas + usia, data = dat)
tidy(m3, conf.int = TRUE)

# --- 5. Model dengan Variabel Kategorikal (m4) ---

dat <- dat |>
  mutate(
    jenis_kelamin = factor(jenis_kelamin),
    negara = factor(negara)
  )

m4 <- lm(kepuasan_hidup ~ kepuasan_finansial + kebebasan_memilih +
           religiusitas + usia + jenis_kelamin, data = dat)
tidy(m4, conf.int = TRUE)

# --- 6. Model dengan Negara (m5) ---

m5 <- lm(kepuasan_hidup ~ kepuasan_finansial + kebebasan_memilih +
           religiusitas + usia + jenis_kelamin + negara, data = dat)
tidy(m5, conf.int = TRUE) |> kable(digits = 3)

# --- 7. Model dengan Interaksi (m6) ---

m6 <- lm(kepuasan_hidup ~ kepuasan_finansial * jenis_kelamin +
           kebebasan_memilih + religiusitas + usia, data = dat)
tidy(m6, conf.int = TRUE) |> kable(digits = 3)

# --- 8. Perbandingan Model ---

anova(m1, m2, m3)

tibble(
  Model = paste0("m", 1:6),
  R2_adj = c(glance(m1)$adj.r.squared, glance(m2)$adj.r.squared,
             glance(m3)$adj.r.squared, glance(m4)$adj.r.squared,
             glance(m5)$adj.r.squared, glance(m6)$adj.r.squared),
  AIC = c(AIC(m1), AIC(m2), AIC(m3), AIC(m4), AIC(m5), AIC(m6)),
  f2 = R2_adj / (1 - R2_adj)
) |> kable(digits = 3)
# Cohen's f²: 0.02 = kecil, 0.15 = sedang, 0.35 = besar

# --- 9. Diagnostik ---

# Diagnostic plots
par(mfrow = c(2, 2))
plot(m3)

# VIF
vif(m3)

# Breusch-Pagan test
bptest(m3)

# Robust standard errors (HC3)
coeftest(m3, vcov = vcovHC(m3, type = "HC3"))

# --- 10. Standardized Coefficients ---

dat_scaled <- dat |>
  mutate(across(where(is.numeric), scale))

m3_std <- lm(kepuasan_hidup ~ kepuasan_finansial + kebebasan_memilih +
               religiusitas + usia, data = dat_scaled)
tidy(m3_std, conf.int = TRUE) |> kable(digits = 3)

# --- 11. Visualisasi ---

ggplot(dat, aes(x = kepuasan_finansial, y = kepuasan_hidup)) +
  geom_jitter(alpha = 0.1, width = 0.3, height = 0.3) +
  geom_smooth(method = "lm", color = "steelblue") +
  labs(title = "Regresi: Kepuasan Finansial → Kepuasan Hidup",
       x = "Kepuasan Finansial", y = "Kepuasan Hidup")
