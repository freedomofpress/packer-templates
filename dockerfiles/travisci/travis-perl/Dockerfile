FROM quay.io/travisci/travis-perl:latest
RUN export DEBIAN_FRONTEND=noninteractive && \
    rm -rf /var/lib/apt/lists && \
    apt-get update -yqq && \
    apt-get install -yqq aptitude && \
    aptitude safe-upgrade -o Aptitude::Delete-Unused=false --assume-yes --target-release `lsb_release -cs`-security
