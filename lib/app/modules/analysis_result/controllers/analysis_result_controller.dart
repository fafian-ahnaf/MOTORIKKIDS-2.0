import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:motorikkids/app/modules/recommendation/views/recommendation_view.dart';
import 'package:motorikkids/app/services/nlp_service.dart';

class AnalysisResultController extends GetxController {
  
  var isLoading = true.obs; 

  // --- VARIABEL OBSERVASI ---
  var inputTeks = "".obs;
  var status = "Memproses...".obs;
  var tingkatKeyakinan = 0.0.obs;
  var statusColor = Rx<Color>(Colors.grey);
  
  var recommendationData = {}.obs;

  // --- VARIABEL UMUR & KATEGORI (UNTUK ATURAN SDIDTK) ---
  var usiaBulan = 0.obs; 
  var kategoriMotorik = "".obs;

  @override
  void onInit() {
    super.onInit();
    
    // Tangkap data dari form sebelumnya
    final Map<String, dynamic> args = Get.arguments ?? {};
    
    String teksObservasi = args['teks'] ?? "Anak sudah mulai bisa melompat walau belum stabil.";
    inputTeks.value = teksObservasi;
    
    // Tangkap usia dan kategori yang dikirim dari form observasi
    usiaBulan.value = args['usia_bulan'] ?? 40; 
    kategoriMotorik.value = args['kategori'] ?? "Motorik Kasar";

    // Langsung tembak ke NLP Flask Anda
    fetchPredictionFromFlask(teksObservasi);
  }

