# Panduan Deploy TaskFlow dari Smartphone Android

Panduan ini dibuat agar repository dapat disiapkan lewat browser Android. Beberapa langkah terminal paling mudah dilakukan melalui GitHub Codespaces di browser. Codespaces mungkin meminta metode pembayaran/kuota sesuai kebijakan GitHub akun Anda.

## 1. Buat repository GitHub
1. Buka https://github.com/new dan login.
2. Nama repository: `taskflow-pwa`.
3. Pilih **Private** jika ingin kode tetap privat.
4. Jangan centang README, .gitignore, atau license (agar repository kosong).
5. Tekan **Create repository**.

## 2. Unggah paket ZIP
1. Unduh `taskflow-pwa.zip` dari percakapan ChatGPT ke Android.
2. Pada repository baru, pilih **Add file → Upload files**.
3. Pilih `taskflow-pwa.zip` dari folder Downloads.
4. Tekan **Commit changes**. ZIP ini hanya langkah pemindahan; nanti diekstrak dan dihapus dari repository.

## 3. Ekstrak kode menggunakan Codespaces
1. Pada repository, pilih tombol **Code → Codespaces → Create codespace on main**. Jika opsi ini tidak tersedia, akun/repository mungkin tidak memiliki akses Codespaces; gunakan komputer atau lingkungan coding online lain.
2. Setelah editor Codespaces terbuka, buka **Terminal → New Terminal**.
3. Jalankan perintah berikut satu per satu:

```bash
unzip taskflow-pwa.zip
cp -a taskflow-pwa/. .
rm -rf taskflow-pwa taskflow-pwa.zip
npm install --no-audit --no-fund
npm run build
```

4. Jika `npm run build` gagal, salin pesan error lengkap (jangan sertakan rahasia) ke ChatGPT untuk diperbaiki. Jangan lanjut menyatakan aplikasi siap sebelum build lolos.
5. Jika build berhasil, jalankan:

```bash
git add -A
git commit -m "Add TaskFlow PWA source"
git push origin main
```

Jika Git meminta identitas commit, gunakan nama dan email GitHub Anda pada konfigurasi Git lokal Codespaces.

## 4. Buat database Supabase
1. Buka https://supabase.com dan buat proyek baru. Simpan kata sandi database di pengelola kata sandi pribadi; jangan kirim ke chat.
2. Buka **SQL Editor → New query**.
3. Di Codespaces, buka `supabase/migrations/0001_taskflow.sql`, salin seluruh isinya, lalu tempel ke SQL Editor.
4. Jalankan SQL dan pastikan tidak ada error.
5. Di Supabase, buka **Project Settings → API** (atau bagian API Keys pada dashboard baru) dan salin Project URL serta anon/public key. Jangan salin service-role key ke frontend atau ke percakapan.
6. Buka **Authentication → URL Configuration**. Setelah mendapat URL Vercel, masukkan URL tersebut sebagai Site URL dan tambahkan URL callback yang diminta oleh alur autentikasi.

## 5. Deploy ke Vercel
1. Buka https://vercel.com dan login menggunakan GitHub.
2. Pilih **Add New → Project**, lalu impor repository `taskflow-pwa`.
3. Framework biasanya terdeteksi sebagai Next.js.
4. Pada **Environment Variables**, tambahkan:
   - `NEXT_PUBLIC_SUPABASE_URL` = Project URL dari Supabase.
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY` = anon/public key dari Supabase.
5. Jangan menambahkan service-role key sebagai variabel `NEXT_PUBLIC_`.
6. Tekan **Deploy** dan tunggu hingga deployment selesai.
7. Buka URL `*.vercel.app` yang diberikan Vercel dan uji registrasi, onboarding, tugas, serta login dari sesi browser lain.
8. Tambahkan URL publik tersebut ke Supabase Authentication URL Configuration, lalu redeploy jika ada perubahan environment.

## 6. Catatan penting sebelum dibagikan ke publik
- Repository memiliki GitHub Actions workflow untuk mencoba build saat push. Periksa tab **Actions** untuk hasilnya.
- Uji migrasi SQL di proyek Supabase baru dan uji RLS menggunakan dua akun terpisah.
- Data demo/local browser tidak otomatis dipindahkan ke akun online.
- Sinkronisasi online hanya aktif setelah Supabase dikonfigurasi.
- Fungsi pengingat yang disediakan saat ini membuat notifikasi dalam aplikasi; pengiriman Web Push sebenarnya memerlukan implementasi dan konfigurasi VAPID tambahan.
- Jangan membagikan password, database password, service-role key, atau VAPID private key.
- Deployment baru dianggap berhasil setelah build lulus dan URL publik benar-benar dapat dibuka.
