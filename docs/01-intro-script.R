# ==============================================================
# Sesi 1: Pengantar R, Pengolahan Data, dan Visualisasi
# ISEI Workshop: Analisis Regresi & SEM dengan RStudio
# ==============================================================

# ---- BAGIAN 1: DASAR-DASAR R ----

# --- 1. Objek dan Nilai ---
country_name <- "Singapore"

# --- 2. Tipe Data Dasar ---
country_code <- "SGP"          # character
life_satisfaction <- 8.5        # numeric (double)
is_religious <- TRUE            # logical (boolean)
birth_year <- 1990L             # integer

typeof(country_code)
typeof(life_satisfaction)
typeof(is_religious)

# Operasi aritmatika
(8 + 7 + 9) / 3
2025 - 1990

# Operasi boolean
life_satisfaction > 8
country_code == "SGP"
(country_code == "NZL") & (life_satisfaction > 8)  # AND
(country_code == "NZL") | (life_satisfaction > 8)  # OR

# --- 3. Fungsi ---
round(3.1415926)
round(3.1415926, digits = 2)

# --- 4. Vektor ---
countries <- c("CAN", "NZL", "SGP", "CAN", "SGP")
satisfaction_scores <- c(8, 7, 9, 6, 8)

length(countries)
mean(satisfaction_scores)
sd(satisfaction_scores)

# Mengakses elemen
countries[1]
satisfaction_scores[1:3]
satisfaction_scores[c(1, 3)]

# Filtering dengan kondisi
criteria <- satisfaction_scores > 7
satisfaction_scores[criteria]

# Menangani NA
financial_satisfaction <- c(8, 7, NA, 6, 9, NA, 7)
mean(financial_satisfaction)                  # NA!
mean(financial_satisfaction, na.rm = TRUE)    # OK

# --- 5. Dataframe ---
survey_data <- data.frame(
  country = c("SGP", "CAN", "NZL", "SGP", "CAN"),
  life_satisfaction = c(8, 7, 9, 6, 8),
  employment = c("Full time", "Student", "Part time", "Retired", "Full time")
)
survey_data

# Mengakses kolom
survey_data$country
survey_data["country"]
survey_data[1, 2]

# --- 6. Faktor ---
negara_factor <- factor(c("SGP", "CAN", "NZL", "SGP"))
levels(negara_factor)

pendidikan <- factor(c("SD", "SMA", "S1", "S2"),
                     levels = c("SD", "SMA", "S1", "S2"),
                     ordered = TRUE)
pendidikan

# Faktor tidak berurutan (nominal)
negara_contoh <- c("Singapura", "Kanada", "Selandia Baru", "Singapura")
negara_contoh <- factor(negara_contoh)
levels(negara_contoh)
str(negara_contoh)

# Faktor berurutan (ordinal)
status_contoh <- c("Penuh waktu", "Pelajar/Mahasiswa", "Paruh waktu", "Pensiunan", "Penuh waktu")
status_contoh <- factor(status_contoh,
                        levels = c("Tidak bekerja", "Pelajar/Mahasiswa",
                                   "Ibu rumah tangga", "Pensiunan",
                                   "Paruh waktu", "Penuh waktu",
                                   "Wiraswasta", "Lainnya"),
                        ordered = TRUE)
levels(status_contoh)
str(status_contoh)


# ---- BAGIAN 2: PENGOLAHAN DATA DENGAN TIDYVERSE ----

# --- 7. Muat Paket ---
library(tidyverse)
library(readxl)

# --- 8. Import Data ---
wvs1 <- read_excel("data/regresi/wvs1.xlsx")
wvs2 <- read_excel("data/regresi/wvs2.xlsx")

wvs <- bind_rows(wvs1, wvs2)
glimpse(wvs)
dim(wvs)
names(wvs)

# --- 9. Operator Pipe ---
wvs_data <- wvs

# Tanpa pipe
wvs_data <- drop_na(wvs_data)
wvs_sorted <- arrange(wvs_data, desc(usia))

# Dengan pipe
wvs_data |>
  drop_na() |>
  arrange(desc(usia))

# --- 10. Data Wrangling ---

# Hapus NA
wvs <- wvs |> drop_na()
dim(wvs)

# Hapus duplikasi
wvs <- wvs |> distinct(id_responden, .keep_all = TRUE)

# Pilih kolom
wvs <- wvs |>
  select(id_responden, negara, jenis_kelamin, tahun_lahir, usia,
         kepuasan_hidup, pentingnya_pekerjaan, kepuasan_finansial,
         kebebasan_memilih, religiusitas, skala_politik,
         status_pernikahan, status_pekerjaan)
glimpse(wvs)

# Filter dan urutkan
wvs <- wvs |>
  filter(usia >= 18) |>
  arrange(desc(usia))
head(wvs)

# Buat variabel baru
wvs <- wvs |>
  mutate(kelompok_usia = case_when(
    usia <= 28 ~ "18-28",
    usia <= 44 ~ "29-44",
    usia <= 60 ~ "45-60",
    TRUE       ~ "61+"
  ))

wvs |>
  select(usia, kelompok_usia) |>
  head(4)

# Simpan hasil
wvs |> write_csv("data-output/wvs_cleaned_v1.csv")

# Simpan ke excel
library(writexl)
wvs |> write_xlsx("data-output/wvs_cleaned_v1.xlsx")

# Konversi ke factor
kolom_faktor <- c("negara", "jenis_kelamin", "status_pernikahan", "status_pekerjaan")

wvs_cleaned <- wvs |>
  mutate(across(all_of(kolom_faktor), as_factor))

str(wvs_cleaned[kolom_faktor])

