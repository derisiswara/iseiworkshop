# Prompt untuk AI Agent: Perbaikan Workshop ISEI — Regresi & SEM dengan RStudio

## KONTEKS PROYEK

Kamu adalah AI Agent yang bertugas memperbaiki bahan workshop akademik bertema "Analisis Regresi & SEM dengan RStudio" untuk ISEI (Ikatan Sarjana Ekonomi Indonesia). Workshop ini ditujukan untuk peneliti, dosen, dan mahasiswa pascasarjana.

Proyek ini adalah Quarto website (`_quarto.yml`). Setiap sesi punya 3 format output:
- **Slides** (`.qmd` format `revealjs`) — untuk presentasi di workshop
- **Notebook** (`-notebook.qmd` format `html`) — untuk peserta ikuti hands-on
- **R Script** (`-script.R`) — kode mandiri untuk referensi peserta

Kode R di ketiga format harus **konsisten** (model, variabel, urutan) agar peserta tidak bingung. Bahasa pengantar: **Bahasa Indonesia**. Komentar kode: boleh campuran Indonesia/Inggris.

---

## STRUKTUR FILE YANG HARUS DIMODIFIKASI

```
├── dataset.qmd                    # Halaman deskripsi dataset (perlu di-update)
├── 02-regresi.qmd                 # Slides regresi (revealjs)
├── 02-regresi-notebook.qmd        # Notebook regresi (html)
├── 02-regresi-script.R            # Script regresi
├── 03-sem.qmd                     # Slides SEM (revealjs)
├── 03-sem-notebook.qmd            # Notebook SEM (html)
├── 03-sem-script.R                # Script SEM
├── index.qmd                      # Homepage (cek link download data)
├── _quarto.yml                    # Config (tambah readxl di install.packages)
└── data/
    ├── regresi/
    │   ├── wvs1.xlsx              # WVS Wave 7: Singapura, Kanada, Selandia Baru
    │   └── wvs2.xlsx              # WVS Wave 7: Singapura, Thailand, Indonesia
    ├── sem/
    │   ├── data.xlsx              # CB-SEM: e-loyalty (n=485, 15 kolom)
    │   ├── Measurement Scale.pdf  # Skala pengukuran CB-SEM
    │   └── Bootstrapping.PNG      # Path diagram referensi
    └── plssem/
        ├── sem_mobi.xlsx          # PLS-SEM: ECSI mobile (n=250, 24 kolom)
        └── desc data.txt          # Deskripsi lengkap dataset mobi
```

---

## DATASET BARU — DESKRIPSI LENGKAP

### 1. Regresi: WVS Wave 7 (format xlsx)

**File:** `data/regresi/wvs1.xlsx` (7.087 obs) dan `data/regresi/wvs2.xlsx` (6.712 obs)

Sama persis dengan data sebelumnya (csv), hanya berubah format ke xlsx. Kolom:
`negara, id_responden, pentingnya_keluarga, pentingnya_teman, pentingnya_waktu_luang, pentingnya_pekerjaan, kebebasan_memilih, kepuasan_hidup, kepuasan_finansial, religiusitas, skala_politik, jenis_kelamin, tahun_lahir, usia, status_pernikahan, status_pekerjaan`

**Perubahan yang diperlukan:**
- Ganti semua `read_csv("data/wvs1.csv")` → `read_excel("data/regresi/wvs1.xlsx")`
- Ganti semua `read_csv("data/wvs2.csv")` → `read_excel("data/regresi/wvs2.xlsx")`
- Tambahkan `library(readxl)` di semua file regresi
- Path download di `dataset.qmd` harus mengarah ke `data/regresi/wvs1.xlsx` dst.

### 2. CB-SEM: Electronic Loyalty (lavaan)

**File:** `data/sem/data.xlsx` (485 obs, 15 kolom)

