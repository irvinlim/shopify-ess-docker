FROM ruby:2.2.3
LABEL maintainer="irvinlimweiquan@gmail.com"

LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.name="Shopify/ess" \
      org.label-schema.description="Shopify Enterprise Script Service (ESS)"

WORKDIR /ess

# Set default locale to prevent UTF-8 parsing errors.
ENV LC_ALL=C.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8

RUN set -ex && \
    \
    # Install build dependencies to build mruby.
    buildDeps="bison" && \
    apt-get update && \
    apt-get install -y --no-install-recommends ${buildDeps} && \
    rm -rf /var/lib/apt/lists/* && \
    \
    # Clone from GitHub and fix git submodules to use HTTPS protocol.
    git clone https://github.com/Shopify/ess.git /ess && \
    sed -i 's git@github.com: https://github.com/ g' .gitmodules && \
    git submodule update --init --recursive && \
    \
    # Build the project.
    bundle install && \
    bin/rake && \
    rm -r /root/.gem/ && \
    \
    # Clean up to reduce layer size.
    apt-get purge -y --auto-remove ${buildDeps}

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
