FROM bioboxes/biobox-minimal-base@sha256:b1d26c3bd23b85cbdbf55540c8c5a65efdb5f99fb15966eb5b0e5b6187af5dfc

ENV PACKAGES python python-matplotlib perl
RUN apt-get update -y && apt-get install -y --no-install-recommends ${PACKAGES}

ADD install_quast.sh /install_quast.sh
RUN ./install_quast.sh && rm install_quast.sh

ADD /run /usr/local/bin/
ADD /Taskfile /
ADD schema.yml /

ENTRYPOINT ["run"]
