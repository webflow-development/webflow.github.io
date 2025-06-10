FROM mcr.microsoft.com/azure-powershell:14.0.0-ubuntu-22.04

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get -y install curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

LABEL maintainer="services@webflow.ch"

ARG BICEP_VERSION="0.35.1"
ARG AZ_RESOURCES_VERSION="7.7.0"

RUN curl -Lo bicep "https://github.com/Azure/bicep/releases/download/v${BICEP_VERSION}/bicep-linux-x64" && \
    chmod +x ./bicep  && \
    mv ./bicep /usr/local/bin/bicep && \
    apt-get update

# RUN pwsh -Command "Set-PSRepository -Name PSGallery -InstallationPolicy Trusted; \
#     Install-Module -Name Az.Resources -RequiredVersion '${AZ_RESOURCES_VERSION}' \
#     -Scope AllUsers -Verbose -Force"

COPY scripts/ /usr/local/bin

USER root
