# Magento2 Docker QA

## Description

This project aims to provide a docker-compose setup for running tests on latest
magento version.

When booted the container will get the latest magento version set it up
and run unit, integration, and functional tests.

## Quick start

The easiest way to get up and running quickly is to kick of the process with
docker-compose:

```
docker-compose up -d
docker-compose logs -f magento.local
```