  // ========================================================
  // 1. FUNGSI PREDIKSI MENGGUNAKAN NLP_SERVICE.DART
  // ========================================================
  Future<void> fetchPredictionFromFlask(String teks) async {
    try {
      isLoading.value = true;

      // Memanggil fungsi dari nlp_service.dart
      final data = await NlpService.analisisMotorik(teks);

      if (data != null) {
        status.value = data['prediksi_status']; 
        tingkatKeyakinan.value = (data['tingkat_keyakinan'] ?? 0.0).toDouble();

        // Jalankan rekomendasi murni dari buku KIA/SDIDTK
        _setRecommendationBakuSDIDTK(usiaBulan.value, kategoriMotorik.value, status.value);
        
      } else {
        _setFallbackData("Gagal mendapat respon dari server NLP. Pastikan API MotorikKids berjalan.");
      }
    } catch (e) {
      _setFallbackData("Terjadi kesalahan sistem. Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ========================================================
  // 2. FUNGSI RULE-BASED KIA / SDIDTK (TANPA AI EKSTERNAL)
  // ========================================================
  void _setRecommendationBakuSDIDTK(int umurBulan, String kategori, String prediksi) {
    // 1. Set Warna Sesuai Status
    if (prediksi == "BB") statusColor.value = Colors.red.shade400;
    else if (prediksi == "MB") statusColor.value = const Color(0xFFEEDB00);
    else if (prediksi == "BSH") statusColor.value = Colors.blue.shade400;
    else if (prediksi == "BSB") statusColor.value = Colors.green.shade500;

    // 2. Tentukan Tindakan Medis Baku Sesuai Umur & Kategori

    // =========================================================
    // RENTANG: 0 - 12 BULAN (Masa Bayi)
    // =========================================================
    if (umurBulan >= 0 && umurBulan <= 12) {
      if (kategori == "Kasar" || kategori == "Motorik Kasar") {
        if (prediksi == "BB") {
          recommendationData.value = {
            "title": "Intervensi Gerak Dasar",
            "goal": "Menstimulasi kekuatan otot leher, punggung, dan kaki",
            "method": "Lakukan intervensi 2 minggu. Tengkurapkan bayi untuk melatih angkat kepala, bantu duduk, atau latih merangkak meraih mainan. Jika tidak ada kemajuan, rujuk ke Puskesmas.",
            "duration": "10-15 Menit / Hari",
          };
        } else if (prediksi == "MB") {
          recommendationData.value = {
            "title": "Latihan Berdiri & Berjalan",
            "goal": "Membangun keseimbangan bertumpu pada kaki",
            "method": "Anak mulai berkembang. Latih berdiri berpegangan pada kursi/meja. Tuntun anak melangkah perlahan untuk menstimulasi keberaniannya berjalan.",
            "duration": "15 Menit / Hari",
          };
        } else if (prediksi == "BSH") {
          recommendationData.value = {
            "title": "Bermain Aktif Terarah",
            "goal": "Mempertahankan kemampuan merangkak dan berdiri",
            "method": "Perkembangan normal. Lanjutkan stimulasi dengan meletakkan mainan agak jauh agar anak merangkak cepat, atau biarkan ia merambat di pinggir tembok.",
            "duration": "Bebas",
          };
        } else if (prediksi == "BSB") {
          recommendationData.value = {
            "title": "Tantangan Berjalan Mandiri",
            "goal": "Mempersiapkan langkah pertama tanpa bantuan",
            "method": "Sangat optimal! Pancing anak untuk melangkah ke arah Anda tanpa berpegangan. Berikan jarak 1-2 langkah sebagai permulaan.",
            "duration": "Bebas",
          };
        }
      } else { 
        // Motorik Halus 0-12 Bulan
        if (prediksi == "BB") {
          recommendationData.value = {
            "title": "Intervensi Genggaman",
            "goal": "Melatih refleks meraih dan menggenggam",
            "method": "Intervensi 2 minggu: Letakkan benda berbunyi/berwarna cerah di tangannya. Latih memindahkan benda dari tangan kiri ke kanan. Jika gagal, konsultasi ke nakes.",
            "duration": "10-15 Menit / Hari",
          };
        } else if (prediksi == "MB") {
          recommendationData.value = {
            "title": "Latihan Menjimpit",
            "goal": "Melatih koordinasi jari telunjuk dan ibu jari",
            "method": "Sediakan potongan biskuit kecil atau kismis. Latih anak mengambilnya menggunakan dua jari (menjimpit). Pastikan diawasi agar tidak tersedak.",
            "duration": "10 Menit (Saat Makan/Bermain)",
          };
        } else if (prediksi == "BSH") {
          recommendationData.value = {
            "title": "Eksplorasi Benda",
            "goal": "Mempertahankan koordinasi mata dan tangan",
            "method": "Perkembangan normal. Lanjutkan stimulasi dengan permainan memasukkan dan mengeluarkan mainan dari dalam wadah (kardus/keranjang).",
            "duration": "Bebas",
          };
        } else if (prediksi == "BSB") {
          recommendationData.value = {
            "title": "Mengenal Alat Tulis Dasar",
            "goal": "Mengenalkan konsep mencoret",
            "method": "Sangat optimal! Mulai berikan krayon besar dan kertas. Ajari anak cara menggenggamnya untuk mencoret-coret bebas.",
            "duration": "Bebas dengan Pengawasan",
          };
        }
      }
    }
    // =========================================================
    // RENTANG: 13 - 24 BULAN (Batita Awal / 1-2 Tahun)
    // =========================================================
    else if (umurBulan > 12 && umurBulan <= 24) {
      if (kategori == "Kasar" || kategori == "Motorik Kasar") {
        if (prediksi == "BB") {
          recommendationData.value = {
            "title": "Intervensi Berjalan & Keseimbangan",
            "goal": "Mengejar kemampuan berjalan mandiri",
            "method": "Latih anak berjalan tanpa bantuan dan membungkuk memungut mainan lalu berdiri lagi. Jika dalam 2 minggu anak masih sering jatuh/belum bisa jalan, rujuk ke RS/Puskesmas.",
            "duration": "15-20 Menit / Hari",
          };
        } else if (prediksi == "MB") {
          recommendationData.value = {
            "title": "Latihan Tangga & Tendangan",
            "goal": "Meningkatkan kekuatan otot kaki",
            "method": "Latih anak menendang bola ke depan. Tuntun anak belajar berjalan mundur 5 langkah dan naik tangga sambil berpegangan.",
            "duration": "20 Menit / Hari",
          };
        } else if (prediksi == "BSH") {
          recommendationData.value = {
            "title": "Aktivitas Lari & Lompat Dasar",
            "goal": "Mempertahankan kemampuan gerak batita",
            "method": "Perkembangan normal. Lanjutkan stimulasi berlari kecil, bermain bola, dan memanjat perabotan yang aman dengan pengawasan.",
            "duration": "Bebas",
          };
        } else if (prediksi == "BSB") {
          recommendationData.value = {
            "title": "Persiapan Sepeda Roda Tiga",
            "goal": "Mengenalkan koordinasi kaki tingkat lanjut",
            "method": "Sangat optimal! Mulai latih anak melompat dengan kedua kaki bersamaan dan kenalkan cara mengayuh sepeda roda tiga.",
            "duration": "Bebas",
          };
        }
      } else { 
        // Motorik Halus 13-24 Bulan
        if (prediksi == "BB") {
          recommendationData.value = {
            "title": "Intervensi Motorik Jari",
            "goal": "Mengejar kemampuan menumpuk dan mencoret",
            "method": "Latih anak menumpuk 2 hingga 4 balok/kubus dan memegang pensil untuk mencoret. Lakukan setiap hari. Jika gagal setelah 2 minggu, rujuk ke nakes.",
            "duration": "15 Menit / Hari",
          };
        } else if (prediksi == "MB") {
          recommendationData.value = {
            "title": "Latihan Menggelindingkan Bola",
            "goal": "Melatih arah dan koordinasi tangan",
            "method": "Duduk berhadapan dengan anak, lalu ajari menggelindingkan bola ke arah Anda. Latih juga anak memutar gagang pintu atau membuka tutup botol.",
            "duration": "15 Menit / Hari",
          };
        } else if (prediksi == "BSH") {
          recommendationData.value = {
            "title": "Bermain Konstruktif",
            "goal": "Mempertahankan fokus dan manipulasi benda",
            "method": "Perkembangan normal. Lanjutkan stimulasi bermain puzzle sederhana (2-3 potong), menyusun balok kayu, dan makan sendiri memakai sendok.",
            "duration": "Bebas",
          };
        } else if (prediksi == "BSB") {
          recommendationData.value = {
            "title": "Latihan Menggambar Pola",
            "goal": "Persiapan motorik prasekolah",
            "method": "Sangat optimal! Mulai ajak anak meniru menggambar garis lurus atau lingkaran sederhana di atas kertas.",
            "duration": "Bebas",
          };
        }
      }
    }
    // =========================================================
    // RENTANG: 25 - 35 BULAN (Batita Akhir / 2-3 Tahun)
    // =========================================================
    else if (umurBulan > 24 && umurBulan < 36) {
      if (kategori == "Kasar" || kategori == "Motorik Kasar") {
        if (prediksi == "BB") {
          recommendationData.value = {
            "title": "Intervensi Naik Tangga & Lompat",
            "goal": "Mengejar ketertinggalan koordinasi tubuh",
            "method": "Latih anak naik tangga sendiri dan melompat dengan kedua kaki bersamaan. Lakukan 2 minggu intensif. Jika tidak ada kemajuan, segera rujuk ke Puskesmas.",
            "duration": "15-20 Menit / Hari",
          };
        } else if (prediksi == "MB") {
          recommendationData.value = {
            "title": "Latihan Menendang & Berlari",
            "goal": "Meningkatkan akurasi gerak tungkai",
            "method": "Anak mulai berkembang. Latih menendang bola kecil ke arah gawang/sasaran. Ajak berlari-lari kecil melintasi rintangan ringan di halaman.",
            "duration": "20 Menit / Hari",
          };
        } else if (prediksi == "BSH") {
          recommendationData.value = {
            "title": "Bermain Keseimbangan Dasar",
            "goal": "Mempertahankan kelincahan",
            "method": "Perkembangan normal. Lanjutkan stimulasi berdiri dengan satu kaki, melompat, dan menari mengikuti irama musik.",
            "duration": "Bebas",
          };
        } else if (prediksi == "BSB") {
          recommendationData.value = {
            "title": "Persiapan Motorik Prasekolah",
            "goal": "Mengenalkan keseimbangan statis",
            "method": "Sangat optimal! Ajak anak berlatih melompat jauh dan coba ajarkan berdiri dengan satu kaki selama lebih dari 2 detik.",
            "duration": "Bebas",
          };
        }
      } else { 
        // Motorik Halus 25-35 Bulan
        if (prediksi == "BB") {
          recommendationData.value = {
            "title": "Intervensi Koordinasi Tangan",
            "goal": "Mengejar kemampuan menyusun dan meniru",
            "method": "Latih anak menyusun 6 balok/kubus dan meniru membuat garis vertikal. Jika dalam 2 minggu anak masih kesulitan, konsultasikan ke dokter/bidan.",
            "duration": "15 Menit / Hari",
          };
        } else if (prediksi == "MB") {
          recommendationData.value = {
            "title": "Melatih Keluwesan Memegang",
            "goal": "Menyiapkan kematangan otot halus jari",
            "method": "Ajari anak mencuci dan mengeringkan tangan sendiri, melepas pakaian, atau mengaduk air/adonan kue bersama ibu.",
            "duration": "Situasional",
          };
        } else if (prediksi == "BSH") {
          recommendationData.value = {
            "title": "Kreativitas Melipat & Menempel",
            "goal": "Mempertahankan keterampilan manipulatif",
            "method": "Perkembangan normal. Lanjutkan stimulasi dengan buku stiker, puzzle 3-4 keping, atau menyusun balok menjadi bentuk kereta/jembatan.",
            "duration": "Bebas",
          };
        } else if (prediksi == "BSB") {
          recommendationData.value = {
            "title": "Menggambar Pola Geometri",
            "goal": "Persiapan menggambar kompleks",
            "method": "Sangat optimal! Mulai ajari anak memegang alat tulis untuk menggambar lingkaran tertutup dan bentuk wajah (orang).",
            "duration": "Bebas",
          };
        }
      }
    }
    // =========================================================
    // RENTANG: 36 - 48 BULAN (3-4 Tahun)
    // =========================================================
    else if (umurBulan >= 36 && umurBulan <= 48) {
      if (kategori == "Kasar" || kategori == "Motorik Kasar") {
        if (prediksi == "BB") {
          recommendationData.value = {
            "title": "Intervensi Intensif 2 Minggu",
            "goal": "Mengejar ketertinggalan kemampuan gerak kasar",
            "method": "Latih anak setiap hari berdiri dengan 1 kaki bergantian sambil berpegangan. Ajak anak melompat sejauh mungkin. Jika 2 minggu tidak ada kemajuan, RUJUK ke Puskesmas.",
            "duration": "15-20 Menit / Hari",
          };
        } else if (prediksi == "MB") {
          recommendationData.value = {
            "title": "Latihan Keseimbangan",
            "goal": "Meningkatkan kemampuan koordinasi tubuh",
            "method": "Terus berikan pujian. Ajak anak bermain 'lampu hijau-merah' untuk melatih keseimbangan berjinjit dan biasakan mengayuh sepeda roda tiga secara rutin.",
            "duration": "20 Menit / Hari",
          };
        } else if (prediksi == "BSH") {
          recommendationData.value = {
            "title": "Lanjutkan Stimulasi Normal",
            "goal": "Mempertahankan kemampuan sesuai usia",
            "method": "Perkembangan normal. Lanjutkan stimulasi melempar tangkap bola besar dan berdiri satu kaki selama 2 detik tanpa bantuan.",
            "duration": "Bebas",
          };
        } else if (prediksi == "BSB") {
          recommendationData.value = {
            "title": "Tantangan Motorik Tingkat Lanjut",
            "goal": "Stimulasi persiapan masuk prasekolah",
            "method": "Sangat optimal! Mulai kenalkan stimulasi usia 4-5 tahun seperti bermain engklek (melompat 1 kaki tanpa jatuh) dan melompat melewati rintangan kecil.",
            "duration": "Bebas",
          };
        }
      } else { 
        // Motorik Halus 36-48 Bulan
        if (prediksi == "BB") {
          recommendationData.value = {
            "title": "Intervensi Halus 2 Minggu",
            "goal": "Mengejar ketertinggalan koordinasi mata-tangan",
            "method": "Berikan kertas & krayon, latih menggambar garis lurus/lingkaran. Latih menyusun 8 balok/kubus. Jika 2 minggu tidak ada kemajuan, konsul ke Tenaga Kesehatan.",
            "duration": "15 Menit / Hari",
          };
        } else if (prediksi == "MB") {
          recommendationData.value = {
            "title": "Aktivitas Keluwesan Jari",
            "goal": "Mengembangkan manipulasi jari",
            "method": "Kemampuan jari sedang berkembang. Dukung dengan bermain puzzle gambar sederhana, atau latih menggunting kertas dan menempel.",
            "duration": "15-20 Menit / Hari",
          };
        } else if (prediksi == "BSH") {
          recommendationData.value = {
            "title": "Lanjutkan Stimulasi Normal",
            "goal": "Mempertahankan kemampuan motorik halus",
            "method": "Perkembangan normal. Lanjutkan stimulasi rutin seperti memotong kertas mengikuti pola lurus, mencocokkan gambar, dan mengelompokkan benda berdasarkan ukuran.",
            "duration": "Bebas",
          };
        } else if (prediksi == "BSB") {
          recommendationData.value = {
            "title": "Persiapan Menulis Dasar",
            "goal": "Mengenalkan kontrol alat tulis presisi",
            "method": "Sangat optimal! Mulai ajari cara memegang pensil yang benar (dynamic tripod), menulis garis silang, dan menggambar bentuk orang lengkap (kepala & badan).",
            "duration": "Bebas",
          };
        }
      }
    }
    // =========================================================
    // RENTANG: 49 - 59 BULAN (4 Tahun)
    // =========================================================
    else if (umurBulan > 48 && umurBulan <= 59) {
      if (kategori == "Kasar" || kategori == "Motorik Kasar") {
        if (prediksi == "BB") {
          recommendationData.value = {
            "title": "Intervensi Keseimbangan",
            "goal": "Mengejar ketertinggalan motorik kasar",
            "method": "Latih anak berdiri 1 kaki bergantian. Pegangi anak saat awal latihan. Minta anak mencoba berdiri seimbang lebih lama tiap harinya. Jika 2 minggu belum ada kemajuan, rujuk ke Puskesmas.",
            "duration": "15 Menit / Hari",
          };
        } else if (prediksi == "MB") {
          recommendationData.value = {
            "title": "Latihan Melompat",
            "goal": "Meningkatkan kekuatan dan koordinasi",
            "method": "Terus latih anak melompat jauh dengan kedua kaki bersamaan. Buat garis batas lompatan di lantai menggunakan selotip atau kapur.",
            "duration": "20 Menit / Hari",
          };
        } else if (prediksi == "BSH") {
          recommendationData.value = {
            "title": "Bermain Aktif",
            "goal": "Mempertahankan kemampuan motorik kasar 4 tahun",
            "method": "Perkembangan normal. Lanjutkan stimulasi seperti bermain lomba balap karung, bermain engklek, lompat tali, dan menari.",
            "duration": "Bebas",
          };
        } else if (prediksi == "BSB") {
          recommendationData.value = {
            "title": "Tantangan Motorik Lanjutan",
            "goal": "Mengenalkan kemampuan usia 5 tahun",
            "method": "Sangat optimal! Mulai ajak anak melompat dengan 1 kaki, melompat jauh, dan berdiri dengan 1 kaki lebih dari 11 detik.",
            "duration": "Bebas",
          };
        }
      } else { 
        // Motorik Halus 4 Tahun
        if (prediksi == "BB") {
          recommendationData.value = {
            "title": "Intervensi Motorik Halus",
            "goal": "Mengejar ketertinggalan koordinasi presisi",
            "method": "Latih anak menggambar garis silang (+) dan lingkaran. Latih menumpuk 8 kubus. Jika gagal setelah 2 minggu, konsultasikan ke tenaga kesehatan.",
            "duration": "15 Menit / Hari",
          };
        } else if (prediksi == "MB") {
          recommendationData.value = {
            "title": "Latihan Menggambar Orang",
            "goal": "Mengembangkan imajinasi visual-motorik",
            "method": "Beri anak kertas dan krayon. Ajari menggambar orang dengan 2-4 bagian tubuh. Beri pujian pada setiap karyanya.",
            "duration": "20 Menit / Hari",
          };
        } else if (prediksi == "BSH") {
          recommendationData.value = {
            "title": "Kreativitas Memotong & Menempel",
            "goal": "Mempertahankan kemampuan 4 tahun",
            "method": "Perkembangan normal. Lanjutkan stimulasi memotong gambar dengan gunting anak dan menempelkannya di kertas.",
            "duration": "Bebas",
          };
        } else if (prediksi == "BSB") {
          recommendationData.value = {
            "title": "Persiapan Menulis Lanjutan",
            "goal": "Mengenalkan kemampuan usia 5 tahun",
            "method": "Sangat optimal! Mulai ajari anak menulis beberapa angka dan huruf, serta menggambar bentuk geometri (persegi, segitiga).",
            "duration": "Bebas",
          };
        }
      }
    }
    // =========================================================
    // RENTANG: 60 - 72 BULAN (5 - 6 Tahun)
    // =========================================================
    else if (umurBulan >= 60 && umurBulan <= 72) {
      if (kategori == "Kasar" || kategori == "Motorik Kasar") {
        if (prediksi == "BB") {
          recommendationData.value = {
            "title": "Intervensi Keseimbangan Tingkat Lanjut",
            "goal": "Mengejar ketertinggalan motorik kasar 5 tahun",
            "method": "Latih anak berdiri 1 kaki selama 11 detik atau lebih. Ajari melompat jauh. Jika tidak ada kemajuan dalam 2 minggu, segera rujuk ke faskes.",
            "duration": "15-20 Menit / Hari",
          };
        } else if (prediksi == "MB") {
          recommendationData.value = {
            "title": "Permainan Kelincahan",
            "goal": "Meningkatkan kelincahan gerak",
            "method": "Terus latih anak bermain halang rintang di sekitar rumah atau taman, serta melompat dengan 1 kaki.",
            "duration": "20 Menit / Hari",
          };
        } else if (prediksi == "BSH") {
          recommendationData.value = {
            "title": "Aktivitas Fisik Kompleks",
            "goal": "Mempertahankan perkembangan motorik kasar 5 tahun",
            "method": "Perkembangan normal. Lanjutkan stimulasi bermain bola (melempar, menangkap, berlari) dan bersepeda.",
            "duration": "Bebas",
          };
        } else if (prediksi == "BSB") {
          recommendationData.value = {
            "title": "Penguatan Fisik",
            "goal": "Mempersiapkan kematangan fisik usia sekolah",
            "method": "Sangat optimal! Dorong anak bermain permainan olahraga yang membutuhkan aturan (seperti sepak bola mini) untuk melatih ketangkasan dan kerja sama.",
            "duration": "Bebas",
          };
        }
      } else { 
        // Motorik Halus 5 - 6 Tahun
        if (prediksi == "BB") {
          recommendationData.value = {
            "title": "Intervensi Motorik Halus Lanjut",
            "goal": "Mengejar ketertinggalan motorik halus prasekolah",
            "method": "Latih anak menggambar orang lengkap (6 bagian tubuh) dan menangkap bola kecil dengan kedua tangan. Jika gagal setelah 2 minggu, rujuk ke faskes.",
            "duration": "15 Menit / Hari",
          };
        } else if (prediksi == "MB") {
          recommendationData.value = {
            "title": "Latihan Bentuk & Huruf",
            "goal": "Meningkatkan kemampuan menulis dasar",
            "method": "Terus latih anak menggambar berbagai bentuk geometri (persegi, segitiga) dan menulis beberapa angka serta huruf.",
            "duration": "20 Menit / Hari",
          };
        } else if (prediksi == "BSH") {
          recommendationData.value = {
            "title": "Proyek Seni Kreatif",
            "goal": "Mempertahankan kemampuan 5 tahun",
            "method": "Perkembangan normal. Lanjutkan stimulasi membuat kerajinan dari tanah liat, pasir, atau plastisin, serta mewarnai.",
            "duration": "Bebas",
          };
        } else if (prediksi == "BSB") {
          recommendationData.value = {
            "title": "Kemandirian Menulis",
            "goal": "Persiapan kematangan menulis untuk SD",
            "method": "Sangat optimal! Latih presisi memegang pensil untuk menulis nama lengkapnya sendiri dan menyalin kalimat sederhana.",
            "duration": "Bebas",
          };
        }
      }
    } 
    // =========================================================
    // JIKA UMUR TIDAK DIKETAHUI / LUAR RENTANG 0-72 BULAN
    // =========================================================
    else {
      recommendationData.value = {
        "title": "Stimulasi Sesuai KIA",
        "goal": "Memenuhi standar SDIDTK",
        "method": "Umur anak ($umurBulan Bulan) di luar jangkauan spesifik. Silakan merujuk pada lembar stimulasi di Buku KIA Kemenkes sesuai kelompok usianya.",
        "duration": "-",
      };
    }
  }

  // ========================================================
  // 3. FUNGSI ERROR HANDLING (FALLBACK DATA)
  // ========================================================
  void _setFallbackData(String errorMsg) {
    if (status.value == "Memproses...") status.value = "Error";
    statusColor.value = Colors.grey;
    recommendationData.value = {
      "title": "Gagal Memuat Data",
      "goal": "-",
      "method": errorMsg,
      "duration": "-",
    };
  }

  // ========================================================
  // 4. NAVIGASI
  // ========================================================
  void goToRecommendation() {
    Get.to(() => const RecommendationView());
  }

  void saveAndFinish() {
    Get.back(); 
    Get.snackbar(
      "Berhasil", 
      "Analisa $status disave ke database.", 
      backgroundColor: Colors.green, 
      colorText: Colors.white,
    );
  }
}