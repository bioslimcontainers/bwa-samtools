FROM alpine:3.15 as samtools-download
RUN apk update && apk upgrade
RUN apk add curl tar xz bzip2
ARG SAMTOOLS_VERSION=1.15.1
RUN curl -OL https://github.com/samtools/samtools/releases/download/${SAMTOOLS_VERSION}/samtools-${SAMTOOLS_VERSION}.tar.bz2
RUN tar xjf samtools-${SAMTOOLS_VERSION}.tar.bz2

FROM alpine:3.15 as bcftools-download
RUN apk update && apk upgrade
RUN apk add curl tar xz bzip2
ARG BCFTOOLS_VERSION=1.15.1
RUN curl -OL https://github.com/samtools/bcftools/releases/download/${BCFTOOLS_VERSION}/bcftools-${BCFTOOLS_VERSION}.tar.bz2
RUN tar xjf bcftools-${BCFTOOLS_VERSION}.tar.bz2

FROM alpine:3.15 as htslib-download
RUN apk update && apk upgrade
RUN apk add curl tar xz bzip2
ARG HTSLIB_VERSION=1.15.1
RUN curl -OL https://github.com/samtools/htslib/releases/download/${HTSLIB_VERSION}/htslib-${HTSLIB_VERSION}.tar.bz2
RUN tar xjf htslib-${HTSLIB_VERSION}.tar.bz2

FROM alpine:3.15 as samtools-build
RUN apk update && apk upgrade
RUN apk add bash gcc libc-dev make autoconf automake libtool curl-dev zlib-dev bzip2-dev xz-dev openssl-dev
RUN apk add ncurses-dev
ARG SAMTOOLS_VERSION=1.15.1
WORKDIR /build
COPY --from=samtools-download /samtools-${SAMTOOLS_VERSION} /build/samtools-${SAMTOOLS_VERSION}
WORKDIR /build/samtools-${SAMTOOLS_VERSION}
RUN ./configure && make -j4 && make install DESTDIR=/dest

FROM alpine:3.15 as bcftools-build
RUN apk update && apk upgrade
RUN apk add bash gcc libc-dev make autoconf automake libtool curl-dev zlib-dev bzip2-dev xz-dev openssl-dev
RUN apk add ncurses-dev
ARG BCFTOOLS_VERSION=1.15.1
WORKDIR /build
COPY --from=bcftools-download /bcftools-${BCFTOOLS_VERSION} /build/bcftools-${BCFTOOLS_VERSION}
WORKDIR /build/bcftools-${BCFTOOLS_VERSION}
RUN ./configure && make -j4 && make install DESTDIR=/dest

FROM alpine:3.15 as htslib-build
RUN apk update && apk upgrade
RUN apk add bash gcc libc-dev make autoconf automake libtool curl-dev zlib-dev bzip2-dev xz-dev openssl-dev
RUN apk add ncurses-dev
ARG HTSLIB_VERSION=1.15.1
WORKDIR /build
COPY --from=htslib-download /htslib-${HTSLIB_VERSION} /build/htslib-${HTSLIB_VERSION}
WORKDIR /build/htslib-${HTSLIB_VERSION}
RUN ./configure && make -j4 && make install DESTDIR=/dest

FROM alpine:3.15 AS bwa-download
RUN apk update && apk upgrade
RUN apk add curl tar xz bzip2
ARG BWA_VERSION=0.7.15
RUN curl -OL https://downloads.sourceforge.net/project/bio-bwa/bwa-${BWA_VERSION}.tar.bz2
RUN tar xjf bwa-${BWA_VERSION}.tar.bz2

FROM alpine:3.15 AS bwa-build
RUN apk update && apk upgrade
RUN apk add bash gcc libc-dev make autoconf automake libtool curl-dev zlib-dev bzip2-dev xz-dev openssl-dev
RUN apk add patch
ARG BWA_VERSION=0.7.15
COPY --from=bwa-download /bwa-${BWA_VERSION} /bwa-${BWA_VERSION}
WORKDIR /bwa-${BWA_VERSION}
COPY bwa-patch.patch /
RUN patch -p1 < /bwa-patch.patch
RUN make -j4
RUN install -D -t /dest/usr/bin bwa
RUN install -D -t /dest/usr/share/man/man1 bwa.1

FROM alpine:3.15
RUN apk update && apk upgrade
RUN apk add bash libcurl zlib libbz2 xz-libs libssl1.1 ncurses perl
COPY --from=samtools-build /dest /
COPY --from=bcftools-build /dest /
COPY --from=htslib-build /dest /
COPY --from=bwa-build /dest /
ADD run.sh /
ENTRYPOINT [ "/bin/bash", "/run.sh" ]
