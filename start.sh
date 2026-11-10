#!/bin/bash
# راه‌انداز یک‌مرحله‌ای ربات سلف‌ساز: نصب + پرسیدن اطلاعات + اجرا (با ری‌استارت خودکار)
cd "$(dirname "$0")" || exit 1

if [ ! -f maker_bot.py ] || [ ! -f mozi.py ]; then
  echo "❌ فایل‌های maker_bot.py و mozi.py باید کنار همین فایل (start.sh) باشن."
  exit 1
fi

SUDO=""
[ "$(id -u)" != "0" ] && command -v sudo >/dev/null 2>&1 && SUDO="sudo"

if [ ! -d venv ]; then
  echo "⏳ نصب پایتون و کتابخانه‌ها (چند دقیقه طول می‌کشه) ..."
  if ! command -v python3 >/dev/null 2>&1; then
    $SUDO apt-get update && $SUDO apt-get install -y python3 python3-pip
  fi
  if ! python3 -m venv venv 2>/dev/null; then
    $SUDO apt-get update && $SUDO apt-get install -y python3-venv
    rm -rf venv
    python3 -m venv venv || { echo "❌ ساخت venv ناموفق بود"; exit 1; }
  fi
  ./venv/bin/pip install telethon jdatetime || { echo "❌ نصب ناموفق بود"; rm -rf venv; exit 1; }
  ./venv/bin/pip install cryptg || true
fi

if [ ! -f config.env ]; then
  echo "اطلاعات رو وارد کن (فقط یک بار پرسیده میشه):"
  read -r -p "1) توکن ربات (از BotFather): " T
  read -r -p "2) api_id ربات سازنده: " AI
  read -r -p "3) api_hash ربات سازنده: " AH
  read -r -p "4) آیدی عددی خودت (از @userinfobot): " AD
  read -r -p "5) یوزرنیم پشتیبانی (مثل @admin، می‌تونی خالی بذاری): " SP
  cat > config.env <<EOF
MAKER_BOT_TOKEN=$T
MAKER_API_ID=$AI
MAKER_API_HASH=$AH
MAKER_ADMINS=$AD
MAKER_SUPPORT=$SP
MAKER_TRIAL_DAYS=3
EOF
  chmod 600 config.env
fi

set -a
. ./config.env
set +a

echo "🚀 ربات در حال اجراست. این پنجره رو نبند (می‌تونی کوچیکش کنی). توقف: Ctrl+C"
while true; do
  ./venv/bin/python maker_bot.py
  echo "ری‌استارت تا ۵ ثانیه‌ی دیگه ..."
  sleep 5
done
