#!/bin/bash

if [ ! -f ./node_modules/html-file-cov/package.json ]; then
  echo 'Installing coverage dependencies'
  npm install jscover
  npm install coffee-coverage
  npm install html-file-cov
fi

#set -o errexit # Exit on error
echo 'Removing cache files'
rm -R ./.tmCache
mkdir ./.tmCache

echo 'Creating instrumented node files (for CoffeeScript)'
coffeeCoverage --path relative ./src ./node-cov/src
coffeeCoverage --path relative ./test ./node-cov/test

echo '    deleting node-cov *.coffee files'
find . -path "./node-cov/**/*.coffee" -delete

echo 'Running Tests locally with (html-file-cov)'
mocha -R html-file-cov node-cov/test  --recursive

#echo 'Removing instrumented node files'
#rm -R node-cov
mv coverage.html .tmCache/coverage.html

echo 'Opening browser with coverage.html'

open .tmCache/coverage.html