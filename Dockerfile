FROM ruby:2.2.3
LABEL maintainer="irvinlimweiquan@gmail.com"

LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.name="Shopify/ess" \
      org.label-schema.description="Shopify's ESS sandbox using mruby and seccomb-bpf-sandbox" \
      org.label-schema.vcs-ref="fd0e9cff6bd3c097419e0825479cac8972cf747c"

WORKDIR /ess

# Set default locale to prevent UTF-8 parsing errors.
ENV LC_ALL=C.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8

# Specify the build dependencies.
ENV BUILD_DEPS "bison"

# Install necessary build dependencies which will be purged later.
RUN apt-get update && \
    apt-get install -y --no-install-recommends ${BUILD_DEPS} && \
    rm -rf /var/lib/apt/lists/*

# Clone the repository and fix git submodules to use HTTPS protocol.
RUN git clone https://github.com/Shopify/ess.git /ess && \
    sed -i 's git@github.com: https://github.com/ g' .gitmodules && \
    git submodule update --init --recursive

# Build the project.
RUN bundle install && \
    bin/rake

# Purge build dependencies.
RUN apt-get purge -y --auto-remove ${BUILD_DEPS}

# Add our own binaries.
ADD bin/ /ess/bin/
ADD run/ /ess/run/

# Link binaries to /usr/bin.
RUN ln -s /ess/bin/sandbox /usr/bin/sandbox && \
    ln -s /ess/bin/pretty /usr/bin/pretty && \
    ln -s /ess/bin/json /usr/bin/json

# Update PWD to directory for input scripts.
WORKDIR /scripts

# Add a default script.
ADD default.rb /scripts/default.rb

CMD ["pretty", "/scripts/default.rb"]
