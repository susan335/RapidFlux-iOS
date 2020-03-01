#!/bin/bash

BASE_PATH=$(cd $(dirname $0); pwd)
SOURCERY="${BASE_PATH}/Sourcery/bin/sourcery"

if [[ ! -z "$GITHUB_ACCESS_TOKEN" ]]; then
    REQUEST_HEADER="-H 'Authorization: token ${GITHUB_ACCESS_TOKEN}'"
fi

if [[ ! -e $SOURCERY ]]; then
    FILE_NAME="${BASE_PATH}/Sourcery.zip"
    URL="https://api.github.com/repos/krzysztofzablocki/Sourcery/releases/tags/0.16.1"
    DOWNLOAD_URL=$(eval curl $REQUEST_HEADER "$URL" | grep -oe '"browser_download_url":\s*"[^" ]*"' | grep -oe 'http[^" ]*')
    eval curl -Lo "${FILE_NAME}" "${DOWNLOAD_URL}"

    unzip ${FILE_NAME} -d "${BASE_PATH}/Sourcery" && rm ${FILE_NAME}
fi

templates=${BASE_PATH}/stencil/ViewModel.stencil

while getopts "a:o:s:u" opts
do
  case $opts in
    a)
      args="--args $OPTARG"
      ;;
    o)
      output=$OPTARG
      ;;
    u)
      templates=${BASE_PATH}/stencil/
      ;;
    s)
      source=$OPTARG
      ;;
  esac
done
echo $source
echo $templates
echo $output
echo $args
$SOURCERY --sources $source \
   --templates $templates \
   --output $output \
   --disableCache \
   ${args}