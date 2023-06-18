ARG DEBIAN_VERSION="11.6-slim"

FROM debian:$DEBIAN_VERSION AS live

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# This Dockerfile's base image has a non-root user with sudo access. Use the "remoteUser"
# property in devcontainer.json to use it. On Linux, the container user's GID/UIDs
# will be updated to match your local UID/GID (when using the dockerFile property).
# See https://aka.ms/vscode-remote/containers/non-root-user for details.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# [Optional] Update UID/GID if needed
RUN   if [ "$USER_GID" != "1000" ] || [ "$USER_UID" != "1000" ]; then \
        groupmod --gid $USER_GID $USERNAME \
        && usermod --uid $USER_UID --gid $USER_GID $USERNAME \
        && chown -R $USER_UID:$USER_GID /home/$USERNAME; \
      fi

RUN apt-get update && apt-get install -y autoconf automake libtool curl make g++ unzip checkinstall gdb ninja-build wget libssl-dev

RUN wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.10.5-stable.tar.xz &&\
    tar xf flutter_linux_3.10.5-stable.tar.xz &&\
    export PATH="$PATH:`pwd`/flutter/bin"

#RUN export PATH="$PATH:`pwd`/flutter/bin" && source /etc/environment && export PATH
RUN apt-get update && apt-get install -y sed git curl xz-utils cmake clang pkg-config gtk+-3.0
