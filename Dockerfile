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

# The following commntd RUNs corresponds to what was done in
# the pre-build image

#RUN export DISPLAY=:0.0 && \
#    apt-get update && apt-get install -y \
#    gcc-4.8 \
#    g++-4.8 \
#    g++ \
#    cmake \
#    git \
#    libboost-context-dev \
#    libboost-dev \
#    openjdk-7-jdk
    
#RUN export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64 && mkdir /opt/simgrid \
#    && cd /opt \
#    && git clone -b 'v3_12' --single-branch git://scm.gforge.inria.fr/simgrid/simgrid.git \

#RUN echo "Building simgrid version:$VERSION" && mkdir /opt/simgrid \
#    && cd /opt \
#    && git clone $VERSION --single-branch git://scm.gforge.inria.fr/simgrid/simgrid.git \
#    && export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64 \
#    && cd /opt/simgrid \
#    && cmake - \
#       	     $COMPILE_OPTIMIZATION \
    # 	     $JAVA \
    # 	     $DEBUG \
    # 	     $MSG_DEPRECATED \
    # 	     $MODEL_CHECKING \
    # 	     $COMPILE_WARNING \
    # 	     $LIB_STATIC \
    # 	     $MAINTAINER_MODE \
    # 	     $TRACING \
    # 	     $SMPI \
    # 	     $MALLOCATORS \
    # 	     $JDULE \
    # 	     $LUA \
    # 	     $GTNETS \
    # 	     $NS3 \
    # 	     $LATENCY_BOUND_TRACKING \
    # 	     $DOCUMENTATION \
    # 	     -DCMAKE_INSTALL_PREFIX=/opt/simgrid \
    # && make \
    # && make test \
    # && make install

RUN ./build_sg.py

# The following fails with java enabled.
RUN cd ${TARGET_DIR} && ( make || make ) && make check && ctest && make install


