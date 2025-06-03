# CUDA対応PyTorch公式イメージをベースに使用（Miniconda不要）
FROM pytorch/pytorch:2.1.0-cuda11.8-cudnn8-runtime

# 環境変数：インストール時の対話を回避
ENV DEBIAN_FRONTEND=noninteractive

# 必要な追加ライブラリをインストール
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

# Pythonパッケージ requirements をコピー
COPY requirements.txt .

RUN pip install --upgrade pip

# ✅ GPU版torch-geometricのインストール（PyTorch + CUDA11.8対応）
RUN pip install \
    torch-scatter \
    torch-sparse \
    torch-cluster \
    torch-spline-conv \
    -f https://data.pyg.org/whl/torch-2.1.0+cu118.html

# その他のPythonパッケージをインストール
RUN pip install -r requirements.txt

# プロジェクトソースコードをコピー
COPY ./src /app/src

# ノートブックフォルダもコピー（必要な場合のみ）
COPY ./notebooks /app/notebooks

# デフォルト起動コマンド（仮: bash, 実行用スクリプトに変更可能）
CMD ["bash"]