| Kolom | Deskripsi |
|-------|-----------|
| No | Nomor responden |
| HV1–HV4 | Hedonic Value (Lee & Wu, 2017) — skala Likert |
| PMB1–PMB4 | Perceived Mental Benefits (Nguyen & Khoa, 2019) — skala Likert |
| ELOY1–ELOY3 | Electronic Loyalty (Khoa & Nguyen, 2020; Srivastava & Rai, 2018) — skala Likert |
| gender | Jenis kelamin |
| occupation | Pekerjaan |
| times | Frekuensi penggunaan |

**Konstruk (semua reflektif):**
- **PMB** (Perceived Mental Benefits) =~ PMB1 + PMB2 + PMB3 + PMB4
- **HV** (Hedonic Value) =~ HV1 + HV2 + HV3 + HV4
- **ELOY** (Electronic Loyalty) =~ ELOY1 + ELOY2 + ELOY3

**Model struktural:**
```
PMB → ELOY    (direct effect)
PMB → HV      (β ≈ 0.439)
HV  → ELOY    (β ≈ 0.201)
PMB → HV → ELOY  (indirect/mediasi)
```

**Referensi teori:**
- Khoa, B. T., & Nguyen, H. M. (2020). Electronic Loyalty In Social Commerce. *Gadjah Mada International Journal of Business*, 22(3), 275-299.
- Lee, C.-H., & Wu, J. J. (2017). Consumer online flow experience. *Industrial Management & Data Systems*, 117(10), 2452-2467.
- Nguyen, M. H., & Khoa, B. T. (2019). Perceived Mental Benefit in Electronic Commerce. *Sustainability*, 11(23), 6587-6608.

**File pendukung:**
- `data/sem/Measurement Scale.pdf` — item-item kuesioner lengkap
- `data/sem/Bootstrapping.PNG` — path diagram dengan koefisien (dari SmartPLS)

### 3. PLS-SEM: ECSI Mobile Industry (seminr)

**File:** `data/plssem/sem_mobi.xlsx` (250 obs, 24 kolom)

Ini adalah dataset `mobi` yang umum digunakan dalam tutorial PLS-SEM, berasal dari European Customer Satisfaction Index (ECSI) untuk industri telepon seluler.

| Konstruk | Indikator | Deskripsi |
|----------|-----------|-----------|
| **IMAG** (Corporate Image) | IMAG1–IMAG5 | Trustworthiness, stabilitas, kontribusi sosial, kepedulian, inovasi |
| **CUEX** (Customer Expectations) | CUEX1–CUEX3 | Ekspektasi kualitas, pemenuhan kebutuhan, frekuensi error |
| **PERQ** (Perceived Quality) | PERQ1–PERQ7 | Kualitas keseluruhan, teknis, layanan, produk, keragaman, reliabilitas, transparansi |
| **PERV** (Perceived Value) | PERV1–PERV2 | Harga vs kualitas, kualitas vs harga |
| **CUSA** (Customer Satisfaction) | CUSA1–CUSA3 | Kepuasan keseluruhan, fulfillment, perbandingan ideal |
| **CUSCO** (Customer Complaints) | CUSCO | Single indicator — penanganan keluhan |
| **CUSL** (Customer Loyalty) | CUSL1–CUSL3 | Repurchase, price tolerance, word of mouth |

**Skala:** Likert 1–10

**Catatan khusus:**
- CUSCO adalah single-indicator construct — perlu perlakuan khusus di seminr
- PERV hanya 2 indikator — perlu disebutkan implikasinya
- Deskripsi lengkap ada di `data/plssem/desc data.txt`

**Model struktural ECSI (referensi standar):**
```
IMAG → CUEX
IMAG → CUSA
IMAG → CUSL
CUEX → PERQ
CUEX → PERV
CUEX → CUSA
PERQ → PERV
PERQ → CUSA
PERV → CUSA
CUSA → CUSCO
CUSA → CUSL
CUSCO → CUSL
```

---

## INSTRUKSI PERBAIKAN — STEP BY STEP

### STEP 0: Persiapan

