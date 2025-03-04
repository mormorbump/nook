# Nookの設定手順

このドキュメントでは、Nookアプリケーションをローカルで実行するための設定手順を説明します。

## 前提条件

- macOS
- Python 3.11
- fish shell（デフォルトシェルとして設定されていること）

## 1. ポート番号の変更

デフォルトでは、Nookのビューワーサーバーはポート8080で実行されますが、干渉を避けるためにポート11111に変更します。

`nook/functions/viewer/viewer.py`ファイルの最後の行を編集します：

```python
# 変更前
uvicorn.run(app, host="0.0.0.0", port=8080)

# 変更後
uvicorn.run(app, host="0.0.0.0", port=11111)
```

## 2. 仮想環境のセットアップ

Python 3.11を使用して仮想環境を作成し、必要なパッケージをインストールします：

```bash
# 既存の仮想環境を削除（存在する場合）
rm -rf .venv

# Python 3.11で新しい仮想環境を作成
python3.11 -m venv .venv

# 仮想環境をアクティベート（fish shell用）
source .venv/bin/activate.fish

# 依存関係をインストール
pip install -r requirements.txt
pip install -r requirements-dev.txt

# FastAPIとUvicornをインストール
pip install fastapi uvicorn jinja2
```

## 3. 自動起動スクリプトの作成

PCを再起動しても自動でサーバーが立ち上がるように、起動スクリプトを作成します：

### 3.1. run_viewer.shスクリプトの作成

以下の内容で`run_viewer.sh`ファイルを作成します：

```bash
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

# viewer.pyを実行
cd "$PROJECT_DIR"
python "$PROJECT_DIR/nook/functions/viewer/viewer.py"
```

スクリプトに実行権限を付与します：

```bash
chmod +x run_viewer.sh
```

### 3.2. launchdサービスの設定

macOSのlaunchdを使用してサービスを自動起動するように設定します：

以下の内容で`com.user.nook-viewer.plist`ファイルを作成します：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.nook-viewer</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/fish</string>
        <string>-c</string>
        <string>/Users/matsumotokazuki/Desktop/work/nook/run_viewer.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardErrorPath</key>
    <string>/Users/matsumotokazuki/Desktop/work/nook/nook-viewer.log</string>
    <key>StandardOutPath</key>
    <string>/Users/matsumotokazuki/Desktop/work/nook/nook-viewer.log</string>
    <key>WorkingDirectory</key>
    <string>/Users/matsumotokazuki/Desktop/work/nook</string>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
    </dict>
</dict>
</plist>
```

注意: パスは環境に合わせて変更してください。

### 3.3. launchdサービスの登録

作成したplistファイルをLaunchAgentsディレクトリにコピーし、サービスを登録します：

```bash
# LaunchAgentsディレクトリが存在しない場合は作成
mkdir -p ~/Library/LaunchAgents/

# plistファイルをコピー
cp com.user.nook-viewer.plist ~/Library/LaunchAgents/

# サービスを登録
launchctl load ~/Library/LaunchAgents/com.user.nook-viewer.plist
```

## 4. サービスの確認

サービスが正常に登録されているか確認します：

```bash
launchctl list | grep nook-viewer
```

正常に登録されていれば、以下のような出力が表示されます：
```
XXXXX  0  com.user.nook-viewer
```

## 5. アクセス方法

ブラウザで以下のURLにアクセスして、Nookのビューワーを表示できます：

```
http://localhost:11111
```

## 6. データ収集の設定

### 6.1. 手動でのデータ収集

Nookのデータ収集を手動で実行するには、以下のコマンドを実行します：

```bash
source .venv/bin/activate.fish && python main.py
```

注意: データ収集を実行するには、`.env`ファイルに適切なAPIキーが設定されている必要があります。

### 6.2. cronによる定期実行の設定

データ収集を定期的に自動実行するために、cronを設定します。

#### 6.2.1. run_nook.shスクリプトの作成

以下の内容で`run_nook.sh`ファイルを作成します：

```bash
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
```

スクリプトに実行権限を付与します：

```bash
chmod +x run_nook.sh
```

#### 6.2.2. crontabの設定

crontabを編集して、定期実行のスケジュールを設定します：

```bash
crontab -e
```

以下の行を追加して、毎日午前0時にデータ収集を実行するようにします（パスは環境に合わせて変更してください）：

```
0 0 * * * /usr/local/bin/fish -c /Users/matsumotokazuki/Desktop/work/nook/run_nook.sh
```

注意：
- fishシェルを使用してスクリプトを実行するように指定しています
- cronはユーザーの環境変数を継承しないため、絶対パスを使用しています
- 実行時間は必要に応じて調整してください（上記の例では毎日午前0時に実行）

## トラブルシューティング

### サービスが起動しない場合

ログファイルを確認して、エラーの原因を特定します：

```bash
cat nook-viewer.log
```

### ポートが既に使用されている場合

別のプロセスが既にポート11111を使用している場合は、以下のコマンドで確認できます：

```bash
lsof -i :11111
```

競合するプロセスを終了するか、別のポート番号を使用してください。