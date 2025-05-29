# ベースイメージ：Miniconda搭載のUbuntuベース
FROM continuumio/miniconda3

# 環境変数：インストール時の対話を回避
ENV DEBIAN_FRONTEND=noninteractive

# 必要なビルドツール・ライブラリをインストール
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    ninja-build \
    libopenblas-dev \
    libomp-dev \
    python3-dev \
    g++ \
    libffi-dev \
    libssl-dev \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 作業ディレクトリを作成
WORKDIR /app

# Conda環境定義をコピー
COPY environment.yml .

# Conda環境を作成（ymlのname通り graphrag_env が作られる）
RUN conda env create -f environment.yml

# Conda環境有効化用（シェル切り替え）
SHELL ["conda", "run", "-n", "graphrag_env", "/bin/bash", "-c"]


# プロジェクトソースコードをコピー
COPY ./src /app/src

# ノートブックフォルダもコピー（必要な場合のみ）
COPY ./notebooks /app/notebooks

# デフォルト起動コマンド（仮: bash, 実行用スクリプトに変更可能）
CMD ["bash"]