1. Baca SEMUA file yang akan dimodifikasi untuk memahami struktur saat ini.
2. Baca `data/plssem/desc data.txt` untuk deskripsi lengkap dataset PLS-SEM.
3. Baca `data/sem/Measurement Scale.pdf` untuk memahami item kuesioner CB-SEM.
4. Lihat `data/sem/Bootstrapping.PNG` untuk referensi visual model CB-SEM.
5. Pastikan paket R yang dibutuhkan: `readxl`, `tidyverse`, `broom`, `car`, `lavaan`, `semPlot`, `seminr`, `knitr`.

---

### STEP 1: Update `dataset.qmd` — Halaman Deskripsi Dataset

**Tujuan:** Perbarui halaman dataset agar menjelaskan ketiga dataset baru dengan link download langsung.

1. **Hapus** semua konten lama yang merujuk ke dataset csv dan dataset dummy.
2. **Tulis ulang** dengan tiga bagian: Regresi (WVS), CB-SEM (E-Loyalty), PLS-SEM (ECSI Mobile).
3. Untuk setiap dataset, sertakan:
   - Deskripsi singkat dan sumber/referensi akademik
   - Tabel variabel/indikator lengkap
   - **Link download langsung** menggunakan format: `[Download wvs1.xlsx](data/regresi/wvs1.xlsx)` — PASTIKAN path relatif benar agar file bisa langsung diklik dan terdownload dari website.
4. Untuk CB-SEM, sertakan deskripsi item kuesioner (dari Measurement Scale.pdf).
5. Untuk PLS-SEM, sertakan deskripsi konstruk dan indikator (dari desc data.txt).

---

### STEP 2: Perbaiki Sesi Regresi (02-regresi.qmd, 02-regresi-notebook.qmd, 02-regresi-script.R)

**Tujuan:** Ganti sumber data ke xlsx, perkuat aspek akademik, seragamkan ketiga format.

#### 2A. Perubahan Data (semua format)
1. Tambahkan `library(readxl)` di bagian setup.
2. Ganti semua `read_csv("data/wvs1.csv")` → `read_excel("data/regresi/wvs1.xlsx")`.
3. Ganti semua `read_csv("data/wvs2.csv")` → `read_excel("data/regresi/wvs2.xlsx")`.
4. Di latihan terakhir yang menggabungkan wvs1+wvs2, pastikan path juga diupdate.

#### 2B. Seragamkan Model Antar Format
Pastikan ketiga file menggunakan **urutan model yang sama persis**:
- m1: `kepuasan_hidup ~ kepuasan_finansial` (regresi sederhana)
- m2: `kepuasan_hidup ~ kepuasan_finansial + kebebasan_memilih` (berganda 2 prediktor)
- m3: `kepuasan_hidup ~ kepuasan_finansial + kebebasan_memilih + religiusitas + usia` (berganda penuh numerik)
- m4: m3 + `jenis_kelamin` (kategorikal)
- m5: m4 + `negara` (multi-level kategorikal)
- m6: interaksi `kepuasan_finansial * jenis_kelamin` + prediktor lain

Jika ada format yang berbeda (terutama script), seragamkan ke urutan di atas.

#### 2C. Penguatan Akademik — Tambahkan di Slides DAN Notebook
1. **Landasan teori (1 slide/section baru setelah "Apa itu Regresi?"):**
   - Teori Subjective Well-Being (Diener et al., 1999): kepuasan hidup sebagai komponen kognitif SWB
   - Hubungan antara kebebasan individual dan kesejahteraan (Inglehart, 2000; Sen, 1999)
   - Justifikasi pemilihan variabel berdasarkan WVS literature

2. **Justifikasi skala ordinal sebagai kontinu (tambahkan di slide "Menyiapkan Data" atau setelahnya):**
   - Tambahkan callout/note: "Variabel skala 1–10 diperlakukan sebagai kontinu berdasarkan Norman (2010) yang menunjukkan bahwa Likert data dengan ≥ 5 kategori bersifat robust untuk analisis parametrik."

