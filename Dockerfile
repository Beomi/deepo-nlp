FROM ufoym/deepo:all-jupyter-py36-cu100

# Install JVM for Konlpy
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    openjdk-8-jdk wget curl git python3-dev \
    language-pack-ko

RUN locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

# Install zsh
RUN apt-get install -y zsh && \
    sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

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

# Install another packages
RUN pip install -e git+https://github.com/kanth989/pandas_explode#egg=pandas_explode
RUN pip install \
    autopep8 twint pytorch_pretrained_bert \
    s3fs fastparquet soynlp konlpy \
    randomcolor pynamodb plotly
RUN pip install "dask[complete]"
RUN pip install python-snappy

# Add Mecab-Ko
RUN curl -L https://raw.githubusercontent.com/konlpy/konlpy/master/scripts/mecab.sh | bash

# Reset Workdir
WORKDIR /code
