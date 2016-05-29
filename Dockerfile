FROM bioboxes/biobox-minimal-base@sha256:b1d26c3bd23b85cbdbf55540c8c5a65efdb5f99fb15966eb5b0e5b6187af5dfc

ENV PACKAGES make g++ python python-matplotlib perl
RUN apt-get update -y && apt-get install -y --no-install-recommends ${PACKAGES}

ENV URL https://s3-us-west-1.amazonaws.com/bioboxes-packages/downloads/quast-3.2.tar.xz
ENV DIR /usr/local/quast

RUN mkdir ${DIR}

RUN cd ${DIR} &&\
    wget --quiet --no-check-certificate ${URL} --output-document - |\
    tar xJf - --directory . --strip-components=1 && \
    cd libs/MUMmer3.23-linux && \
    make CPPFLAGS="-O3 -DSIXTYFOURBITS"

COPY ./run /
ADD /Taskfile /
ADD schema.yml /

ENTRYPOINT ["/run"]
