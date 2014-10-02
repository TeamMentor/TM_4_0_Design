#!/bin/bash

set -o errexit # Exit on error
echo 'Removing cache files'
#rm -R .tmCache

echo 'Creating instrumented node files'
echo '    for js'
./node_modules/jscover/bin/jscover node node-cov 
echo '    for CoffeeScript'
coffeeCoverage --path relative ./node ./node-cov/
echo '    deleting node-cov *.coffee files'
find . -path "./node-cov/**/*.coffee" -delete

echo 'Running Tests and Publishing to coveralls'
mocha -R mocha-lcov-reporter node-cov/tests/**/**.* | sed 's,SF:,SF:node/,' | ./node_modules/coveralls/bin/coveralls.js

echo 'Removing instrumented node files'
rm -R node-cov

echo 'Opening browser with Coveralls page (refresh and the new data should be there)'

open "https://coveralls.io/r/TeamMentor/TM_4_0_Design"