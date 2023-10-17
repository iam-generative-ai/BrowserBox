# By using this Dockerfile or a container that runs BrowserBox you are agreeing to the terms in the BrowserBox License.
# base image

# current base
FROM ubuntu:jammy

LABEL org.opencontainers.image.source https://github.com/BrowserBox/BrowserBox

ARG IS_DOCKER_BUILD=true
ENV IS_DOCKER_BUILD=$IS_DOCKER_BUILD
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/New_York

# install dependencies
RUN apt-get update
RUN apt-get update && \
    apt-get install -y tzdata && \
    ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    apt-get clean
RUN apt-get install -y \
    libx11-xcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libnss3 \
    libnspr4 \
    libasound2 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libxrandr2 \
    libpangocairo-1.0-0 \
    libgtk-3-0 \
    curl \
    jq \
    vim 

# install Node.js
# RUN apt-get install -y nodejs
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | sudo -E bash -
RUN source ~/.nvm/nvm.sh; nvm install stable

# Create a non-root user 'bbpro' and give it sudo permissions
RUN useradd -ms /bin/bash bbpro && \
    apt-get update && \
    apt-get install -y sudo && \
    echo "bbpro ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Define HOME and WORKDIR
ENV HOME=/home/bbpro
WORKDIR $HOME/bbpro/

# Copy application to docker as root to preserve permissions
USER root
COPY . $HOME/bbpro/

# Change ownership of the workdir to the 'bbpro' user
RUN chown -R bbpro:bbpro $HOME/bbpro/

# Switch back to 'bbpro' user
USER bbpro

# install application
RUN yes | ./deploy-scripts/global_install.sh localhost

# extract the login link using setup_bbpro and save it to a file
RUN echo $(setup_bbpro --port 8080) > login_link.txt

# run the application
RUN bbpro 

CMD tail -f /dev/null

