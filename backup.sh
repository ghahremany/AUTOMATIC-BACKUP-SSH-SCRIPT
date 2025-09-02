#!/bin/bash

# -------- تنظیمات --------
SOURCE_DIR="/home/user/Documents"
BACKUP_DIR="/home/user/backups"
TIMESTAMP=$(date +'%Y%m%d%H%M%S')
BACKUP_FILE="$BACKUP_DIR/backup_$TIMESTAMP.tar.gz"
LOG_FILE="$BACKUP_DIR/backup_log.txt"

# -------- آپلود (اختیاری) --------
UPLOAD_TO_SERVER=false
REMOTE_USER="user"
REMOTE_HOST="example.com"
REMOTE_DIR="/remote/backup/path"

# -------- ایمیل نوتیفیکیشن (اختیاری) --------
SEND_EMAIL_NOTIFICATION=false
EMAIL_TO="you@example.com"
EMAIL_SUBJECT_SUCCESS="Backup Successful"
EMAIL_SUBJECT_FAIL="Backup Failed"

# -------- تنظیمات اضافی --------
RETENTION_DAYS=30
MAX_BACKUP_SIZE_GB=10
EXCLUDE_FILE="$HOME/.backup_exclude"

# -------- توابع کمکی --------
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

send_notification() {
    local title="$1"
    local message="$2"
    local urgency="${3:-normal}"
    
    if command -v notify-send >/dev/null; then
        notify-send -u "$urgency" "$title" "$message"
    fi
}

send_email() {
    local subject="$1"
    local message="$2"
    
    if [ "$SEND_EMAIL_NOTIFICATION" = true ] && command -v mail >/dev/null; then
        echo "$message" | mail -s "$subject" "$EMAIL_TO"
    fi
}

cleanup_on_error() {
    log_message "خطا: عملیات متوقف شد. در حال پاکسازی..."
    [ -f "$BACKUP_FILE" ] && rm -f "$BACKUP_FILE"
    send_notification "Backup Failed" "عملیات بکاپ با خطا متوقف شد" "critical"
    send_email "$EMAIL_SUBJECT_FAIL" "Backup operation failed and was terminated."
    exit 1
}

# تنظیم تله برای خطاها
trap cleanup_on_error ERR
set -e  # خروج در صورت بروز خطا

# -------- بررسی وجود دایرکتری مبدأ --------
if [ ! -d "$SOURCE_DIR" ]; then
    log_message "خطا: دایرکتری مبدأ وجود ندارد: $SOURCE_DIR"
    send_notification "Backup Failed" "دایرکتری مبدأ یافت نشد" "critical"
    send_email "$EMAIL_SUBJECT_FAIL" "Source directory not found: $SOURCE_DIR"
    exit 1
fi

# -------- ساخت پوشه بکاپ --------
if ! mkdir -p "$BACKUP_DIR"; then
    log_message "خطا: نمی‌توان پوشه بکاپ را ایجاد کرد"
    exit 1
fi

log_message "شروع عملیات بکاپ از $SOURCE_DIR"

# -------- بررسی فضای دیسک با حاشیه امنیت --------
REQUIRED_SPACE=$(du -s "$SOURCE_DIR" | awk '{print $1}')
AVAILABLE_SPACE=$(df "$BACKUP_DIR" | tail -1 | awk '{print $4}')
SAFETY_MARGIN=$((REQUIRED_SPACE * 20 / 100))  # 20% حاشیه امنیت

if [ "$AVAILABLE_SPACE" -lt $((REQUIRED_SPACE + SAFETY_MARGIN)) ]; then
    log_message "خطا: فضای دیسک کافی نیست. مورد نیاز: $((REQUIRED_SPACE + SAFETY_MARGIN))KB، موجود: ${AVAILABLE_SPACE}KB"
    send_notification "Backup Failed" "فضای دیسک کافی نیست" "critical"
    send_email "$EMAIL_SUBJECT_FAIL" "Not enough disk space for backup operation"
    exit 1
fi

# -------- بررسی حداکثر اندازه بکاپ --------
SOURCE_SIZE_GB=$(du -sh "$SOURCE_DIR" | cut -f1 | sed 's/G//')
if [[ "$SOURCE_SIZE_GB" =~ ^[0-9]+$ ]] && [ "$SOURCE_SIZE_GB" -gt "$MAX_BACKUP_SIZE_GB" ]; then
    log_message "هشدار: اندازه دایرکتری مبدأ (${SOURCE_SIZE_GB}GB) از حداکثر مجاز (${MAX_BACKUP_SIZE_GB}GB) بیشتر است"
