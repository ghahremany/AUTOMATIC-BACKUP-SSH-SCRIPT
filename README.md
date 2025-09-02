# 🔐 اسکریپت بکاپ پیشرفته
**یک ابزار قدرتمند و قابل اعتماد برای بکاپ خودکار فایل‌ها در لینوکس**

![Bash](https://img.shields.io/badge/bash-4.0+-green.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Platform](https://img.shields.io/badge/platform-Linux-orange.svg)

## 📋 فهرست مطالب
- [ویژگی‌ها](#-ویژگیها)
- [نیازمندی‌ها](#-نیازمندیها)
- [نصب و راه‌اندازی](#-نصب-و-راهاندازی)
- [پیکربندی](#-پیکربندی)
- [استفاده](#-استفاده)
- [برنامه‌ریزی خودکار](#-برنامهریزی-خودکار)
- [مثال‌ها](#-مثالها)
- [عیب‌یابی](#-عیبیابی)
- [مشارکت](#-مشارکت)
- [مجوز](#-مجوز)

## 🚀 ویژگی‌ها

### ✨ ویژگی‌های اصلی
- **بکاپ فشرده**: استفاده از tar و gzip/pigz برای فشرده‌سازی بهینه
- **برچسب زمانی**: نام‌گذاری خودکار فایل‌ها با تاریخ و زمان
- **بررسی فضای دیسک**: کنترل فضای کافی قبل از شروع بکاپ
- **حذف فایل‌های قدیمی**: نگهداری خودکار بکاپ‌ها بر اساس مدت زمان تعیین شده
- **لاگ کامل**: ثبت تمام عملیات با جزئیات کامل

### 🌟 ویژگی‌های پیشرفته
- **آپلود به سرور راه دور**: انتقال خودکار بکاپ‌ها از طریق SCP
- **اعلان‌های دسکتاپ**: نمایش وضعیت عملیات روی صفحه نمایش
- **اعلان ایمیل**: ارسال گزارش عملیات به ایمیل
- **استثناء فایل‌ها**: حذف فایل‌های غیرضروری از بکاپ
- **فشرده‌سازی موازی**: استفاده از تمام هسته‌های پردازنده

### 🛡️ ایمنی و قابلیت اعتماد
- **مدیریت خطا**: پردازش هوشمند خطاها و پاکسازی خودکار
- **بررسی یکپارچگی**: اطمینان از سالمت فایل‌های بکاپ
- **حاشیه امنیت**: محاسبه فضای اضافی برای عملیات ایمن
- **مجوزهای محفوظ**: تنظیم خودکار مجوزهای مناسب برای فایل‌ها

## 📦 نیازمندی‌ها

### ضروری
- `bash` (نسخه 4.0 یا جدیدتر)
- `tar`
- `gzip`
- `find`
- `du`
- `df`

### اختیاری (برای ویژگی‌های اضافی)
```bash
# برای فشرده‌سازی سریع‌تر
sudo apt install pigz

# برای اعلان‌های دسکتاپ
sudo apt install libnotify-bin

# برای ارسال ایمیل
sudo apt install mailutils

# برای آپلود به سرور
sudo apt install openssh-client
```

## 🔧 نصب و راه‌اندازی

### 1. دانلود اسکریپت
```bash
# کلون کردن مخزن
git clone https://github.com/username/advanced-backup-script.git
cd advanced-backup-script

# یا دانلود مستقیم
wget https://raw.githubusercontent.com/username/advanced-backup-script/main/backup.sh
```

### 2. اعطای مجوز اجرا
```bash
chmod +x backup.sh
```

### 3. تست اولیه
```bash
# اجرای تست با دایرکتری کوچک
./backup.sh
```

## ⚙️ پیکربندی

### تنظیمات اصلی
اسکریپت را با ویرایش متغیرهای زیر شخصی‌سازی کنید:

```bash
# مسیرها
SOURCE_DIR="/home/user/Documents"          # پوشه منبع
BACKUP_DIR="/home/user/backups"           # پوشه مقصد بکاپ

# آپلود به سرور (اختیاری)
UPLOAD_TO_SERVER=true                     # فعال/غیرفعال
REMOTE_USER="myuser"                      # نام کاربری سرور
REMOTE_HOST="backup.example.com"          # آدرس سرور
REMOTE_DIR="/remote/backup/path"          # مسیر روی سرور

# ایمیل (اختیاری)
SEND_EMAIL_NOTIFICATION=true             # فعال/غیرفعال
EMAIL_TO="admin@example.com"              # آدرس مقصد

# تنظیمات پیشرفته
RETENTION_DAYS=30                         # نگهداری بکاپ (روز)
MAX_BACKUP_SIZE_GB=10                     # حداکثر اندازه (گیگابایت)
```

### فایل استثناءات
برای حذف فایل‌های خاص از بکاپ، فایل `~/.backup_exclude` را ویرایش کنید:

```
# مثال فایل استثناءات
.git/
node_modules/
*.tmp
*.log
.cache/
__pycache__/
*.pyc
Thumbs.db
.DS_Store
```

## 💻 استفاده

### اجرای ساده
```bash
./backup.sh
```

### بررسی وضعیت
```bash
# مشاهده لاگ‌ها
tail -f /home/user/backups/backup_log.txt

# لیست بکاپ‌ها
ls -lah /home/user/backups/backup_*.tar.gz
```

### نمونه خروجی
```
[2024-03-15 14:30:01] شروع عملیات بکاپ از /home/user/Documents
[2024-03-15 14:30:02] استفاده از pigz برای فشرده‌سازی سریع‌تر
[2024-03-15 14:32:15] بکاپ با موفقیت ایجاد شد: backup_20240315143001.tar.gz (اندازه: 2.3G)
[2024-03-15 14:33:45] آپلود با موفقیت به backup.example.com انجام شد
[2024-03-15 14:33:46] 3 فایل بکاپ قدیمی حذف شد
[2024-03-15 14:33:46] عملیات بکاپ کامل شد. تعداد کل بکاپ‌ها: 7، اندازه کل: 15G
```

## ⏰ برنامه‌ریزی خودکار

### استفاده از Cron
```bash
# ویرایش جدول cron
crontab -e

# اضافه کردن برنامه‌ها:

# بکاپ روزانه ساعت 2 شب
0 2 * * * /path/to/backup.sh

# بکاپ هفتگی یکشنبه‌ها ساعت 3 شب
0 3 * * 0 /path/to/backup.sh

# بکاپ ماهانه روز اول هر ماه
0 1 1 * * /path/to/backup.sh
```

### استفاده از Systemd Timer
```bash
# ایجاد فایل سرویس
sudo nano /etc/systemd/system/backup.service
```

```ini
[Unit]
Description=Advanced Backup Script
Wants=backup.timer

[Service]
Type=oneshot
ExecStart=/path/to/backup.sh
User=yourusername

[Install]
WantedBy=multi-user.target
```

```bash
# ایجاد فایل تایمر
sudo nano /etc/systemd/system/backup.timer
```

```ini
[Unit]
Description=Run backup script daily
Requires=backup.service

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
```

```bash
# فعال‌سازی
sudo systemctl enable backup.timer
sudo systemctl start backup.timer
```

## 📚 مثال‌ها

### مثال 1: بکاپ ساده
```bash
#!/bin/bash
SOURCE_DIR="/home/user/Documents"
BACKUP_DIR="/home/user/backups"
UPLOAD_TO_SERVER=false
SEND_EMAIL_NOTIFICATION=false
./backup.sh
```

### مثال 2: بکاپ کامل با آپلود
```bash
#!/bin/bash
SOURCE_DIR="/var/www"
BACKUP_DIR="/backup/web"
UPLOAD_TO_SERVER=true
REMOTE_USER="backup"
REMOTE_HOST="storage.company.com"
REMOTE_DIR="/backups/web"
SEND_EMAIL_NOTIFICATION=true
EMAIL_TO="admin@company.com"
./backup.sh
```

### مثال 3: بکاپ چندگانه
```bash
#!/bin/bash
# بکاپ چندین دایرکتری

directories=("/home/user/Documents" "/var/www" "/etc")

for dir in "${directories[@]}"; do
    SOURCE_DIR="$dir"
    BACKUP_DIR="/backup$(dirname $dir)"
    ./backup.sh
done
```

## 🔍 عیب‌یابی

### مشکلات رایج

**❌ خطای "فضای کافی نیست"**
```bash
# بررسی فضای دیسک
df -h /path/to/backup

# پاکسازی فایل‌های قدیمی
find /path/to/backup -name "backup_*.tar.gz" -mtime +7 -delete
```

**❌ خطای اتصال به سرور**
```bash
# تست اتصال SSH
ssh user@server.com "echo 'اتصال موفق'"

# بررسی کلیدهای SSH
ssh-copy-id user@server.com
```

**❌ عدم ارسال اعلان‌ها**
```bash
# نصب پکیج‌های مورد نیاز
sudo apt install libnotify-bin mailutils

# تست اعلان دسکتاپ
notify-send "تست" "پیام آزمایشی"

# تست ایمیل
echo "تست" | mail -s "آزمایش" user@example.com
```

### لاگ‌های مفید
```bash
# مشاهده آخرین لاگ‌ها
tail -n 50 /path/to/backup_log.txt

# جستجو در لاگ‌ها
grep "خطا\|ERROR" /path/to/backup_log.txt

# مانیتورینگ زنده
tail -f /path/to/backup_log.txt
```

### حالت دیباگ
```bash
# اجرا با جزئیات بیشتر
bash -x backup.sh

# یا اضافه کردن به ابتدای اسکریپت
set -x  # فعال‌سازی حالت debug
```

## 🤝 مشارکت

مشارکت شما در بهبود این اسکریپت خوشامد است!

### مراحل مشارکت
1. **Fork** کردن مخزن
2. ایجاد **branch** جدید برای ویژگی (`git checkout -b feature/amazing-feature`)
3. **Commit** کردن تغییرات (`git commit -m 'Add amazing feature'`)
4. **Push** کردن به branch (`git push origin feature/amazing-feature`)
5. ایجاد **Pull Request**

### راهنمای توسعه
- از کدنویسی تمیز و قابل خواندن استفاده کنید
- کامنت‌های فارسی برای توضیح کد اضافه کنید
- تست‌های مناسب برای ویژگی‌های جدید بنویسید
- مستندات را به‌روزرسانی کنید

### گزارش مشکلات
برای گزارش باگ یا درخواست ویژگی، از [Issues](https://github.com/ghahremany/AUTOMATIC-BACKUP-SSH-SCRIPT/issues) استفاده کنید.

## 📄 مجوز

این پروژه تحت مجوز MIT منتشر شده است. برای جزئیات بیشتر فایل [LICENSE](LICENSE) را مطالعه کنید.

---

## 🌟 ستاره بدهید!

اگر این اسکریپت برای شما مفید بود، لطفاً با دادن ⭐ از پروژه حمایت کنید!

---

<div align="center">

**ساخته شده با ❤️ برای جامعه متن‌باز**

[🏠 صفحه اصلی]([t](https://github.com/ghahremany/AUTOMATIC-BACKUP-SSH-SCRIPT)) | 
[📖 مستندات](https://github.com/ghahremany/AUTOMATIC-BACKUP-SSH-SCRIPT/wiki) | 
[🐛 گزارش مشکل](https://github.com/ghahremany/AUTOMATIC-BACKUP-SSH-SCRIPT/issues) | 
[💬 بحث و گفتگو](https://github.com/ghahremany/AUTOMATIC-BACKUP-SSH-SCRIPT/discussions)

</div>