3. **Diagnostik tambahan (tambahkan setelah bagian VIF yang sudah ada):**
   ```r
   # Breusch-Pagan test untuk homoskedastisitas
   library(lmtest)
   bptest(m3)

   # Robust standard errors (HC3)
   library(sandwich)
   coeftest(m3, vcov = vcovHC(m3, type = "HC3"))
   ```
   Jelaskan: "Jika p-value BP test < 0.05, gunakan robust standard errors untuk inferensi yang lebih valid."

4. **Confidence interval (tambahkan di semua `tidy()`):**
   - Ganti semua `tidy(m1)` → `tidy(m1, conf.int = TRUE)`
   - Tambahkan catatan: "APA 7th Edition merekomendasikan pelaporan CI di samping p-value."

5. **Effect size (tambahkan di tabel perbandingan model):**
   - Tambahkan kolom Cohen's f² = R² / (1 − R²) di tabel perbandingan model.
   - Berikan interpretasi: f² = 0.02 (kecil), 0.15 (sedang), 0.35 (besar).

6. **Template pelaporan APA (perbaiki yang sudah ada):**
   - Ganti placeholder "..." dengan instruksi yang lebih spesifik.
   - Tambahkan contoh pelaporan dengan CI.

7. **Tambahkan `set.seed(2026)` di awal setiap file** untuk reproducibility.

8. **Tambahkan `library(lmtest)` dan `library(sandwich)` di setup** karena digunakan untuk diagnostik.

9. **Update `install.packages()` di `index.qmd`** — tambahkan `"readxl"`, `"lmtest"`, `"sandwich"`.

---

### STEP 3: Perbaiki Sesi CB-SEM (03-sem.qmd, 03-sem-notebook.qmd, 03-sem-script.R) — Bagian CB-SEM

**Tujuan:** Ganti dataset dummy e-commerce dengan data riil e-loyalty. Terapkan two-step approach yang benar. Perkuat evaluasi validitas/reliabilitas.

#### 3A. Ganti Dataset dan Konstruk
1. Ganti `read_csv("data/sem_ecommerce.csv")` → `read_excel("data/sem/data.xlsx")`.
2. Hapus kolom `No` dari analisis: `dat <- dat |> select(-No)`.
3. Update semua spesifikasi model:

**CFA Model:**
```r
cfa_model <- '
  PMB  =~ PMB1 + PMB2 + PMB3 + PMB4
  HV   =~ HV1 + HV2 + HV3 + HV4
  ELOY =~ ELOY1 + ELOY2 + ELOY3
'
```

**Full SEM Model:**
```r
sem_model <- '
  # Measurement model
  PMB  =~ PMB1 + PMB2 + PMB3 + PMB4
  HV   =~ HV1 + HV2 + HV3 + HV4
  ELOY =~ ELOY1 + ELOY2 + ELOY3

  # Structural model
  HV   ~ PMB
  ELOY ~ PMB + HV
'
```

4. Update tabel hipotesis:

| No | Hipotesis | Path |
|----|-----------|------|
| H1 | Perceived Mental Benefits berpengaruh positif terhadap Electronic Loyalty | ELOY ~ PMB |
| H2 | Perceived Mental Benefits berpengaruh positif terhadap Hedonic Value | HV ~ PMB |
| H3 | Hedonic Value berpengaruh positif terhadap Electronic Loyalty | ELOY ~ HV |

5. Update tabel konstruk dan indikator dengan deskripsi dari Measurement Scale.pdf.

#### 3B. Two-Step Approach (Struktur Analisis)
Pertahankan alur two-step approach dari bahan lama, tapi sesuaikan dengan data baru:

**Step 1 — CFA:**
1. Spesifikasi dan estimasi CFA
2. Evaluasi fit indices (chi-square, CFI, TLI, RMSEA, SRMR)
3. Evaluasi factor loadings (standardized ≥ 0.50, idealnya ≥ 0.70)
4. Hitung CR dan AVE
5. **TAMBAHKAN: Matriks Fornell-Larcker untuk discriminant validity**:
   ```r
   # Matriks korelasi antar konstruk
   cor_matrix <- lavInspect(cfa_fit, "cor.lv")

   # Hitung sqrt(AVE) dan bandingkan
   # sqrt(AVE) di diagonal harus > korelasi off-diagonal
   ```
