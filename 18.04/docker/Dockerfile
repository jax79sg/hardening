FROM ubuntu:18.04
RUN apt update && apt install -y wget git vim build-essential
RUN git clone https://github.com/Stifler6996/apt-mirror
COPY mirror.list /etc/apt/mirror.list 
