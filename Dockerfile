FROM debian:latest

RUN apt-get -y update
RUN apt-get -y upgrade

RUN apt-get install -y git vim
RUN apt-get install -y devscripts build-essential lintian debhelper
RUN apt-get install -y help2man

RUN apt-get install -y curl

COPY build_stlcmd.sh /tmp/
COPY signing-key.asc /tmp/
RUN sh /tmp/build_stlcmd.sh

CMD ["bash"]