6. **TAMBAHKAN: Penjelasan eksplisit tentang two-step approach** — mengapa CFA dulu sebelum full SEM (1 slide baru). Jelaskan referensi Anderson & Gerbing (1988).

**Step 2 — Full SEM:**
1. Spesifikasi full structural model
2. Estimasi dan evaluasi fit
3. Tabel path coefficients dengan keputusan hipotesis
4. R² variabel endogen
5. **TAMBAHKAN: Analisis mediasi sebagai bagian materi utama (BUKAN hanya latihan)**:
   ```r
   sem_med <- '
     PMB  =~ PMB1 + PMB2 + PMB3 + PMB4
     HV   =~ HV1 + HV2 + HV3 + HV4
     ELOY =~ ELOY1 + ELOY2 + ELOY3

     HV   ~ a*PMB
     ELOY ~ c*PMB + b*HV

     # Indirect effect
     indirect := a*b
     # Total effect
     total := c + a*b
   '
   sem_med_fit <- sem(sem_med, data = dat, se = "bootstrap", bootstrap = 1000)
   parameterEstimates(sem_med_fit) |> filter(op == ":=")
   ```
   Jelaskan: "Analisis mediasi menguji apakah HV memediasi hubungan PMB → ELOY. Gunakan bootstrap CI untuk menilai signifikansi indirect effect."

#### 3C. Penguatan Akademik Tambahan
1. **Slide "Kapan Menggunakan CB-SEM vs PLS-SEM?"** — pertahankan dari bahan lama (sudah bagus).
2. **Tambahkan catatan tentang Common Method Bias (1 callout):**
   "Karena semua data dikumpulkan melalui self-report questionnaire, perhatikan risiko Common Method Variance (CMV). Dalam riset jurnal, lakukan uji Harman's single-factor test atau full collinearity VIF approach (Kock, 2015)."
3. **Template pelaporan APA untuk CB-SEM** — perbaiki agar lebih lengkap dengan contoh angka.
4. **Referensi** — tambahkan di akhir:
   - Anderson, J.C. & Gerbing, D.W. (1988). Structural Equation Modeling in Practice. *Psychological Bulletin*, 103(3), 411-423.
   - Hu, L. & Bentler, P.M. (1999). Cutoff criteria for fit indexes. *Structural Equation Modeling*, 6(1), 1-55.
   - Fornell, C. & Larcker, D.F. (1981). Evaluating SEM with unobservable variables. *Journal of Marketing Research*, 18(1), 39-50.
   - Ditambah referensi dataset: Khoa & Nguyen (2020), Lee & Wu (2017), Nguyen & Khoa (2019).

---

### STEP 4: Perbaiki Sesi PLS-SEM (03-sem.qmd, 03-sem-notebook.qmd, 03-sem-script.R) — Bagian PLS-SEM

**Tujuan:** Ganti dataset dummy innovation dengan dataset ECSI mobile (mobi). Perkuat evaluasi dan tambahkan fitur analisis lanjutan.

#### 4A. Ganti Dataset dan Konstruk
1. Ganti `read_csv("data/sem_innovation.csv")` → `read_excel("data/plssem/sem_mobi.xlsx")`.
2. Update spesifikasi model:

**Measurement Model:**
```r
mm <- constructs(
  composite("IMAG", multi_items("IMAG", 1:5)),
  composite("CUEX", multi_items("CUEX", 1:3)),
  composite("PERQ", multi_items("PERQ", 1:7)),
  composite("PERV", multi_items("PERV", 1:2)),
  composite("CUSA", multi_items("CUSA", 1:3)),
  composite("CUSCO", single_item("CUSCO")),
  composite("CUSL", multi_items("CUSL", 1:3))
)
```
Catatan: Semua konstruk ini reflektif (Mode A, default). CUSCO adalah single-item construct.

