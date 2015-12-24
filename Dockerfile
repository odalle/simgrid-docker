# SIMGRID build Docker image.
# Author: O. Dalle
#
# Description:
# This image produces a compiled version of SG. The required dpendencies
# and sources are supposed to b already installed in the pre-build image
# on top of which the current image is built.

FROM simgrid:prebuild
MAINTAINER Olivier Dalle <olivier.dalle@unice.fr>

ARG LATEST
ENV LATEST_VERSION v3_12
ARG VERSION=${LATEST_VERSION}
ENV SG_VERSION ${VERSION}

ARG ENABLED_BUILD_OPTIONS
ENV ENABLED_BUILD_OPTIONS ${ENABLED_BUILD_OPTIONS}

ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64

ARG WORKDIR=/opt
WORKDIR ${WORKDIR}

COPY build_sg.py ./

ARG TARGET_DIR=${WORKDIR}/simgrid
ENV TARGET_DIR ${TARGET_DIR}

COPY simgrid-${VERSION} simgrid-${VERSION}


RUN ./build_sg.py

# The following fails with java enabled.
RUN cd ${TARGET_DIR} && ( make || make ) && make check && ctest && make install


