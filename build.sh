#!/bin/bash

set -xeu -o pipefail

for samtools_version in 1.15.1 1.14 1.13; do
    for bwa_version in 0.7.15 0.7.17; do
        docker build \
            --tag bioslimcontainers/bwa-samtools:bwa-${bwa_version}_samtools-${samtools_version} \
            --build-arg SAMTOOLS_VERSION=${samtools_version} \
            --build-arg BCFTOOLS_VERSION=${samtools_version} \
            --build-arg HTSLIB_VERSION=${samtools_version} \
            --build-arg BWA_VERSION=${bwa_version} \
            .

        if [ ! -z "${DOCKER_PUSH}" ]; then
            docker push bioslimcontainers/bwa-samtools:bwa-${bwa_version}_samtools-${samtools_version}
        fi
    done
done