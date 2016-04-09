#!/bin/sh
if [ \( "$1" = "-h" \) -o \( "$1" = "--help" \) ]
then
  echo "Usage: release.sh <docker sha> <version>"
else
  docker tag $1 hflw/formless:$2
  docker push hflw/formless
  if [ "$2" != "latest" ]
  then
    git tag $2
    git push --tags
  fi
fi