**Structural Model (ECSI):**
```r
sm <- relationships(
  paths(from = "IMAG",  to = c("CUEX", "CUSA", "CUSL")),
  paths(from = "CUEX",  to = c("PERQ", "PERV", "CUSA")),
  paths(from = "PERQ",  to = c("PERV", "CUSA")),
  paths(from = "PERV",  to = "CUSA"),
  paths(from = "CUSA",  to = c("CUSCO", "CUSL")),
  paths(from = "CUSCO", to = "CUSL")
)
```

3. Update tabel hipotesis sesuai model ECSI. Buat tabel lengkap H1–H12 (atau sesuai jumlah path).

4. Update tabel konstruk dan indikator — gunakan deskripsi dari `data/plssem/desc data.txt`.

#### 4B. Evaluasi Measurement Model (Outer Model) — Perkuat
1. **Reliability:** Tampilkan `summary(pls_model)$reliability` — Cronbach's Alpha, rhoC, AVE, rhoA.
2. **Outer Loadings:** Tampilkan loadings dan berikan interpretasi per konstruk.
3. **Discriminant Validity:**
   - **HTMT** (sudah ada) — pertahankan dan jelaskan threshold < 0.90.
   - **TAMBAHKAN: Fornell-Larcker Criterion** — `summary(pls_model)$validity$fl_criteria`.
   - **TAMBAHKAN: Cross-Loadings** — `summary(pls_model)$validity$cross_loadings`. Jelaskan bahwa loading pada konstruk sendiri harus > loading pada konstruk lain.
4. **Catatan khusus:**
   - Jelaskan bahwa CUSCO sebagai single-item construct tidak bisa dievaluasi reliabilitasnya secara tradisional.
   - Jelaskan bahwa PERV dengan 2 indikator memiliki keterbatasan — AVE dan CR bisa kurang stabil.

#### 4C. Evaluasi Structural Model (Inner Model) — Perkuat
1. **Bootstrap:** Naikkan `nboot` dari 1000 menjadi 5000. Tambahkan `set.seed()`.
   ```r
   set.seed(2026)
   boot <- bootstrap_model(pls_model, nboot = 5000)
   ```
2. **Path Coefficients:** Tampilkan `boot_summary$bootstrapped_paths` dengan interpretasi.
3. **R² dan Adjusted R²:** Tampilkan dan jelaskan interpretasi (0.25 lemah, 0.50 moderat, 0.75 substansial).
4. **f² Effect Size:** Tampilkan `summary(pls_model)$fSquare` dan jelaskan (0.02 kecil, 0.15 sedang, 0.35 besar).
5. **TAMBAHKAN: Analisis Mediasi (materi utama, bukan latihan):**
   ```r
   # Contoh: indirect effect IMAG → CUSA → CUSL
   med_imag <- specific_effect_significance(boot,
     from = "IMAG", through = "CUSA", to = "CUSL")
   med_imag
   ```
   Jelaskan konsep mediasi dan cara interpretasi bootstrap CI.
6. **TAMBAHKAN: PLS-Predict (predictive relevance):**
   ```r
   pred <- predict_pls(
     model = pls_model,
     technique = predict_DA,
     noFolds = 10,
     reps = 10
   )
   sum_pred <- summary(pred)
   ```
   Jelaskan: "Jika RMSE PLS < RMSE LM untuk mayoritas indikator, model memiliki predictive power yang baik."

#### 4D. Penguatan Akademik Tambahan
1. **Hapus semua referensi ke konstruk formatif dari slides/notebook PLS-SEM.**
   Dataset ECSI mobi semuanya reflektif. Namun, **pertahankan slide penjelasan konsep "Reflektif vs Formatif"** sebagai pengetahuan umum, dengan catatan bahwa model kali ini hanya menggunakan reflektif.
2. **Tambahkan referensi:**
   - Hair, J.F., Risher, J.J., Sarstedt, M. & Ringle, C.M. (2019). When to use and how to report PLS-SEM. *European Business Review*, 31(1), 2-24.
   - Henseler, J., Ringle, C.M. & Sarstedt, M. (2015). A new criterion for assessing discriminant validity. *JAMS*, 43(1), 115-135.
   - Shmueli, G., et al. (2019). Predictive model assessment in PLS-SEM. *European Journal of Marketing*, 53(11), 2322-2347.

