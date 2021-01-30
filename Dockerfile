FROM jodogne/orthanc-debug:1.8.2 as Debug

RUN apt-get update \
  && apt-get -y install software-properties-common apt-transport-https ca-certificates \
  && wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null \
  && apt-add-repository 'deb https://apt.kitware.com/ubuntu/ xenial main' \
  && apt-get update \
  && apt-get -y install build-essential unzip cmake make git curl python libsasl2-dev uuid-dev libssl-dev zlib1g-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /root/

COPY . orthanc-mongodb/

RUN mkdir orthanc-mongodb/build \
  && cd orthanc-mongodb/build \
  && cmake -DCMAKE_CXX_FLAGS='-fPIC' \
     -DCMAKE_INSTALL_PREFIX=/usr \
     -DCMAKE_BUILD_TYPE=Debug \
     -DORTHANC_ROOT=/root/orthanc \
     -DAUTO_INSTALL_DEPENDENCIES=ON .. \
  && make

RUN rm /etc/orthanc/orthanc.json

COPY ./orthanc-conf.json /etc/orthanc/orthanc-conf.json

EXPOSE 4242
EXPOSE 8042

ENTRYPOINT [ 'Orthanc' ]

CMD [ '/etc/orthanc/' ]

