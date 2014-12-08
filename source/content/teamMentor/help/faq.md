## FAQ

#### Q - What is the current version of TEAM Mentor and how is it structured?

A - The current version of TM can always be found on https://github.com/TeamMentor/Master However, we are still sorting out the development methodology so this location may change.

#### Q - What Software Development methodology is used in TeamMentor and how often we create releases or feature packs?

A - Generally we aim for a quarterly release cycle. The methodology and process is still being defined. But some of the ideas that are close to being solidified can be found here: Team Mentor Development Process - Repository Perspective.

#### Q - Do we have documentation available (Visio documents, diagrams,design notes,architecture diagrams) about TeamMentor architecture?

A - Some useful documentation can be found on http://docs.teammentor.net - this site is geared towards clients. Other internal documentation can be found on this site (tm4tm.teammentor.net). This site is still a work in progress.

#### Q - Are there any Coding conventions that needs to be followed (naming conventions or code standards)?

A - Yes, variable names must all begin with "cool_" and class names must contain the word "Spopodvipodvertom". Seriously though, not that I know off, but clearly written code with good comments are a must.

#### Q - What Version tool are we currently using for Source Version control?

A - TeamMentor not only uses git (github in particular) for version control, but is heavily integrated with git in its internals. In particular all the content libraries are stored as xml files and fetched from github.

#### Q - What steps needs to be followed in order to setup a Development environment for TeamMentor?

A - Start by cloning the repository git clone https://github.com/TeamMentor/Master . It will have everything to run TM. It also includes a standalone http daemon. So double clicking on Start TM will bring up TM in a browser, connected to localhost. You may also want to download a freely distributed OWASP library from https://github.com/TMContent/Lib_OWASP see the docs.teammentor.net site for instructions on how to install the library. These two things together will give you a good start.

#### Q - What are the system requirements that needs to be met in order to start developing on TeamMentor?

A - VisualStudio and good imagination.

#### Q - Do we have different test regions (development, staging, production) that can be used to reproduce or test fixes/improvements?

A - Not at the moment, but we should start looking into setting these up

#### Q - What kind or user profiles(user structure) can I find in TeamMentor and what are the access levels?

A - TeamMentor has 3 main roles - admin, editor and reader. Editor can edit articles, and admin can control TM, set options and create users. More info can be found on docs.teammentor.net

#### Q - Do we have test users or generic users already created that can be used for testing purposes?

A - Generally no. Testing is done locally on a VM at the moment.

#### Q - If I find a bug or defect on TeamMentor, where should I fill the defect up and whom should I notify?

A - All bugs should be reported through github at https://github.com/TeamMentor/Master/issues?milestone=&page=1&state=open generally as much info as possible to reproduce the issue, including screen shots is always good.

#### Q - Do we have any CodeReview tool so we can create a code review request before committing the code?

A - Not at the moment. You break you fix policy applies

#### Q - If I wanted to learn more about the product itself, what resources should I look at?

A - docs.teammentor.net and tm4tm.teammentor.net are best options

#### Q - If I find an issue in content how should I report it?

A - Generally content issues should be reported github issue list in TMContent/Lib_XXX library. Where XXX stands for specific technology library where content issue was found. For example, if you find an issue in the Java library with a particular article you should report the issue in TMContent/Lib_Java repository issue list. If the issue spans multiple technologies or is not specific to a library it should be reported in TMContent/Lib_All repository issue list.

#### Q - But TMContent repositories are private, I don’t have access, how do I report the issue?

A - If you do not have access to the TMContent library, you should report the issue in https://github.com/TeamMentor/Master/issues?milestone=&page=1&state=open

#### Q - TeamMentor now supports git integration, what is the difference between Library and User_Data integration?

A - Library git integration is explained in the documentation article TM_Libraries Git Support and User_Data git integration is explained in the documentation article User_Data Git Support also please take a look at Configuring User_Data to Sync to Github for more information on SI hosted TM instances.

#### Q - My TeamMentor syncs to a whole bunch of repositories, I though only one repository is used?

A - You are mixing the Libraries sync with User_Data sync, In a TM server, each library can be synced to a github repo, but only to 1 User_Data repo (which is the one that has all the user data xml files and config stuff)