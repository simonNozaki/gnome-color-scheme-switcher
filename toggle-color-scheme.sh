#!/bin/bash
#
# gnomeのデスクトップテーマをトグルする 実行はcronでスケジュールされる

# cronからGNOMEを操作する場合、失われる環境変数があるので手動で定義する
# @see https://mackro.blog.jp/archives/22815337.html?ref=head_btn_prev&id=8145773
export DISPLAY=:0
export XDG_RUNTIME_DIR=/run/user/1000

# @param message
function log() {
  local message=$1
  local now
  now=$(date '+%Y-%m-%d %T.%3N')
  pid=$$
  echo "[${now} #${pid}] ${message}"
}

function toggle_scheme() {
  local mode=$1
  prefer_mode="prefer-${mode}"

  current_mode=$(gsettings get org.gnome.desktop.interface color-scheme)
  log "Current scheme is ${current_mode}"

  gsettings set org.gnome.desktop.interface color-scheme "${prefer_mode}"
  log "Toggled to ${mode}"
}

# 時間帯判定: 18:00~翌7:00はdarkである
# @return 'night' | 'daytime'
function period_of_time() {
  today=$(date '+%Y-%m-%d')
  night_end_timestamp=$(date '+%s' --date "${today} 07:00:00")
  night_start_timestamp=$(date '+%s' --date "${today} 18:00:00")

  now=$(date '+%s')
  # 範囲の両端と現在時刻をUnixタイムスタンプで比較
  if [[ $night_end_timestamp > $now || $night_start_timestamp < $now ]]; then
    echo night
  else
    echo daytime
  fi
}

log 'Start toggleing desktop'
period=$(period_of_time)
log "Now is ${period}"

if [[ $period = "night" ]]; then
  toggle_scheme dark
else
  toggle_scheme light
fi
log 'Toggleing desktop scheme done'