# --- 11. Group By + Summarize ---
wvs_cleaned |>
  summarize(
    rata_rata = mean(kepuasan_hidup),
    sd = sd(kepuasan_hidup),
    n = n(),
    .by = negara
  )

# Grup kepuasan: if_else
wvs_cleaned <- wvs_cleaned |>
  mutate(
    grup_kepuasan = if_else(
      kepuasan_hidup > mean(kepuasan_hidup),
      "Di Atas Rata-rata",
      "Di Bawah Rata-rata"
    )
  )

table(wvs_cleaned$negara, wvs_cleaned$grup_kepuasan)

# Pivot wider
wvs_cleaned |>
  summarize(
    rata_kepuasan = mean(kepuasan_hidup),
    .by = c(negara, kelompok_usia)
  ) |>
  pivot_wider(names_from = kelompok_usia, values_from = rata_kepuasan)


# ---- BAGIAN 3: VISUALISASI DAN STATISTIK DESKRIPTIF ----

# --- 12. Statistik Deskriptif ---
library(DescTools)
mean(wvs_cleaned$usia, na.rm = TRUE)
median(wvs_cleaned$usia, na.rm = TRUE)
DescTools::Mode(wvs_cleaned$usia, na.rm = TRUE)

sd(wvs_cleaned$usia, na.rm = TRUE)
var(wvs_cleaned$usia, na.rm = TRUE)
range(wvs_cleaned$usia, na.rm = TRUE)
IQR(wvs_cleaned$usia, na.rm = TRUE)

# Ringkasan per variabel
wvs_cleaned |>
  select(kepuasan_hidup, kebebasan_memilih, kepuasan_finansial, usia) |>
  pivot_longer(everything(), names_to = "variabel", values_to = "nilai") |>
  summarize(
    M = mean(nilai), SD = sd(nilai),
    Min = min(nilai), Max = max(nilai),
    .by = variabel
  )

table(wvs_cleaned$negara)

# --- 14. Visualisasi ---

# Histogram
ggplot(wvs_cleaned, aes(x = kepuasan_hidup)) +
  geom_histogram(binwidth = 1, fill = "steelblue", color = "white") +
  labs(title = "Distribusi Kepuasan Hidup", x = "Kepuasan Hidup", y = "Frekuensi")

# Boxplot per negara
ggplot(wvs_cleaned, aes(x = negara, y = kepuasan_hidup, fill = negara)) +
  geom_boxplot() +
  labs(title = "Kepuasan Hidup per Negara", x = "Negara", y = "Kepuasan Hidup") +
  theme(legend.position = "none")

# Bar chart
ggplot(wvs_cleaned, aes(x = negara, fill = negara)) +
  geom_bar() +
  labs(title = "Jumlah Responden per Negara", x = "Negara", y = "Jumlah") +
  theme_minimal() +
  theme(legend.position = "none")

# Pie chart
proporsi_negara <- wvs_cleaned |>
  count(negara) |>
  mutate(persen = n / sum(n) * 100)

ggplot(proporsi_negara, aes(x = "", y = persen, fill = negara)) +
  geom_col(width = 1) +
  coord_polar(theta = "y") +
  labs(title = "Proporsi Responden per Negara") +
  theme_void()

# Scatter plot
ggplot(wvs_cleaned, aes(x = kebebasan_memilih, y = kepuasan_hidup)) +
  geom_jitter(alpha = 0.1, width = 0.3, height = 0.3) +
  geom_smooth(method = "lm", color = "red") +
  labs(title = "Kebebasan Memilih vs Kepuasan Hidup",
       x = "Kebebasan Memilih", y = "Kepuasan Hidup")

# Tabulasi silang
wvs_cleaned |>
  count(negara, kelompok_usia) |>
  pivot_wider(names_from = negara, values_from = n)

# Stacked bar chart
ggplot(wvs_cleaned, aes(x = negara, fill = kelompok_usia)) +
  geom_bar() +
  labs(title = "Distribusi Kelompok Usia per Negara",
       x = "Negara", y = "Jumlah", fill = "Kelompok Usia") +
  theme_minimal()

# Grouped bar chart
ggplot(wvs_cleaned, aes(x = negara, fill = kelompok_usia)) +
  geom_bar(position = "dodge") +
  labs(title = "Distribusi Kelompok Usia per Negara (Grouped)",
       x = "Negara", y = "Jumlah", fill = "Kelompok Usia") +
  theme_minimal()

# Proportional bar chart
ggplot(wvs_cleaned, aes(x = negara, fill = kelompok_usia)) +
  geom_bar(position = "fill") +
  labs(title = "Proporsi Kelompok Usia per Negara",
       x = "Negara", y = "Proporsi", fill = "Kelompok Usia") +
  theme_minimal() +
  scale_y_continuous(labels = scales::percent)

# --- 15. Korelasi ---
cor(wvs_cleaned$kepuasan_finansial, wvs_cleaned$kepuasan_hidup)

# Matriks korelasi
library(corrplot)
wvs_cleaned |>
  select(kepuasan_hidup, kepuasan_finansial, religiusitas,
         kebebasan_memilih, usia) |>
  cor(use = "complete.obs") |>
  corrplot(method = "color", type = "upper",
           addCoef.col = "black", number.cex = 0.8,
           tl.col = "black", tl.cex = 0.8)

# --- 16. Faceting ---
ggplot(wvs_cleaned, aes(x = kepuasan_finansial, y = kepuasan_hidup)) +
  geom_jitter(alpha = 0.2, width = 0.3, height = 0.3) +
  geom_smooth(method = "lm", color = "red") +
  facet_wrap(~ negara) +
  labs(title = "Kepuasan Finansial vs Kepuasan Hidup per Negara",
       x = "Kepuasan Finansial", y = "Kepuasan Hidup") +
  theme_minimal()
