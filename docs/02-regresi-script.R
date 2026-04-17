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
  select(kepuasan_hidup, kebebasan_memilih, kepuasan_finansial, usia,
         religiusitas, jenis_kelamin, negara) |>
  drop_na()

nrow(dat)

# --- 2. Korelasi ---

cor(dat$kepuasan_finansial, dat$kepuasan_hidup)
cor.test(dat$kepuasan_finansial, dat$kepuasan_hidup)

# --- 3. Regresi Sederhana (m1) ---

m1 <- lm(kepuasan_hidup ~ kepuasan_finansial, data = dat)
tidy(m1, conf.int = TRUE)
summary(m1)
glance(m1) |> select(r.squared, adj.r.squared, AIC)

# Visualisasi M1
ggplot(dat, aes(x = kepuasan_finansial, y = kepuasan_hidup)) +
  geom_jitter(alpha = 0.1, width = 0.3, height = 0.3) +
  geom_smooth(method = "lm", color = "steelblue") +
  labs(title = "M1: Regresi Sederhana",
       x = "Kepuasan Finansial", y = "Kepuasan Hidup")

# --- 4. Regresi Berganda 2 Prediktor (m2) ---

m2 <- lm(kepuasan_hidup ~ kepuasan_finansial + kebebasan_memilih,
         data = dat)
tidy(m2, conf.int = TRUE)
summary(m2)

# --- 5. Regresi Berganda Penuh Numerik (m3) ---

m3 <- lm(kepuasan_hidup ~ kepuasan_finansial + kebebasan_memilih +
           religiusitas + usia, data = dat)
tidy(m3, conf.int = TRUE)
summary(m3)

# --- 6. Model dengan Variabel Kategorikal (m4) ---

dat <- dat |>
  mutate(
    jenis_kelamin = factor(jenis_kelamin),
    negara = factor(negara)
  )

levels(dat$jenis_kelamin)
levels(dat$negara)

m4 <- lm(kepuasan_hidup ~ kepuasan_finansial + kebebasan_memilih +
           religiusitas + usia + jenis_kelamin, data = dat)
tidy(m4, conf.int = TRUE)
summary(m4)

# --- 7. Model dengan Negara (m5) ---

m5 <- lm(kepuasan_hidup ~ kepuasan_finansial + kebebasan_memilih +
           religiusitas + usia + jenis_kelamin + negara, data = dat)
tidy(m5, conf.int = TRUE) |> kable(digits = 3)

# Mengubah kategori referensi
dat <- dat |>
  mutate(negara = relevel(negara, ref = "Singapura"))

m5b <- lm(kepuasan_hidup ~ kepuasan_finansial + kebebasan_memilih +
            religiusitas + usia + jenis_kelamin + negara, data = dat)
tidy(m5b, conf.int = TRUE) |> kable(digits = 3)

# --- 8. Model dengan Interaksi (m6) ---

m6 <- lm(kepuasan_hidup ~ kepuasan_finansial * jenis_kelamin +
           kebebasan_memilih + religiusitas + usia, data = dat)
tidy(m6, conf.int = TRUE) |> kable(digits = 3)

# Visualisasi interaksi
ggplot(dat, aes(x = kepuasan_finansial, y = kepuasan_hidup,
                color = jenis_kelamin)) +
  geom_point(alpha = 0.2) +
  geom_smooth(method = "lm") +
  labs(title = "Interaksi: Kepuasan Finansial x Jenis Kelamin",
       x = "Kepuasan Finansial", y = "Kepuasan Hidup",
       color = "Jenis Kelamin") +
  theme_minimal()

# --- 9. Perbandingan Model ---

anova(m1, m2, m3)

# Tabel perbandingan dengan Cohen's f2 inkremental
r2_adj <- c(glance(m1)$adj.r.squared, glance(m2)$adj.r.squared,
            glance(m3)$adj.r.squared, glance(m4)$adj.r.squared,
            glance(m5)$adj.r.squared, glance(m6)$adj.r.squared)

cohens_f2 <- c(NA, diff(r2_adj) / (1 - r2_adj[-1]))

tibble(
  Model = paste0("m", 1:6),
  Formula = c("finansial", "+ kebebasan", "+ religiusitas + usia",
              "+ jenis_kelamin", "+ negara", "finansial * jk + lainnya"),
  R2_adj = r2_adj,
  AIC = c(AIC(m1), AIC(m2), AIC(m3), AIC(m4), AIC(m5), AIC(m6)),
  Cohens_f2 = cohens_f2
) |> kable(digits = 3)

# --- 10. Diagnostik ---

# Diagnostic plots
par(mfrow = c(2, 2))
plot(m3)

# VIF
vif(m3)

# Breusch-Pagan test
bptest(m3)

# Uji Normalitas Residual (Kolmogorov-Smirnov)
ks.test(m3$residuals, "pnorm", mean = 0, sd = sd(m3$residuals))

# Uji Autokorelasi (Durbin-Watson)
dwtest(m3)

# Robust standard errors (HC3)
coeftest(m3, vcov = vcovHC(m3, type = "HC3"))

# --- 11. Standardized Coefficients ---

dat_scaled <- dat |>
  mutate(across(where(is.numeric), scale))

m3_std <- lm(kepuasan_hidup ~ kepuasan_finansial + kebebasan_memilih +
               religiusitas + usia, data = dat_scaled)
tidy(m3_std, conf.int = TRUE) |> kable(digits = 3)
