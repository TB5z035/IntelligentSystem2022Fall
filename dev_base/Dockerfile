##########################################################################
# dev-base
##########################################################################
FROM ubuntu:focal AS conda
SHELL ["/bin/bash", "-c"]
ADD proxy.sh /opt/proxy.sh
ADD direct.sh /opt/direct.sh

### wget
RUN source /opt/proxy.sh && apt-get update && apt-get install -y --no-install-recommends wget && source /opt/direct.sh 

### conda
WORKDIR /opt
RUN wget --no-check-certificate https://repo.anaconda.com/miniconda/Miniconda3-py37_4.12.0-Linux-x86_64.sh -O Miniconda3.sh && \
     chmod +x Miniconda3.sh && ./Miniconda3.sh -b -p /opt/conda -f
ENV PATH=/opt/conda/bin:/opt/conda/condabin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN pip3 install --upgrade pip -i https://pypi.tuna.tsinghua.edu.cn/simple

##########################################################################
FROM ubuntu:focal AS base
SHELL ["/bin/bash", "-c"]

RUN apt-get update && \
     apt-get install -y --no-install-recommends ca-certificates gnupg2 && \
     rm -rf /var/lib/apt/lists/* && \
     apt-get clean 

RUN sed -i "s@http://.*archive.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list
RUN sed -i "s@http://.*security.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list

RUN echo 'Etc/UTC' > /etc/timezone && \
     ln -s /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
     apt-get update && \
     DEBIAN_FRONTEND=noninterative apt-get install -y --no-install-recommends \
     tzdata dirmngr wget && \
     rm -rf /var/lib/apt/lists/* && apt-get clean

WORKDIR /opt
COPY --from=conda /opt/conda /opt/conda
RUN /opt/conda/bin/conda init
ENV PATH=/opt/conda/bin:/opt/conda/condabin:/usr/local/nvidia/bin:/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
