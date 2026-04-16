# ==============================================================
# Sesi 1: Pengantar R, Pengolahan Data, dan Visualisasi
# ISEI Workshop: Analisis Regresi & SEM dengan RStudio
# ==============================================================

# --- 1. Pengantar R ---

# Tipe data dasar
x <- 42            # numeric
nama <- "ISEI"     # character
aktif <- TRUE       # logical

# Vektor
angka <- c(1, 2, 3, 4, 5)
mean(angka)
sd(angka)

# --- 2. Muat Paket ---

library(tidyverse)

# --- 3. Import Data ---

wvs1 <- read.csv("data/wvs1.csv")
wvs2 <- read.csv("data/wvs2.csv")

# Gabungkan kedua dataset
wvs <- bind_rows(wvs1, wvs2)

# Lihat struktur data
glimpse(wvs)
head(wvs)
nrow(wvs)

# --- 4. Pengolahan Data dengan Tidyverse ---

# Filter: hanya responden usia 18-65
wvs_dewasa <- wvs |>
  filter(usia >= 18, usia <= 65)

# Select: pilih kolom tertentu
wvs_subset <- wvs |>
  select(negara, jenis_kelamin, usia, kepuasan_hidup, kebebasan_memilih)

# Mutate: buat variabel baru
wvs <- wvs |>
  mutate(kelompok_usia = case_when(
    usia < 30  ~ "Muda",
    usia < 50  ~ "Dewasa",
    TRUE       ~ "Senior"
  ))

# Group by + Summarize
wvs |>
  summarize(
    rata_rata = mean(kepuasan_hidup, na.rm = TRUE),
    sd = sd(kepuasan_hidup, na.rm = TRUE),
    n = n(),
    .by = negara
  )

# Arrange: urutkan
wvs |>
  summarize(rata_rata = mean(kepuasan_hidup, na.rm = TRUE), .by = negara) |>
  arrange(desc(rata_rata))

# --- 5. Pembersihan Data ---

wvs_clean <- wvs |>
  filter(
    kepuasan_hidup > 0,
    kebebasan_memilih > 0,
    kepuasan_finansial > 0,
    usia > 0
  ) |>
  filter(jenis_kelamin %in% c("Laki-laki", "Perempuan"))

nrow(wvs_clean)

# --- 6. Statistik Deskriptif ---

wvs_clean |>
  select(kepuasan_hidup, kebebasan_memilih, kepuasan_finansial, usia) |>
  pivot_longer(everything(), names_to = "variabel", values_to = "nilai") |>
  summarize(
    M = mean(nilai),
    SD = sd(nilai),
    Min = min(nilai),
    Max = max(nilai),
    .by = variabel
  )

# Tabel frekuensi
table(wvs_clean$negara)
table(wvs_clean$jenis_kelamin)

# --- 7. Visualisasi dengan ggplot2 ---

# Histogram
ggplot(wvs_clean, aes(x = kepuasan_hidup)) +
  geom_histogram(binwidth = 1, fill = "steelblue", color = "white") +
  labs(title = "Distribusi Kepuasan Hidup", x = "Kepuasan Hidup", y = "Frekuensi")

# Boxplot per negara
ggplot(wvs_clean, aes(x = negara, y = kepuasan_hidup, fill = negara)) +
  geom_boxplot() +
  labs(title = "Kepuasan Hidup per Negara", x = "Negara", y = "Kepuasan Hidup") +
  theme(legend.position = "none")

# Scatter plot
ggplot(wvs_clean, aes(x = kebebasan_memilih, y = kepuasan_hidup)) +
  geom_jitter(alpha = 0.1, width = 0.3, height = 0.3) +
  geom_smooth(method = "lm", color = "red") +
  labs(title = "Kebebasan Memilih vs Kepuasan Hidup",
       x = "Kebebasan Memilih", y = "Kepuasan Hidup")

# Bar plot: rata-rata per negara
wvs_clean |>
  summarize(M = mean(kepuasan_hidup), .by = negara) |>
  ggplot(aes(x = reorder(negara, M), y = M, fill = negara)) +
  geom_col() +
  coord_flip() +
  labs(title = "Rata-rata Kepuasan Hidup per Negara", x = "", y = "Rata-rata") +
  theme(legend.position = "none")
