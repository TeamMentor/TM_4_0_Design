#!/bin/bash

if [ ! -f ./node_modules/mocha-lcov-reporter/package.json ]; then
  echo 'Installing coverage dependencies'
  npm install jscover
  npm install coffee-coverage
  npm install mocha-lcov-reporter
  npm install coveralls
fi

set -o errexit # Exit on error
echo 'Removing cache files'
rm -R .tmCache

echo 'Creating instrumented node files'
echo '    for js'
./node_modules/jscover/bin/jscover node node-cov 
echo '    for CoffeeScript'
coffeeCoverage --path relative ./node ./node-cov/
echo '    deleting node-cov *.coffee files'
find . -path "./node-cov/**/*.coffee" -delete

echo 'Running Tests and Publishing to coveralls'
mocha -R mocha-lcov-reporter node-cov/tests --recursive | sed 's,SF:,SF:node/,' | ./node_modules/coveralls/bin/coveralls.js

echo 'Removing instrumented node files'
rm -R node-cov