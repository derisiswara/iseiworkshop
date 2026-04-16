# Kamus Variabel — World Values Survey (WVS) Wave 7

## Informasi Dataset

| File | Negara |
|---|---|
| `wvs1.csv` | Singapura, Kanada, Selandia Baru |
| `wvs2.csv` | Singapura, Thailand, Indonesia |

**Sumber:** World Values Survey Association (2022). *World Values Survey Wave 7 (2017–2022)*. <https://www.worldvaluessurvey.org/>

---

## Daftar Variabel

### Identitas

| Variabel | Deskripsi |
|---|---|
| `negara` | Negara responden (Kanada, Singapura, Selandia Baru, Indonesia, Thailand) |
| `id_responden` | Identitas unik setiap responden (numerik) |

### Nilai & Prioritas Hidup

Variabel-variabel berikut mengukur seberapa penting aspek-aspek kehidupan bagi responden. **Perhatian:** skala bersifat **terbalik** — skor lebih rendah berarti **lebih penting**.

| Variabel | Pertanyaan Survei | Skala |
|---|---|---|
| `pentingnya_keluarga` | "Seberapa penting keluarga dalam hidup Anda?" | 1 = Sangat penting, 2 = Cukup penting, 3 = Kurang penting, 4 = Tidak penting sama sekali |
| `pentingnya_teman` | "Seberapa penting teman dalam hidup Anda?" | 1 = Sangat penting, 2 = Cukup penting, 3 = Kurang penting, 4 = Tidak penting sama sekali |
| `pentingnya_waktu_luang` | "Seberapa penting waktu luang dalam hidup Anda?" | 1 = Sangat penting, 2 = Cukup penting, 3 = Kurang penting, 4 = Tidak penting sama sekali |
| `pentingnya_pekerjaan` | "Seberapa penting pekerjaan dalam hidup Anda?" | 1 = Sangat penting, 2 = Cukup penting, 3 = Kurang penting, 4 = Tidak penting sama sekali |

### Kesejahteraan Subjektif & Nilai

| Variabel | Pertanyaan Survei | Skala |
|---|---|---|
| `kebebasan_memilih` | "Seberapa besar kebebasan memilih dan kendali yang Anda rasakan atas hidup Anda?" | 1 (Tidak ada kebebasan sama sekali) – 10 (Sangat banyak kebebasan) |
| `kepuasan_hidup` | "Secara keseluruhan, seberapa puas Anda dengan hidup Anda saat ini?" | 1 (Sangat tidak puas) – 10 (Sangat puas) |
| `kepuasan_finansial` | "Seberapa puas Anda dengan kondisi keuangan rumah tangga Anda?" | 1 (Sangat tidak puas) – 10 (Sangat puas) |

### Orientasi Politik & Agama

| Variabel | Pertanyaan Survei | Nilai |
|---|---|---|
| `religiusitas` | "Apakah Anda menganggap diri Anda sebagai..." | Religius, Tidak religius, Ateis, Tidak tahu |
| `skala_politik` | "Dalam skala politik, di mana Anda memposisikan diri?" | 1 (Kiri / Liberal) – 10 (Kanan / Konservatif); **-1** = Tidak tahu / Tidak menjawab |

### Demografi

| Variabel | Deskripsi | Nilai |
|---|---|---|
| `jenis_kelamin` | Jenis kelamin responden | Laki-laki, Perempuan |
| `tahun_lahir` | Tahun kelahiran responden | Numerik (tahun) |
| `usia` | Usia responden saat survei dilaksanakan | Numerik (tahun) |
| `status_pernikahan` | Status pernikahan saat ini | Menikah, Kohabitasi, Bercerai, Pisah, Janda/Duda, Lajang |
| `status_pekerjaan` | Status pekerjaan saat ini | Penuh waktu, Paruh waktu, Wiraswasta, Pensiunan, Ibu rumah tangga, Pelajar/Mahasiswa, Tidak bekerja, Lainnya |

---

## Catatan Penting

1. **Variabel `pentingnya_*`** (keluarga, teman, waktu_luang, pekerjaan): Skala **terbalik** — skor 1 = paling penting, skor 4 = paling tidak penting. Jika ingin konsistensi arah dengan variabel lain, pertimbangkan untuk melakukan *reverse coding* (5 - skor asli).

2. **Variabel `kebebasan_memilih`, `kepuasan_hidup`, `kepuasan_finansial`**: Skala 1–10, skor lebih tinggi = **lebih positif**. Cocok digunakan sebagai variabel dependen dalam analisis regresi.

3. **Variabel `skala_politik`**: Nilai **-1** menunjukkan *missing value* (responden tidak menjawab atau tidak tahu). Harus ditangani sebelum analisis (hapus atau imputasi).

4. **Variabel `religiusitas`**: Variabel **kategorikal** (bukan numerik). Perlu di-*dummy code* jika digunakan dalam regresi.

5. **Perbedaan urutan kolom**: Kedua file CSV memiliki variabel yang sama, namun dengan **urutan kolom yang berbeda**. Pastikan merujuk pada nama kolom (bukan posisi) saat menggabungkan data.

6. **Konteks survei**: Data dikumpulkan antara 2017–2022 sebagai bagian dari World Values Survey Wave 7. Usia responden dihitung pada saat pengisian survei.

---

## Contoh Penggunaan untuk Analisis Regresi (R)

```r
library(tidyverse)

# Baca dan gabungkan data
wvs1 <- read_csv("wvs1.csv")
wvs2 <- read_csv("wvs2.csv")
wvs <- bind_rows(wvs1, wvs2)

# Bersihkan missing values di skala_politik
wvs_clean <- wvs |>
  filter(skala_politik >= 1)

# Contoh: Regresi kepuasan hidup
model <- lm(kepuasan_hidup ~ kebebasan_memilih + kepuasan_finansial +
              factor(religiusitas) + usia + factor(jenis_kelamin) +
              factor(negara),
            data = wvs_clean)
summary(model)
```
