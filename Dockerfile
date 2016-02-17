FROM ubuntu:latest

ENV PACKAGES wget make xz-utils g++ python python-matplotlib perl ca-certificates
RUN apt-get update -y && apt-get install -y --no-install-recommends ${PACKAGES}

ENV URL https://downloads.sourceforge.net/project/quast/quast-3.2.tar.gz
ENV DIR /usr/local/quast

RUN mkdir ${DIR}

RUN cd ${DIR} &&\
    wget --quiet --no-check-certificate ${URL} --output-document - |\
    tar xzf - --directory . --strip-components=1 && \
    cd libs/MUMmer3.23-linux && \
    make CPPFLAGS="-O3 -DSIXTYFOURBITS"

COPY ./run /

RUN wget \
      --quiet \
      --output-document -\
      ${URL} \
    | tar xzf - \
      --directory ${DIR} \
      --strip-components=1

ENV CONVERT https://github.com/bronze1man/yaml2json/raw/master/builds/linux_386/yaml2json
# download yaml2json and make it executable
RUN cd /usr/local/bin && wget --quiet ${CONVERT} && chmod 700 yaml2json 

ENV JQ http://stedolan.github.io/jq/download/linux64/jq
# download jq and make it executable
RUN cd /usr/local/bin && wget --quiet ${JQ} && chmod 700 jq

ADD /Taskfile /

# Locations for biobox file validator
ENV VALIDATOR /bbx/validator/
ENV BASE_URL https://s3-us-west-1.amazonaws.com/bioboxes-tools/validate-biobox-file
ENV VERSION  0.x.y
RUN mkdir -p ${VALIDATOR}

# download the validate-biobox-file binary and extract it to the directory $VALIDATOR
RUN wget \
      --quiet \
      --output-document -\
      ${BASE_URL}/${VERSION}/validate-biobox-file.tar.xz \
    | tar xJf - \
      --directory ${VALIDATOR} \
      --strip-components=1

ENV PATH ${PATH}:${VALIDATOR}

ADD schema.yml /

ENTRYPOINT ["/run"]
