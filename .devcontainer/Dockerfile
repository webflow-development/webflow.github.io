FROM ubuntu:24.04

# Install dependencies
RUN apt-get update && apt-get install -y ruby-full build-essential zlib1g-dev

ENV GEM_HOME="$HOME/gems"
ENV PATH="$HOME/gems/bin:$PATH"

RUN gem install jekyll bundler