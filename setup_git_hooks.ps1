# Git hook'larını yapılandırmak için PowerShell betiği
# Bu betik, Git pre-commit hook'unu ayarlar

# Proje kök dizini
$projectRoot = $PSScriptRoot

# Git hooks klasörünün yolunu belirleme
$hooksDir = Join-Path -Path $projectRoot -ChildPath ".git\hooks"

# Pre-commit hook dosyasının yolu
$preCommitFile = Join-Path -Path $hooksDir -ChildPath "pre-commit"

# Hook içeriği
$hookContent = @"
#!/bin/sh
# Pre-commit hook to encrypt the words_lib.json file before committing

# Kelime veritabanı dosyaları
ORIGINAL="assets/words_lib.json"
BACKUP="assets/words_lib_original.json"
ENCRYPTED="assets/words_lib_encrypted.json"

echo ">>> Kelime Avı Git Hook: Veritabanı şifreleme kontrolü başlatılıyor..."

# Dosya varsa ve değişikliklere eklenmiş ise işlem yap
if [ -f "\$ORIGINAL" ] && git diff --name-only --cached | grep -q "\$ORIGINAL"; then
    # Dosyanın şifrelenmiş olup olmadığını kontrol et
    if head -c 100 "\$ORIGINAL" | grep -qE "[a-zA-Z]{5,}"; then
        echo ">>> Kelime veritabanı dosyasında muhtemel şifrelenmemiş içerik tespit edildi."
        echo ">>> Şifreleme işlemi başlatılıyor..."

        # Orijinal dosyayı yedekle
        cp "\$ORIGINAL" "\$BACKUP"
        echo ">>> Orijinal veri yedeklendi: \$BACKUP"

        # Şifreleme aracını çalıştır
        dart lib/tools/encrypt_dictionary.dart
        
        if [ -f "\$ENCRYPTED" ]; then
            # Şifrelenmiş dosyayı orijinal konuma taşı
            cp "\$ENCRYPTED" "\$ORIGINAL"
            rm "\$ENCRYPTED"
            echo ">>> Şifreleme başarılı! Şifrelenmiş veri \$ORIGINAL konumuna taşındı."
            
            # Şifrelenmiş dosyayı git stage'e ekle
            git add "\$ORIGINAL"
            echo ">>> Şifrelenmiş dosya commit için hazırlandı."
        else
            echo "!!! HATA: Şifreleme işlemi başarısız oldu!"
            echo "!!! Lütfen 'dart lib/tools/encrypt_dictionary.dart' komutunu manuel olarak çalıştırın."
            exit 1
        fi
    else
        echo ">>> Kelime veritabanı zaten şifrelenmiş görünüyor, işlem atlanıyor."
    fi
else
    echo ">>> words_lib.json dosyası değişmemiş, şifreleme işlemi atlanıyor."
fi

# Normal commit işlemine devam et
exit 0
"@

# Hook dosyasını oluştur
Set-Content -Path $preCommitFile -Value $hookContent -Encoding UTF8

# Dosyayı Unix'te çalıştırılabilir yap (Git Bash için gerekli)
# Git Bash komutunu kullan
Start-Process -FilePath "git" -ArgumentList "update-index --chmod=+x .git/hooks/pre-commit" -Wait -NoNewWindow

Write-Host "Git pre-commit hook başarıyla yapılandırıldı." -ForegroundColor Green
Write-Host "Bu hook, her commit işleminde words_lib.json dosyasını otomatik olarak şifreleyecek." -ForegroundColor Yellow
Write-Host "Script kurulumunu tamamlamak için bu betiği admin yetkisi ile çalıştırın:" -ForegroundColor Cyan
Write-Host "  PowerShell -ExecutionPolicy Bypass -File setup_git_hooks.ps1" -ForegroundColor Cyan