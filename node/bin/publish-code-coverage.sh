#!/bin/bash

set -o errexit # Exit on error

echo 'Creating instrumented node files'
./node_modules/jscover/bin/jscover node node-cov 

echo 'Running Tests and Publishing to coveralls'
mocha -R mocha-lcov-reporter node-cov/tests/**/**.js | sed 's,SF:,SF:node/,' | ./node_modules/coveralls/bin/coveralls.js

echo 'Removing instrumented node files'
rm -R node-cov

echo 'Opening browser with Coveralls page'

open "https://coveralls.io/r/TeamMentor/TM_4_0_Design"