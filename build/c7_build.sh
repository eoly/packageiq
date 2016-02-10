#!/bin/bash

docker run -h c7-builder.docker -it --rm -v $PWD:/data c7-builder
