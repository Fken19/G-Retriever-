# graphrag-research

GraphRAG研究用：質・量評価モデル開発
（LLMの推論精度を向上させるための、グラフクエリ結果の評価システム）

---

## 📂 プロジェクト構成

/src          → Python実験用コード、スクリプト群
/data         → 大容量データ（.gitignore対象）
/notebooks    → Jupyterノートブック（必要に応じて）
Dockerfile    → Docker環境構築ファイル
environment.yml → Conda環境定義ファイル
.gitignore    → Git管理外ファイル定義
.dockerignore → Dockerビルド外ファイル定義
README.md     → プロジェクト説明ファイル（この文書）

---

## ✅ 1. 研究の目的・課題設定

### 🎯 目的

GraphRAGにおいて、LLMがグラフクエリ結果（サブグラフ）を使うべきか、また使うならどのサブグラフを使うべきか、
事前に **量** と **質** を予測し最適化する仕組みを構築する。

### 📌 背景・必要性

* 知識グラフを活用することで、LLMのhallucination（幻覚的誤出力）を抑え、推論精度を上げられる可能性がある。
* しかし、クエリ結果が無関係・冗長・矛盾を含む場合は逆効果になる。
* そのため、量と質を事前に評価し、適切なサブグラフのみを選択・活用する必要がある。

---

## ✅ 2. 評価指標の理解

### 📦 質（Quality Estimation）

以下の三本柱で質を評価する：

| 指標                  | 説明                              |
| ------------------- | ------------------------------- |
| logical consistency | サブグラフ内のtripleが意味的・論理的に矛盾しない。    |
| goal relevance      | クエリの意図に沿ったノード・パスが選ばれている。        |
| hop depth control   | 推論の複雑さ・冗長性を避けるため、2〜4 hop程度に抑える。 |

### 📦 量（Cardinality Estimation）

* クエリ実行時に得られるサブグラフの件数（node数、triple数）を予測する。
* 件数が極端に少ない場合は情報不足、多すぎる場合は計算コスト・ノイズ増加の懸念。

---

## ✅ 3. logical consistency の下位要素

| 項目                      | 説明                                                  | 測定方法例                                            |
| ----------------------- | --------------------------------------------------- | ------------------------------------------------ |
| relation整合性チェック         | 隣接するtriple間のrelationが意味的一貫か。                        | relation consistency matrix（ルールベース）、embedding類似度 |
| concept hierarchy check | サブグラフ内のentity間のis-a階層に競合がないか（例：果物と会社の混在）。           | KG内階層、ontology（例：schema.org）参照                   |
| 因果・時間整合性                | 因果関係や時間の流れに矛盾がないか（例：A causes BとB prevents Aが同時にある）。 | causal direction consistency、知識ベース、共起パターン        |
| semantic drift検出        | 話題と関係ないノードが混入していないか（例：Steiner木に不要ノードが混入）。           | embedding空間の距離、外れ値検出、クラスタリング                     |

---

## ✅ 4. スコアの統合方法

* 各要素のスコアを個別に計算。
* 重み付け平均、回帰モデル、または機械学習モデル（例：ランダムフォレスト、ニューラルネットワーク）を用いて統合。
* 統合後の総合quality scoreを用いてサブグラフをランキング・選択。

### 📐 統合スコア例

`Final Score = w₁ * logical consistency + w₂ * goal relevance + w₃ * hop depth control`

---

## ✅ 5. 学習フェーズの流れ

1️⃣ **環境準備**
G-Retriever、Microsoft GraphRAG、独自開発版のいずれかをセットアップ。

2️⃣ **データ収集**
benchmarkデータを用意し、質問を入力して中間サブグラフを抽出。

3️⃣ **説明変数の計算**
各サブグラフに対してlogical consistency、goal relevance、hop depth、cardinalityの値を計算。

4️⃣ **目的変数の設定**
サブグラフあり／なしのLLM出力精度の差分を目的変数とする（Supervised Quality Estimation）。

5️⃣ **学習器の構築**
説明変数を入力、目的変数を出力とする回帰モデル・分類モデルを構築。

6️⃣ **評価**
学習器の性能を精度、F1スコア、AUCなどで評価。

---

## ✅ 6. chain of thought以外の目的における条件

| 目的          | 条件                                     |
| ----------- | -------------------------------------- |
| 事実grounding | KGに含まれる信頼できる事実を参照し、hallucinationを抑制する。 |
| 構造的推論       | クエリの曖昧さが高い場合はKG情報補完、低い場合はLLM単独推論で十分。   |
| 外部知識の動的統合   | LLMが知らない新規・特化知識を引き込む場合は高スコアにする。        |

さらに、LLM側のchain of thoughtを利用することで、
単なる質問文比較よりも正確な知識比較が可能になる可能性がある。

---

## ⚙️ 環境セットアップ（概要・最新手順）

1. Git管理：

   ```bash
   git add .
   git commit -m "✅ 最新変更: 環境・コード更新"
   git push origin main
   ```

2. サブモジュール初期化：

   ```bash
   git submodule update --init --recursive
   ```

3. Dockerビルド：

   ```bash
   docker build -t graphrag-image .
   ```

4. Docker実行：

   ```bash
   docker run -it --name graphrag-container -v ~/Projects/graphrag-research:/app graphrag-image bash
   ```

5. Conda環境起動：

   ```bash
   conda activate graphrag_env
   ```

6. Llamaモデル準備（例: meta-llama/Llama-2-7b-hf、小規模モデルの動作確認）：

   * HuggingFace CLI認証（アクセストークン使用）
   * GPUサーバーでモデルダウンロード

7. inference.py・train.pyによる小規模テスト：

   ```bash
   python inference.py
   python train.py
   ```

---

## 🚧 現在の進行状況（2025年6月3日現在）

* Docker + Conda 環境構築完了。
* GitHubに最新状態をpush済み。
* Llama 2モデルのダウンロード・動作確認準備中（アクセストークン取得済み）。
* inference.py・train.pyのテスト準備中。
* 質・量評価スクリプト開発計画中。

---

## 📅 TODO・今後の作業予定

* [ ] GPUサーバーでのLlama 2推論環境動作確認。
* [ ] inference.pyの出力確認・ログ整備。
* [ ] train.pyによる小規模実験設計と実施。
* [ ] 質・量の指標算出スクリプトの開発。
* [ ] 統合スコアモデルの設計。
* [ ] GitとDockerの連携強化（サーバー側pull・Docker再ビルドなど手順整備）。
