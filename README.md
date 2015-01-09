TM 4.0 Design  [![Build Status][travis-img]][travis-url][![Coverage Status][coveralls-img]][coveralls-url]
=============

Repo to hold files and designs for the 4.0 version of TeamMentor.


### Auto publish to Azure

This repo is currently configured to autopublish to Azure at http://tm-4-0-design.azurewebsites.net

TeamCity CI is used to pull the changes and push/publish to Azure (for more details see [issue 2](https://github.com/TeamMentor/TM_4_0_Design/issues/2))

### Wiki pages (on this repo)

* [IE CSS resources](https://github.com/TeamMentor/TM_4_0_Design/wiki/IE-CSS-resources)


**to run dev brach**

* clone https://github.com/TeamMentor/TM_4_0_Design
* git checkout Issue_68_Library_Rendering
* npm install
* npm start
* http://localhost:1337/

**MAJOR REFACTORING CURRENTLY HAPPENING**

See the [Issue_80_Jade_Cleanup](https://github.com/TeamMentor/TM_4_0_Design/tree/Issue_80_Jade_Cleanup) branch for the current structure. 

The key objective of that branch is to create a clean and fully unit-tested version of TM Jade


[travis-img]: https://travis-ci.org/TeamMentor/TM_4_0_Design.svg?branch=master
[travis-url]: https://travis-ci.org/TeamMentor/TM_4_0_Design
[coveralls-img]: https://coveralls.io/repos/TeamMentor/TM_4_0_Design/badge.png?branch=master
[coveralls-url]: https://coveralls.io/r/TeamMentor/TM_4_0_Design?branch=master
