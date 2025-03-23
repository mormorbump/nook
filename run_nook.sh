#!/usr/local/bin/fish

# 実行ログを記録
echo "run_nook.sh started at "(date)" by cron" >> "$HOME/Desktop/work/nook/nook_cron.log"

# プロジェクトディレクトリを設定
set PROJECT_DIR (dirname (status filename))
echo "PROJECT_DIR: $PROJECT_DIR" >> "$HOME/Desktop/work/nook/nook_cron.log"

# 仮想環境をアクティベート
echo "Activating virtual environment..." >> "$HOME/Desktop/work/nook/nook_cron.log"
source "$PROJECT_DIR/.venv/bin/activate.fish"

# 環境変数を読み込む
if test -f "$PROJECT_DIR/.env"
    echo "Loading environment variables from .env..." >> "$HOME/Desktop/work/nook/nook_cron.log"
    for line in (cat "$PROJECT_DIR/.env" | grep -v '^#')
        set -gx (echo $line | cut -d= -f1) (echo $line | cut -d= -f2-)
    end
else
    echo "ERROR: .env file not found!" >> "$HOME/Desktop/work/nook/nook_cron.log"
end

# main.pyを実行してデータを収集
echo "Changing directory to $PROJECT_DIR..." >> "$HOME/Desktop/work/nook/nook_cron.log"
cd "$PROJECT_DIR"
echo "Running main.py..." >> "$HOME/Desktop/work/nook/nook_cron.log"
python3 "$PROJECT_DIR/main.py"
echo "run_nook.sh completed at "(date) >> "$HOME/Desktop/work/nook/nook_cron.log"
echo "----------------------------------------" >> "$HOME/Desktop/work/nook/nook_cron.log"