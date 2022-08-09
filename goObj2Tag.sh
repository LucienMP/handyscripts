#!/bin/bash

#
# goes from diff obj ... to a tag
#

SHA=$1
RES=$(git describe $SHA | cut -d ":" -f 1)

git tag --sort=taggerdate --contains $RES
