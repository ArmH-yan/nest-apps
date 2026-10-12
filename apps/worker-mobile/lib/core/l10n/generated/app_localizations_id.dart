// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'NEST Worker';

  @override
  String get retry => 'Coba lagi';

  @override
  String get cancel => 'Batal';

  @override
  String get close => 'Tutup';

  @override
  String get ok => 'OK';

  @override
  String get open => 'Buka';

  @override
  String get tryAgain => 'Coba lagi';

  @override
  String get fieldRequired => 'Wajib diisi';

  @override
  String get navTasks => 'Tugas';

  @override
  String get navWork => 'Kerja';

  @override
  String get navHistory => 'Riwayat';

  @override
  String get navProfile => 'Profil';

  @override
  String get loginSubtitle => 'Masuk untuk melihat tugas Anda';

  @override
  String get phoneLabel => 'Nomor telepon';

  @override
  String get passwordLabel => 'Kata sandi';

  @override
  String get loginButton => 'Masuk';

  @override
  String get forgotPassword => 'Lupa kata sandi?';

  @override
  String get forgotPasswordBody =>
      'Hubungi manajer Anda untuk mengatur ulang kata sandi.';

  @override
  String get changePasswordTitle => 'Buat kata sandi baru';

  @override
  String get changePasswordBody =>
      'Demi keamanan Anda, buat kata sandi baru sebelum mulai.';

  @override
  String get currentPassword => 'Kata sandi saat ini';

  @override
  String get newPassword => 'Kata sandi baru';

  @override
  String get repeatPassword => 'Ulangi kata sandi baru';

  @override
  String get passwordsDoNotMatch => 'Kata sandi tidak cocok';

  @override
  String get passwordTooShort => 'Minimal 8 karakter';

  @override
  String get savePassword => 'Simpan kata sandi';

  @override
  String get myTasks => 'Tugas Saya';

  @override
  String get sectionToday => 'HARI INI';

  @override
  String get sectionUpcoming => 'MENDATANG';

  @override
  String get sectionYesterday => 'KEMARIN';

  @override
  String get emptyTasksTitle => 'Belum ada tugas';

  @override
  String get emptyTasksBody =>
      'Tugas baru dari manajer Anda akan muncul di sini.';

  @override
  String lastUpdated(String time) {
    return 'Terakhir diperbarui $time';
  }

  @override
  String activeTaskBanner(String title) {
    return 'Anda sedang mengerjakan: $title';
  }

  @override
  String get leadBadge => 'KETUA';

  @override
  String get today => 'Hari ini';

  @override
  String get tomorrow => 'Besok';

  @override
  String get statusUpcoming => 'MENDATANG';

  @override
  String get statusToday => 'SIAP DIMULAI';

  @override
  String get statusInProgress => 'SEDANG BEKERJA';

  @override
  String get statusOnBreak => 'ISTIRAHAT';

  @override
  String get statusWaiting => 'MENUNGGU DIKIRIM';

  @override
  String get statusSyncFailed => 'GAGAL SINKRON';

  @override
  String get statusCompleted => 'SELESAI';

  @override
  String get statusCancelled => 'DIBATALKAN';

  @override
  String get jobSurvey => 'Survei lokasi';

  @override
  String get jobInstallation => 'Pemasangan';

  @override
  String get jobInspection => 'Inspeksi';

  @override
  String get jobMaintenance => 'Perawatan';

  @override
  String get jobDismantling => 'Pembongkaran';

  @override
  String get taskInformation => 'Informasi tugas';

  @override
  String get project => 'Proyek';

  @override
  String get customer => 'Pelanggan';

  @override
  String get instructions => 'Instruksi';

  @override
  String get scheduledDate => 'Tanggal';

  @override
  String get scheduledTime => 'Waktu';

  @override
  String get yourRole => 'Peran Anda';

  @override
  String get roleLead => 'Ketua tim';

  @override
  String get roleMember => 'Anggota tim';

  @override
  String get crew => 'Tim';

  @override
  String get siteContact => 'Kontak lokasi';

  @override
  String get workLocation => 'Lokasi kerja';

  @override
  String get address => 'Alamat';

  @override
  String get accessNotes => 'Catatan akses';

  @override
  String get coordinates => 'Koordinat';

  @override
  String get workRadius => 'Radius kerja';

  @override
  String metersValue(String meters) {
    return '$meters m';
  }

  @override
  String get currentDistance => 'Jarak Anda';

  @override
  String get navigate => 'Navigasi';

  @override
  String get verifyMyLocation => 'Verifikasi Lokasi Saya';

  @override
  String get openWorkScreen => 'Buka layar kerja';

  @override
  String get taskNotFound => 'Tugas ini sudah tidak tersedia.';

  @override
  String get errNotScheduledToday => 'Tugas ini tidak dijadwalkan hari ini.';

  @override
  String errTooEarly(String time) {
    return 'Anda bisa memulai tugas ini mulai pukul $time.';
  }

  @override
  String get errAnotherTaskActive =>
      'Selesaikan dulu tugas Anda yang sedang berjalan.';

  @override
  String get errAlreadyCompleted => 'Tugas ini sudah selesai.';

  @override
  String get errCancelled => 'Tugas ini dibatalkan oleh manajer Anda.';

  @override
  String get errLocationNotVerified =>
      'Verifikasi lokasi Anda terlebih dahulu.';

  @override
  String get errInvalidAction => 'Tindakan ini tidak tersedia saat ini.';

  @override
  String get verifyTitle => 'Pemeriksaan lokasi';

  @override
  String get checkingLocation => 'Memeriksa lokasi Anda…';

  @override
  String get locationVerified => 'Lokasi Terverifikasi';

  @override
  String get atWorkLocation => 'Anda berada di lokasi kerja.';

  @override
  String get distance => 'Jarak';

  @override
  String get gpsAccuracy => 'Akurasi GPS';

  @override
  String get outsideTitle => 'Anda berada di luar area kerja';

  @override
  String get outsideBody =>
      'Mendekatlah ke lokasi kerja yang ditentukan untuk mulai bekerja.';

  @override
  String allowedRadius(String meters) {
    return 'Diizinkan: $meters m';
  }

  @override
  String get lowAccuracyTitle => 'Sinyal GPS lemah';

  @override
  String get lowAccuracyBody => 'Pindah ke area terbuka dan coba lagi.';

  @override
  String get permissionDeniedTitle =>
      'Izin lokasi diperlukan untuk mulai bekerja.';

  @override
  String get allowLocation => 'Izinkan lokasi';

  @override
  String get openSettings => 'Buka pengaturan';

  @override
  String get servicesDisabledTitle => 'Layanan lokasi dinonaktifkan.';

  @override
  String get openLocationSettings => 'Buka pengaturan lokasi';

  @override
  String get locationTimeout => 'Tidak dapat menemukan lokasi Anda. Coba lagi.';

  @override
  String get startWorkingTimer => 'Mulai Timer Kerja';

  @override
  String get noActiveTaskTitle => 'Tidak ada tugas aktif';

  @override
  String get noActiveTaskBody => 'Mulai tugas dari Tugas Saya.';

  @override
  String get workTime => 'WAKTU KERJA';

  @override
  String get breakTime => 'WAKTU ISTIRAHAT';

  @override
  String get startedLabel => 'DIMULAI';

  @override
  String get locationLabel => 'LOKASI';

  @override
  String get verified => 'Terverifikasi';

  @override
  String get stopAndStartBreak => 'BERHENTI & ISTIRAHAT';

  @override
  String get resumeWorking => 'LANJUTKAN KERJA';

  @override
  String get finishTask => 'SELESAIKAN TUGAS';

  @override
  String get tapToBreak => 'Ketuk untuk istirahat';

  @override
  String get tapToResume => 'Ketuk untuk lanjut bekerja';

  @override
  String get earningsTitle => 'Bulan ini';

  @override
  String get worksDoneThisMonth => 'Pekerjaan selesai (disetujui)';

  @override
  String get earnedThisMonth => 'Penghasilan (disetujui)';

  @override
  String get earningsApprovedOnly =>
      'Hanya tugas yang disetujui manajer yang dihitung. Tugas yang dikirim akan ditambahkan di sini setelah disetujui.';

  @override
  String get earningsUnavailable =>
      'Belum dimuat. Tarik ke bawah di Tugas Saya untuk memperbarui saat online.';

  @override
  String get finishConfirmTitle => 'Selesaikan tugas ini?';

  @override
  String get finishConfirmBody =>
      'Berikutnya Anda akan menambahkan foto dan mengirim. Timer tetap berjalan sampai Anda mengirim.';

  @override
  String get finish => 'Selesai';

  @override
  String get syncAllSent => 'Semua perubahan terkirim';

  @override
  String syncPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count item menunggu dikirim',
    );
    return '$_temp0';
  }

  @override
  String get syncFailedBanner => 'Pengiriman gagal';

  @override
  String get syncOffline => 'Offline — pekerjaan Anda tersimpan di ponsel ini';

  @override
  String get syncing => 'Mengirim…';

  @override
  String get syncNow => 'Sinkron sekarang';

  @override
  String get completeTask => 'Selesaikan Tugas';

  @override
  String get summary => 'Ringkasan';

  @override
  String get taskLabel => 'Tugas';

  @override
  String get totalDuration => 'Total durasi';

  @override
  String get completionTime => 'Waktu selesai';

  @override
  String get materialsTitle => 'Material';

  @override
  String get materialsInstalledHint => 'Apa yang Anda pasang?';

  @override
  String get materialsDismantleHint =>
      'Masukkan apa yang Anda bawa kembali. Selisihnya dicatat sebagai hilang.';

  @override
  String get materialsInspectionHint => 'Catat barang yang rusak, jika ada.';

  @override
  String get addMaterial => 'Tambah material';

  @override
  String get item => 'Barang';

  @override
  String get quantity => 'Jumlah';

  @override
  String expectedQuantity(String quantity) {
    return 'Diharapkan: $quantity';
  }

  @override
  String get materialsRequired => 'Tambahkan minimal satu material.';

  @override
  String get materialsUnavailable =>
      'Daftar material tidak tersedia saat offline. Coba lagi saat online.';

  @override
  String get checklistComingSoon =>
      'Daftar periksa inspeksi akan ditambahkan di versi berikutnya.';

  @override
  String get photosTitle => 'Foto Pekerjaan Selesai';

  @override
  String get takePhoto => 'Ambil Foto';

  @override
  String get chooseFromGallery => 'Pilih dari Galeri';

  @override
  String photosRequired(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tambahkan minimal $count foto.',
    );
    return '$_temp0';
  }

  @override
  String get uploadFailed => 'Unggahan gagal';

  @override
  String get removePhoto => 'Hapus foto';

  @override
  String get commentTitle => 'Komentar (opsional)';

  @override
  String get commentHint => 'Hal yang perlu diketahui manajer Anda';

  @override
  String get submitTask => 'Kirim Tugas';

  @override
  String get submitConfirmTitle => 'Kirim Tugas?';

  @override
  String get photos => 'Foto';

  @override
  String get materials => 'Material';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count item',
    );
    return '$_temp0';
  }

  @override
  String get movementInstalled => 'Dipasang';

  @override
  String get movementRetrieved => 'Diambil kembali';

  @override
  String get movementDamaged => 'Rusak';

  @override
  String get movementLost => 'Hilang';

  @override
  String get movementAdjustment => 'Penyesuaian';

  @override
  String get submittedTitle => 'Tugas terkirim ✓';

  @override
  String get submittedBody => 'Manajer Anda sekarang dapat melihatnya.';

  @override
  String get savedOfflineTitle => 'Tugas tersimpan';

  @override
  String get savedOfflineBody => 'Akan dikirim otomatis saat Anda online.';

  @override
  String get goToHistory => 'Ke Riwayat';

  @override
  String get historyTitle => 'Riwayat';

  @override
  String get historyEmptyTitle => 'Belum ada tugas selesai';

  @override
  String get historyEmptyBody => 'Tugas yang dikirim muncul di sini.';

  @override
  String workingDuration(String duration) {
    return '$duration bekerja';
  }

  @override
  String completedAtTime(String time) {
    return 'Selesai $time';
  }

  @override
  String get workAndBreaks => 'Kerja dan istirahat';

  @override
  String get sessionWork => 'Kerja';

  @override
  String get sessionBreak => 'Istirahat';

  @override
  String get completionLocation => 'Lokasi penyelesaian';

  @override
  String get comment => 'Komentar';

  @override
  String get notRecorded => 'Tidak tercatat';

  @override
  String hoursMinutes(int hours, int minutes) {
    return '${hours}j ${minutes}m';
  }

  @override
  String get profileTitle => 'Profil';

  @override
  String get employeeId => 'ID Karyawan';

  @override
  String get phone => 'Telepon';

  @override
  String get company => 'Perusahaan';

  @override
  String get settings => 'Pengaturan';

  @override
  String get notifications => 'Notifikasi';

  @override
  String get locationPermission => 'Izin lokasi';

  @override
  String get cameraPermission => 'Izin kamera';

  @override
  String get manageInSettings => 'Atur di pengaturan sistem';

  @override
  String get language => 'Bahasa';

  @override
  String get languageDevice => 'Bahasa perangkat';

  @override
  String get appVersion => 'Versi aplikasi';

  @override
  String get unsyncedItems => 'Item belum tersinkron';

  @override
  String get logout => 'Keluar';

  @override
  String get logoutConfirmTitle => 'Keluar?';

  @override
  String logoutUnsyncedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Anda punya $count item yang belum tersinkron.',
    );
    return '$_temp0 Item tetap di ponsel ini dan dikirim setelah Anda masuk lagi.';
  }

  @override
  String get developer => 'Pengembang (build dev)';

  @override
  String get gpsSource => 'Sumber GPS';

  @override
  String get simulateOffline => 'Simulasikan tanpa internet';

  @override
  String get failNextUpload => 'Gagalkan unggahan foto berikutnya';

  @override
  String get rejectNextCompletion => 'Tolak pengiriman berikutnya (409)';

  @override
  String get notificationsEmpty => 'Tidak ada notifikasi';

  @override
  String get errorNoInternet => 'Tidak ada koneksi internet.';

  @override
  String get errorOfflineCached =>
      'Anda sedang offline. Menampilkan tugas tersimpan.';

  @override
  String get errorServer => 'Terjadi kesalahan di server.';

  @override
  String get errorGeneric => 'Terjadi kesalahan. Coba lagi.';

  @override
  String get errorInvalidCredentials => 'Nomor telepon atau kata sandi salah.';

  @override
  String requestId(String id) {
    return 'ID permintaan: $id';
  }
}
