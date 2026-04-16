# ==============================================================
# Sesi 2: Analisis Regresi
# ISEI Workshop: Analisis Regresi & SEM dengan RStudio
# ==============================================================

library(tidyverse)
library(broom)
library(car)

# --- 1. Import & Pembersihan Data ---

wvs1 <- read.csv("data/wvs1.csv")
wvs2 <- read.csv("data/wvs2.csv")
wvs <- bind_rows(wvs1, wvs2)

wvs_clean <- wvs |>
  filter(
    kepuasan_hidup > 0,
    kebebasan_memilih > 0,
    kepuasan_finansial > 0,
    usia > 0
  ) |>
  filter(jenis_kelamin %in% c("Laki-laki", "Perempuan"))

# Subset lengkap untuk semua model
dat <- wvs_clean |>
  select(kepuasan_hidup, kebebasan_memilih, kepuasan_finansial, usia,
         religiusitas, jenis_kelamin, negara) |>
  tidyr::drop_na()

nrow(dat)

# --- 2. Statistik Deskriptif ---

dat |>
  select(where(is.numeric)) |>
  pivot_longer(everything(), names_to = "variabel", values_to = "nilai") |>
  summarize(M = mean(nilai), SD = sd(nilai), .by = variabel)

# --- 3. Regresi Sederhana (M1) ---

m1 <- lm(kepuasan_hidup ~ kebebasan_memilih, data = dat)
tidy(m1)
glance(m1)

# --- 4. Regresi Berganda (M2) ---

m2 <- lm(kepuasan_hidup ~ kebebasan_memilih + kepuasan_finansial + usia,
         data = dat)
tidy(m2)
glance(m2)

# --- 5. Regresi dengan Variabel Kategorikal (M3) ---

m3 <- lm(kepuasan_hidup ~ kebebasan_memilih + kepuasan_finansial + usia +
           religiusitas + jenis_kelamin + negara, data = dat)
tidy(m3)
glance(m3)

# --- 6. Perbandingan Model ---

# ANOVA bertingkat
anova(m1, m2, m3)

# Tabel R²
bind_rows(
  glance(m1) |> mutate(model = "M1: Sederhana"),
  glance(m2) |> mutate(model = "M2: Berganda"),
  glance(m3) |> mutate(model = "M3: + Kategorikal")
) |>
  select(model, r.squared, adj.r.squared, AIC, BIC)

# --- 7. Diagnostik ---

# Diagnostic plots
par(mfrow = c(2, 2))
plot(m3)

# VIF
car::vif(m3)

# --- 8. Visualisasi ---

# Scatter + regression line
ggplot(dat, aes(x = kebebasan_memilih, y = kepuasan_hidup)) +
  geom_jitter(alpha = 0.1, width = 0.3, height = 0.3) +
  geom_smooth(method = "lm", color = "steelblue") +
  labs(title = "Regresi: Kebebasan Memilih → Kepuasan Hidup",
       x = "Kebebasan Memilih", y = "Kepuasan Hidup")
