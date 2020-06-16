# Comment
FROM ubuntu:bionic

LABEL tag=dealii_candi_9.2


# Adapted from the work of Luca Heltai
LABEL maintainer="blais.bruno@gmail.com"

USER root
RUN apt-get update && apt-get install -y software-properties-common \
    && apt-get update && apt-get install -y \
    git \
    locales \
    ssh \
    sudo \
    ninja-build \
    numdiff \
    wget \
    build-essential \
    lsb-release \
    automake \
    autoconf \
    gfortran \
    openmpi-bin \
    openmpi-common \
    libopenmpi-dev \
    cmake \
    subversion \
    libblas-dev \
    liblapack-dev \
    libblas3 \
    liblapack3 \
    libsuitesparse-dev \
    libtool  \
    libboost-all-dev  \
    zlib1g-dev \
    trilinos-dev \
    && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8



RUN wget https://github.com/dealii/dealii/releases/download/v9.0.0/clang-format-6-linux.tar.gz \
    && tar xfv clang* && cp clang-6/bin/clang-format /usr/local/bin/ \
    && rm -rf clang*

# add and enable the default user
ARG USER=dealii
RUN adduser --disabled-password --gecos '' $USER
RUN adduser $USER sudo; echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

#make sure everything is in place
RUN chown -R $USER:$USER /home/$USER
USER $USER
ENV HOME /home/$USER
ENV USER $USER
#ENV OMPI_MCA_btl "^vader"

WORKDIR $HOME

RUN echo "Preparing CANDI"
RUN mkdir $HOME/candi
#
RUN echo "Cloning CANDI"
RUN git clone https://github.com/dealii/candi.git $HOME/candi/candi
RUN echo $(ls $HOME/candi/candi)
RUN cd $HOME/candi/candi ; bash candi.sh -j16 --prefix=$HOME/candi
RUN echo $(ls $HOME/candi)
RUN echo $(ls $HOME/candi/deal.II-v9.2.0)
RUN rm -rf $HOME/candi/tmp

ENV OMPI_MCA_btl_base_warn_component_unused=0
ENV OMPI_MCA_btl_vader_single_copy_mechanism=none