fi

# -------- ایجاد فایل استثناءات در صورت عدم وجود --------
if [ ! -f "$EXCLUDE_FILE" ]; then
    cat > "$EXCLUDE_FILE" << EOF
# فایل‌هایی که باید از بکاپ حذف شوند
.git/
node_modules/
*.tmp
*.log
.cache/
EOF
    log_message "فایل استثناءات ایجاد شد: $EXCLUDE_FILE"
fi

# -------- ایجاد فایل بکاپ --------
log_message "در حال ایجاد فایل بکاپ..."

# انتخاب روش فشرده‌سازی
if command -v pigz >/dev/null; then
    log_message "استفاده از pigz برای فشرده‌سازی سریع‌تر"
    tar --exclude-from="$EXCLUDE_FILE" -cf - -C "$SOURCE_DIR" . | pigz -p "$(nproc)" > "$BACKUP_FILE"
else
    log_message "استفاده از gzip برای فشرده‌سازی"
    tar --exclude-from="$EXCLUDE_FILE" -czf "$BACKUP_FILE" -C "$SOURCE_DIR" .
fi

# -------- بررسی موفقیت عملیات و محاسبه اندازه --------
if [ -f "$BACKUP_FILE" ] && [ -s "$BACKUP_FILE" ]; then
    chmod 600 "$BACKUP_FILE"
    BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    log_message "بکاپ با موفقیت ایجاد شد: $BACKUP_FILE (اندازه: $BACKUP_SIZE)"
    send_notification "Backup Successful" "بکاپ با موفقیت ایجاد شد: $BACKUP_SIZE"
    send_email "$EMAIL_SUBJECT_SUCCESS" "Backup completed successfully: $BACKUP_FILE (Size: $BACKUP_SIZE)"
else
    log_message "خطا: فایل بکاپ ایجاد نشد یا خالی است"
    exit 1
fi

# -------- آپلود به سرور (اختیاری) --------
if [ "$UPLOAD_TO_SERVER" = true ]; then
    log_message "شروع آپلود به سرور..."
    
    # بررسی اتصال به سرور
    if ! ssh -o ConnectTimeout=10 -o BatchMode=yes "$REMOTE_USER@$REMOTE_HOST" exit 2>/dev/null; then
        log_message "خطا: عدم امکان اتصال به سرور $REMOTE_HOST"
        send_notification "Upload Failed" "عدم امکان اتصال به سرور"
        send_email "$EMAIL_SUBJECT_FAIL" "Cannot connect to remote server: $REMOTE_HOST"
    else
        # آپلود با نمایش پیشرفت
        if scp -v "$BACKUP_FILE" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR/"; then
            log_message "آپلود با موفقیت به $REMOTE_HOST انجام شد"
            send_notification "Upload Successful" "بکاپ با موفقیت آپلود شد"
            send_email "$EMAIL_SUBJECT_SUCCESS" "Backup successfully uploaded to $REMOTE_HOST"
        else
            log_message "خطا: آپلود به $REMOTE_HOST ناموفق"
            send_notification "Upload Failed" "آپلود ناموفق بود" "critical"
            send_email "$EMAIL_SUBJECT_FAIL" "Failed to upload backup to $REMOTE_HOST"
        fi
    fi
fi

# -------- حذف بکاپ‌های قدیمی --------
log_message "حذف بکاپ‌های قدیمی‌تر از $RETENTION_DAYS روز..."
DELETED_COUNT=$(find "$BACKUP_DIR" -type f -name "backup_*.tar.gz" -mtime +$RETENTION_DAYS -print0 | xargs -0 rm -f | wc -l)
if [ "$DELETED_COUNT" -gt 0 ]; then
    log_message "$DELETED_COUNT فایل بکاپ قدیمی حذف شد"
fi

# -------- گزارش نهایی --------
TOTAL_BACKUPS=$(find "$BACKUP_DIR" -type f -name "backup_*.tar.gz" | wc -l)
TOTAL_SIZE=$(du -sh "$BACKUP_DIR" | cut -f1)
log_message "عملیات بکاپ کامل شد. تعداد کل بکاپ‌ها: $TOTAL_BACKUPS، اندازه کل: $TOTAL_SIZE"

# غیرفعال کردن تله خطا
set +e
trap - ERR

exit 0
