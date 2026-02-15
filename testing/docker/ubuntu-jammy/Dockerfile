FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    git \
    sudo \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash dotfiles && \
    echo "dotfiles ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/dotfiles

USER dotfiles
WORKDIR /home/dotfiles

CMD ["/bin/bash"]
