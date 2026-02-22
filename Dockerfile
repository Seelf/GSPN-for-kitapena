# STAGE 1: Build GreatSPN based on Debian
FROM debian:bullseye-slim AS builder

# Install build tools and libraries
RUN apt-get update && apt-get install -y \
    gcc g++ make autoconf automake libtool flex bison byacc cmake git wget zip \
    ant default-jdk \
    libgmp-dev libboost-all-dev libglib2.0-dev libglpk-dev libxml2-dev \
    libsuitesparse-dev libmotif-dev libxml++2.6-dev libglibmm-2.4-dev \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/default-java
ENV MAKE_ARGS=-j4
# Set include and library paths as ENV variables, so they are visible to all processes
ENV CPLUS_INCLUDE_PATH=/usr/local/include
ENV LIBRARY_PATH=/usr/local/lib
WORKDIR /build

# 1. Meddly (using a stable commit from February 2024 compatible with GreatSPN)
RUN git clone https://github.com/asminer/meddly.git meddly && \
    cd meddly && \
    git checkout c55b7e96b0f353dd9fec39aa2a6970a340d97cb1 && \
    ./autogen.sh && ./configure --prefix=/usr/local && \
    make ${MAKE_ARGS} && make install

# 2. SPOT (Version 2.9.6)
RUN wget http://www.lrde.epita.fr/dload/spot/spot-2.9.6.tar.gz && \
    tar xzf spot-2.9.6.tar.gz && cd spot-2.9.6 && \
    ./configure --disable-python --disable-debug && \
    make ${MAKE_ARGS} && make install

# 3. OGDF (Version Dogwood-202202)
RUN git clone https://github.com/ogdf/ogdf && \
    cd ogdf && \
    git checkout dogwood-202202 && \
    mkdir build && cd build && cmake .. && \
    make ${MAKE_ARGS} && make install

# 4. lp_solve
RUN wget https://datacloud.di.unito.it/index.php/s/JFsJwyHfJ9FNWZJ/download/lp_solve_5.5.2.11_source.tar.gz && \
    wget https://raw.githubusercontent.com/greatspn/SOURCES/master/contrib/build_lpsolve.sh && \
    sed -i 's/sudo //g' build_lpsolve.sh && \
    tar xzf lp_solve_5.5.2.11_source.tar.gz && \
    sh ./build_lpsolve.sh

# 5. GreatSPN
RUN git clone https://github.com/greatspn/SOURCES.git GreatSPN_SOURCES && \
    cd GreatSPN_SOURCES && \
    export MULTIARCH=$(gcc -print-multiarch) && \
    # Set compiler paths
    # Export paths and variables explicitly for both make and make install
    export CPLUS_INCLUDE_PATH=/usr/local/include && \
    export LIBRARY_PATH=/usr/local/lib:/usr/lib/$MULTIARCH && \
    export CXXFLAGS="-fpermissive -I/usr/local/include" && \
    export CPPFLAGS="-fpermissive -I/usr/local/include" && \
    export INCLUDE_MEDDLY_LIB="-I/usr/local/include" && \
    export HAS_MEDDLY_LIB=1 && export PATH_TO_MEDDLY_LIB=/usr/local/lib/ && \
    export HAS_GMP_LIB=1 && export PATH_TO_GMP_LIB=/usr/lib/$MULTIARCH/ && \
    export LINK_GMP_LIB="-lgmpxx -lgmp" && \
    export HAS_GLPK_LIB=1 && export PATH_TO_GLPK_LIB=/usr/lib/$MULTIARCH/ && \
    export LINK_GLPK_LIB="-lglpk" && \
    export HAS_LP_SOLVE_LIB=1 && export PATH_TO_LP_SOLVE_LIB=/usr/local/lib/ && \
    export INCLUDE_LP_SOLVE_LIB="-DHAS_LP_SOLVE_LIB=1 -I/usr/local/include" && \
    export JAVA_HOME=/usr/lib/jvm/default-java && \
    make ${MAKE_ARGS} -k derived_objects && \
    make ${MAKE_ARGS} && \
    make install

# STAGE 2: Target image (Python slim)
FROM python:3.9-slim

RUN apt-get update && apt-get install -y \
    libgmp10 libglpk40 libxml2 libglib2.0-0 libmotif-common \
    libxml++2.6-2v5 libglibmm-2.4-1v5 \
    graphviz default-jre-headless \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/GreatSPN /usr/local/GreatSPN
COPY --from=builder /usr/local/lib /usr/local/lib
COPY --from=builder /usr/local/include /usr/local/include

RUN ldconfig
ENV GREATSPN_HOME=/usr/local/GreatSPN
ENV PATH="${PATH}:${GREATSPN_HOME}/bin:${GREATSPN_HOME}/scripts"

WORKDIR /app

# The default command will just be bash, letting you use the container interactively
CMD ["bash"]