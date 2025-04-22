# Use the official Alpine image as a parent image
FROM alpine:latest

RUN apk update
RUN apk add bash sudo

RUN adduser -D -s /bin/bash bazeler && \
        echo "bazeler ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

COPY build_gcc_linux.sh /home/bazeler/build_gcc_linux.sh
RUN chmod +x /home/bazeler/build_gcc_linux.sh

USER bazeler
WORKDIR /home/bazeler
RUN ./build_gcc_linux.sh
