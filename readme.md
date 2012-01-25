PRT: Pattern Recognition and Machine Learning in MATLAB
=========

A free and permissively licensed object oriented approach to machine learning in MATLAB.

Machine learning and pattern recognition are eveywhere. MATLAB is a high level interpretted language and despite it's high cost to entry, it is frequently used throughout academia and engineering contractors for its easy of use and its numerous available toolboxes. Currently available toolboxes for pattern recognition and machine learning in MATLAB are either costly or restrictively licensed. The PRT is an MIT licensed toolbox that provides access to a wide range of pattern recognition techniques in an easy to use unified framework. The PRT provides a suite of MATLAB commands and data-types to help you organize, visualize, process, cluster and classify your data. If you have data and need to make predictions based on your data, the PRT can help.

Installation
------------

To install the PRT, simply (clone the repository or) un-zip the PRT folder into your working MATLAB directory. Assume this folder is called called "prt". To ensure that all of the PRT functions are on your MATLAB path, edit your startup.m file to include the folder "prt" on your path, and then run "prtPath". On a typical windows system, these lines in your startup.m might look like this:

> addpath C:\Users\theUser\Documents\MATLAB\prt
> prtPath;

The PRT is distributed with several folders that begin with "]". These are by default not added to your MATLAB path by prtPath. If you would like to include folders that begin with "]" these folders must be specified in the call to prtPath. The most useful of these folders are the ]beta and ]alpha folders which offer new features at various stages of their development. These folders can be added to the MATLAB path along with the rest of the PRT by using:

> prtPath('beta','alpha');


Setting the PRT for First Time Usage
------------------------------------

The PRT provides several utility functions to help ensure that all the power of the PRT is readily available. Once the PRT is installed following the directions above, we need to add the PRT to the MATLAB Documentation search index, and also make sure that GraphViz is installed on your computer. The command "prtSetup" will attempt to handle this process for you. Simply type:

> prtSetup

At the MATLAB command prompt to start this process. If GraphViz is not installed, the PRT will warn you and provide the URL of a website where you can download GraphViz for your system.

Note: building the search index can take a little while, please be patient while prtSetup is running.

### Building MEX Files

Several of the PRT's functions are implemented as MEX file for speed and convenience. However MEX files may need to be re-compiled to work on your system. Rebuilding MEX files with the PRT is quite easy. All we need to do is 1) make sure you have a supported compiler, 2) Run mex -setup, and 3) Compiler the PRT MEX files. The following sections outline how to accomplish these three tasks.

1) First, make sure you have a MATLAB Supported compiler for your system (there are free ones available for making MEX files on all operating systems). You can find a list of supported compilers for your version of MATLAB here.

2) Once your compiler is installed, run the MATLAB command

> mex -setup

And pick the compiler you've installed to let MATLAB know which compiler you'd like to use.

3) The PRT command "prtSetupMex" is provided to automatically recompile all the MEX files included in the PRT. Running

> prtSetupMex

Should compile all the necessary files.

### That's it!

Congratulations! You've successfully installed the PRT and it should be working properly now.

Documentation
-------------

Once installed, the PRT documentation is available in several ways.

 1) Run the command "prtDoc" at the command line.
 
 2) From the MATLAB "Start" button, Start --> Toolboxes --> PRT
 
 3) All the PRT documentation is also available here: <http://www.newfolderconsulting.com/prt/doc/>