---

### STEP 5: Update `dataset.qmd` — Link Download

Pastikan halaman dataset memiliki link download yang berfungsi untuk SEMUA file data:

```markdown
### Download Data

**Regresi:**

- [wvs1.xlsx](data/regresi/wvs1.xlsx) — WVS Wave 7: Singapura, Kanada, Selandia Baru (n = 7.087)
- [wvs2.xlsx](data/regresi/wvs2.xlsx) — WVS Wave 7: Singapura, Thailand, Indonesia (n = 6.712)

**CB-SEM:**

- [data.xlsx](data/sem/data.xlsx) — E-Loyalty: Perceived Mental Benefits, Hedonic Value, Electronic Loyalty (n = 485)
- [Measurement Scale.pdf](data/sem/Measurement Scale.pdf) — Skala pengukuran dan item kuesioner

**PLS-SEM:**

- [sem_mobi.xlsx](data/plssem/sem_mobi.xlsx) — ECSI Mobile Industry: 7 konstruk, 24 indikator (n = 250)
```

**PENTING:** Pastikan link bisa langsung diklik dan mendownload file. Di Quarto website, link relatif ke file di folder `data/` akan berfungsi jika file tersebut di-copy ke output directory. Jika perlu, tambahkan di `_quarto.yml`:
```yaml
resources:
  - data/**
```

---

### STEP 6: Update `index.qmd`

1. Update daftar `install.packages()` di bagian Kegiatan Pra-Workshop:
   ```r
   install.packages(c("readxl", "car", "broom", "lmtest", "sandwich",
                       "lavaan", "semPlot", "seminr", "tidyverse",
                       "rmarkdown", "knitr"))
   ```
2. Pastikan deskripsi Sesi 3 di tabel jadwal masih akurat setelah perubahan dataset.

---

### STEP 7: Verifikasi Konsistensi

Setelah semua perubahan selesai, lakukan pengecekan:

1. **Konsistensi antar format:** Untuk setiap sesi, pastikan slides, notebook, dan script menggunakan variabel, model, dan urutan analisis yang SAMA.
2. **Path data:** Pastikan semua `read_excel()` mengarah ke path yang benar.
3. **Library:** Pastikan semua library yang digunakan sudah di-load di awal setiap file.
4. **Render test:** Jalankan `quarto render` dan pastikan tidak ada error. Cek bahwa link download data berfungsi.
5. **set.seed():** Pastikan ada di awal setiap file yang menggunakan bootstrap atau sampling.
6. **Bahasa:** Semua narasi dalam Bahasa Indonesia. Nama variabel/kode boleh Inggris.
7. **Cross-check references:** Pastikan semua referensi akademik yang disebutkan konsisten di slides, notebook, dan script.

---

## CHECKLIST RINGKAS

- [ ] `dataset.qmd` — rewrite dengan 3 dataset baru + link download
- [ ] `_quarto.yml` — tambah `resources: - data/**`
- [ ] `index.qmd` — update install.packages
- [ ] `02-regresi.qmd` — data xlsx, teori SWB, diagnostik tambahan, CI, effect size, seragamkan model
- [ ] `02-regresi-notebook.qmd` — sama dengan slides
- [ ] `02-regresi-script.R` — sama dengan slides
- [ ] `03-sem.qmd` — CB-SEM: dataset e-loyalty, two-step, Fornell-Larcker, mediasi, referensi
- [ ] `03-sem.qmd` — PLS-SEM: dataset ECSI mobi, cross-loading, FL, PLS-Predict, mediasi, nboot=5000
- [ ] `03-sem-notebook.qmd` — sama dengan slides
- [ ] `03-sem-script.R` — sama dengan slides
- [ ] Verifikasi konsistensi antar format
- [ ] Test render Quarto
