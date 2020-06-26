FROM ufoym/deepo

# Install JVM for Konlpy
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    openjdk-8-jdk wget curl git python3-dev build-essential \
    language-pack-ko libsnappy-dev

RUN locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

# Install zsh
RUN apt-get install -y zsh && \
    sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Pip cache
RUN mkdir /root/.pip && echo "[global] \nindex-url=http://ftp.daumkakao.com/pypi/simple \ntrusted-host=ftp.daumkakao.com" > /root/.pip/pip.conf

# Install Khaiii
WORKDIR /deps
RUN git clone https://github.com/kakao/khaiii.git
WORKDIR /deps/khaiii

RUN pip install cython && \
    pip install --upgrade pip && \
    pip install -r requirements.txt && \
    mkdir build
WORKDIR /deps/khaiii/build

RUN cmake .. && make all && make resource && make install && make package_python

WORKDIR /deps/khaiii/build/package_python
RUN pip install .

# Setup Jupyter extensions
RUN pip install jupyter_nbextensions_configurator jupyter_contrib_nbextensions && \
    jupyter nbextensions_configurator enable && \
    jupyter contrib nbextension install

RUN pip install jupyter_http_over_ws && \
    jupyter serverextension enable --py jupyter_http_over_ws

# Konlpy & Mecab-ko
RUN pip install konlpy && curl -L https://raw.githubusercontent.com/konlpy/konlpy/master/scripts/mecab.sh | bash

# Install another packages
RUN pip install \
    pandas_explode \
    transformers \
    autopep8 twint pytorch_pretrained_bert \
    s3fs fastparquet soynlp \
    randomcolor pynamodb plotly python-snappy 
RUN pip install "dask[complete]"

RUN wget -O /usr/local/bin/orca https://github.com/plotly/orca/releases/download/v1.2.1/orca-1.2.1-x86_64.AppImage && chmod +x /usr/local/bin/orca
RUN pip install psutil requests

# APEX for fp16
RUN git clone https://github.com/NVIDIA/apex && \
    cd apex && \
    pip install --no-cache-dir ./


# Add non-root user
RUN adduser --disabled-password --gecos "" user

# Reset Workdir
WORKDIR /code
