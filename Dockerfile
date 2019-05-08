FROM alpine:3.9 AS download-samtools
RUN apk add curl libarchive-tools
RUN curl -OL https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2
RUN bsdtar xf samtools-1.9.tar.bz2

FROM alpine:3.9 AS buildenv-samtools
RUN apk add gcc make libc-dev ncurses-dev bzip2-dev zlib-dev curl-dev curl xz-dev
COPY --from=download-samtools /samtools-1.9 /samtools-1.9
WORKDIR /samtools-1.9
RUN ./configure --prefix=/usr
RUN make -j4
RUN make install DESTDIR=/dest

FROM alpine:3.9 AS download-bwa
RUN apk add curl libarchive-tools
RUN curl -OL https://downloads.sourceforge.net/project/bio-bwa/bwa-0.7.17.tar.bz2
RUN bsdtar xf bwa-0.7.17.tar.bz2

FROM alpine:3.9 AS buildenv-bwa
RUN apk add gcc make libc-dev zlib-dev patch
COPY --from=download-bwa /bwa-0.7.17 /bwa-0.7.17
WORKDIR /bwa-0.7.17
COPY bwa-patch.patch /
RUN patch -p1 < /bwa-patch.patch
RUN make -j4
RUN install -D -t /dest//usr/bin bwa
RUN install -D -t /dest//usr/share/man/man1 bwa.1

FROM alpine:3.9
RUN apk add ncurses libbz2 zlib libcurl xz-libs bash
COPY --from=buildenv-samtools /dest /
COPY --from=buildenv-bwa /dest /
ADD run.sh /
ENTRYPOINT [ "/bin/bash", "/run.sh" ]
