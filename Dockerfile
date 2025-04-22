# Базовый образ: Ubuntu 22.04 LTS
FROM ubuntu:22.04

# Устанавливаем общие зависимости в один слой
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential \
        wget curl ca-certificates pkg-config libssl-dev \
        zlib1g-dev libncurses5-dev autoconf automake libtool perl make file \
        libbz2-dev liblzma-dev libcurl4-openssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Переменная для путей установки специализированного ПО
ENV SOFT=/soft

# Создаём папку под софт
RUN mkdir -p $SOFT

# HTSlib 1.20 (от 30.12.2023)
RUN cd /tmp && \
    wget https://github.com/samtools/htslib/releases/download/1.20/htslib-1.20.tar.bz2 && \
    tar -xjf htslib-1.20.tar.bz2 && cd htslib-1.20 && \
    ./configure --prefix=$SOFT/htslib-1.20 && \
    make -j$(nproc) && make install && \
    rm -rf /tmp/htslib-1.20*

# Добавляем HTSlib в PATH и переменные окружения
ENV HTSLIB=/soft/htslib-1.20
ENV PATH=$HTSLIB/bin:$PATH
ENV LD_LIBRARY_PATH=$HTSLIB/lib

# SAMtools 1.14 (от 05.08.2023)
RUN cd /tmp && \
    wget https://github.com/samtools/samtools/releases/download/1.14/samtools-1.14.tar.bz2 && \
    tar -xjf samtools-1.14.tar.bz2 && cd samtools-1.14 && \
    ./configure --prefix=$SOFT/samtools-1.14 --with-htslib=$SOFT/htslib-1.20 && \
    make -j$(nproc) && make install && \
    rm -rf /tmp/samtools-1.14*

# Переменная SAMTOOLS
ENV SAMTOOLS=$SOFT/samtools-1.14/bin/samtools \
    PATH=$SOFT/samtools-1.14/bin:$PATH

# BCFtools 1.14 (от 05.08.2023)
RUN cd /tmp && \
    wget https://github.com/samtools/bcftools/releases/download/1.14/bcftools-1.14.tar.bz2 && \
    tar -xjf bcftools-1.14.tar.bz2 && cd bcftools-1.14 && \
    ./configure --prefix=$SOFT/bcftools-1.14 --with-htslib=$SOFT/htslib-1.20 && \
    make -j$(nproc) && make install && \
    rm -rf /tmp/bcftools-1.14*

# Переменная BCFTOOLS
ENV BCFTOOLS=$SOFT/bcftools-1.14/bin/bcftools \
    PATH=$SOFT/bcftools-1.14/bin:$PATH

# libdeflate 1.23 (от 15.12.2024)
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        cmake \
    && rm -rf /var/lib/apt/lists/*

RUN cd /tmp && \
    wget https://github.com/ebiggers/libdeflate/archive/refs/tags/v1.23.tar.gz && \
    tar -xzf v1.23.tar.gz && \
    cd libdeflate-1.23 && \
    cmake -B build \
          -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_PREFIX=$SOFT/libdeflate-1.23 && \
    cmake --build build --parallel $(nproc) && \
    cmake --install build && \
    rm -rf /tmp/libdeflate-1.23 /tmp/v1.23.tar.gz

# Переменная LIBDEFLATE
ENV LIBDEFLATE=$SOFT/libdeflate-1.23 \
    PATH=$SOFT/libdeflate-1.23/bin:$PATH

# VCFtools 0.1.16 (от 02.08.2018)
RUN cd /tmp && \
    wget https://github.com/vcftools/vcftools/releases/download/v0.1.16/vcftools-0.1.16.tar.gz && \
    tar -xzf vcftools-0.1.16.tar.gz && cd vcftools-0.1.16 && \
    ./autogen.sh && ./configure --prefix=$SOFT/vcftools-0.1.16 && \
    make -j$(nproc) && make install && \
    rm -rf /tmp/vcftools-0.1.16*

# Переменная VCFTOOLS
ENV VCFTOOLS=$SOFT/vcftools-0.1.16/bin/vcftools \
    PATH=$SOFT/vcftools-0.1.16/bin:$PATH

# Очищаем временные файлы
RUN rm -rf /var/tmp/* /tmp/*

# По умолчанию запускаем bash
CMD ["bash"]

#Python task
RUN apt-get update && \
    apt-get install -y python3-pip && \
    pip3 install pysam && \
    pip3 install pandas &&\
    rm -rf /var/lib/apt/lists/*
COPY convert_alleles.py /usr/local/bin/
RUN chmod +x /usr/local/bin/convert_alleles.py

