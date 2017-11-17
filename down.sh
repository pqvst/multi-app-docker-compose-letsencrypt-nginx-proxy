#!/bin/bash

(cd router && docker-compose down)

(cd app1 && docker-compose down)

(cd app2 && docker-compose down)
