#!/usr/bin/env fish

# プロジェクトディレクトリを設定
set PROJECT_DIR (dirname (status filename))

# 仮想環境をアクティベート
source "$PROJECT_DIR/.venv/bin/activate.fish"

# 環境変数を読み込む
if test -f "$PROJECT_DIR/.env"
    for line in (cat "$PROJECT_DIR/.env" | grep -v '^#')
        set -gx (echo $line | cut -d= -f1) (echo $line | cut -d= -f2-)
    end
end

# main.pyを実行してデータを収集
cd "$PROJECT_DIR"
python "$PROJECT_DIR/main.py"