#!/usr/bin/env bash
#
# new-doc.sh — 新しい静的ドキュメント（雛形）を追加するスクリプト
#
# 既存の cloudflare-guide と同じ構造・同じテイスト（css/style.css を共有）の
# サンプル文書を生成し、index.html の目次にも自動で登録します。
#
# 使い方:
#   scripts/new-doc.sh <slug> "<タイトル>" ["<説明>"]
#
# 例:
#   scripts/new-doc.sh release-notes "リリースノート" "v1.0 の変更点まとめ"
#     → release-notes.html を作成し、目次に追加します。
#
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INDEX="$ROOT/index.html"

slug="${1:-}"
title="${2:-}"
desc="${3:-静的ドキュメントのサンプルです。}"

if [ -z "$slug" ] || [ -z "$title" ]; then
  echo "使い方: $0 <slug> \"<タイトル>\" [\"<説明>\"]" >&2
  echo "  例:   $0 release-notes \"リリースノート\" \"v1.0 の変更点まとめ\"" >&2
  exit 1
fi

# slug は英数字・ハイフン・アンダースコアのみ（ファイル名 / URL になるため）
case "$slug" in
  *[!a-zA-Z0-9_-]*|"")
    echo "エラー: slug には英数字・ハイフン・アンダースコアのみ使えます: '$slug'" >&2
    exit 1;;
esac

out="$ROOT/$slug.html"
if [ -e "$out" ]; then
  echo "エラー: $slug.html は既に存在します。別の slug を指定してください。" >&2
  exit 1
fi

if [ ! -f "$INDEX" ]; then
  echo "エラー: index.html が見つかりません ($INDEX)" >&2
  exit 1
fi

# ---------------------------------------------------------------
# 1) 雛形 HTML を生成
# ---------------------------------------------------------------
cat > "$out" <<EOF
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>$title</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:opsz,wght@12..96,400;12..96,600;12..96,800&family=Zen+Kaku+Gothic+New:wght@400;500;700;900&family=JetBrains+Mono:wght@400;500;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="wrap">

  <header>
    <div class="kicker">Sample Document</div>
    <h1>$title</h1>
    <p class="sub">$desc</p>
  </header>

  <!-- ========== 本文ここから（自由に書き換えてください） ========== -->

  <div class="sec-h"><span class="bar"></span>はじめに</div>
  <p class="sec-lead">これは静的ドキュメントの雛形です。サイト共通の <code>css/style.css</code> を読み込んでいるため、既存のドキュメントと同じテイストで表示されます。本文を書き換えて自分のドキュメントに仕上げてください。</p>

  <div class="prereq">
    <h3><span></span>このページについて</h3>
    <ul>
      <li><b>種別</b>: サンプル文書のテンプレート</li>
      <li><b>編集方法</b>: この HTML の本文を書き換えるだけ</li>
    </ul>
  </div>

  <div class="sec-h" style="margin-top:40px;"><span class="bar"></span>使えるパーツ</div>
  <p class="sec-lead">共通スタイルに用意された主なコンポーネントの例です。</p>

  <ol class="steps">
    <li>
      <div class="step-title">ステップ見出し</div>
      <div class="step-body">手順を <b>番号付き</b> で並べられます。</div>
    </li>
    <li>
      <div class="step-title">コードブロック</div>
      <pre><span class="terminal-dot"><i></i><i></i><i></i></span><code><span class="cmt"># サンプルコマンド</span>
<span class="cmd">echo</span> <span class="str">"hello, world"</span></code></pre>
    </li>
    <li>
      <div class="step-title">補足ノート</div>
      <div class="step-body">下のような注記ボックスを出せます。</div>
    </li>
  </ol>

  <div class="note">
    <span class="ic">!</span>
    <div>これは <b>note</b> コンポーネントです。補足や注意書きに使います。</div>
  </div>

  <!-- ========== 本文ここまで ========== -->

  <footer>
    <div class="conf">Temporary Static Document · Sample</div>
  </footer>

</div>
</body>
</html>
EOF

# ---------------------------------------------------------------
# 2) index.html の目次に登録（連番は自動採番）
# ---------------------------------------------------------------
count="$(grep -c 'class="doc"' "$INDEX" || true)"
num="$(printf '%02d' "$((count + 1))")"

block="$(mktemp)"
cat > "$block" <<EOF
    <li>
      <a class="doc" href="$slug.html">
        <span class="idx">$num</span>
        <span class="meta">
          <span class="title">$title</span>
          <span class="desc">$desc</span>
        </span>
        <span class="go">&rarr;</span>
      </a>
    </li>
EOF

tmp="$(mktemp)"
awk -v blockfile="$block" '
  /<\/ul>/ && !done {
    while ((getline line < blockfile) > 0) print line
    close(blockfile)
    done=1
  }
  { print }
' "$INDEX" > "$tmp"
mv "$tmp" "$INDEX"
rm -f "$block"

echo "作成しました:"
echo "  - $slug.html        (雛形ドキュメント)"
echo "  - index.html        (目次に #$num として追加)"
echo
echo "ローカル確認:  npx wrangler dev   →  http://localhost:8787/$slug.html"
