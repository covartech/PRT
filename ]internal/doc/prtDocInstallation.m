%% Product Installation and Accessing Documentation
%
% To install the PRT, simply un-zip the PRT folder into your working MATLAB
% directory.  This should create a folder called "prt".  To ensure that all
% of the PRT functions are on your MATLAB path, edit your startup.m file to
% include the folder "prt" on your path, and then run "prtPath".  On a
% typical windows system, these lines in your startup.m might look like
% this:
%
%   addpath C:\Users\theUser\Documents\MATLAB\prt
%   prtPath;
%
% Note: if the above lines are not placed in your startup.m, but are run
% after MATLAB has started, the PRT will not be available in the MATLAB
% doc browser.
%
% Once installed, the PRT documentation is available in several ways.  
%
%   1) Run the command "prtDoc" at the command line.
%   2) From the MATLAB "Start" button, Start --> Toolboxes --> PRT
%   3) All the PRT documentation is also available here:
%       http://www.newfolderconsulting.com/prt/doc/

%% Setting the PRT for First Time Usage
%
% The PRT provides several utility functions to help ensure that all the
% power of the PRT is readily available.  Once the PRT is installed
% following the directions above, we need to add the PRT to the MATLAB
% Documentation search index, and also make sure that GraphViz is installed
% on your computer.  The command "prtSetup" will attempt to handle this
% process for you.  Simply type:
%
% prtSetup
%
% At the MATLAB command prompt to start this process.  If GraphViz is not
% installed, the PRT will warn you and provide the URL of a website where
% you can download GraphViz for your system.  
%
% Note: building the search index can take a little while, please be
% patient while prtSetup is running.
%

%% Building MEX Files
% 
% Several of the PRT's functions are implemented as MEX file for speed and
% convenience.  However MEX files may need to be re-compiled to work on
% your system.  Rebuilding MEX files with the PRT is quite easy.  All we
% need to do is 1) make sure you have a supported compiler, 2) Run mex
% -setup, and 3) Compiler the PRT MEX files.  The following sections
% outline how to accomplish these three tasks.
%
% 1) First, make sure you have a MATLAB Supported compiler for your system
% (there are free ones available for making MEX files on all operating
% systems).  You can find a list of supported compilers for your version of
% MATLAB <http://www.mathworks.com/support/compilers/previous_releases.html
% here>.
%
% 2) Once your compiler is installed, run the MATLAB command
%
% mex -setup
%
% And pick the compiler you've installed to let MATLAB know which compiler
% you'd like to use.
%
% 3) The PRT command "prtSetupMex" is provided to automatically recompile
% all the MEX files included in the PRT.  Running
%
% prtSetupMex
%
% Should compile all the necessary files.
% 

%% That's it!
%
% Congratulations!  You've successfully installed the PRT and it should be
% working properly now.  To learn more, please check out the rest of the
% documentation, including:
%
% * <prtDocProductOverview.html Product Overview>
% * <prtDocPatternRecognition.html What is Pattern Recognition?>
% * <prtDocGettingStartedExamples.html Some examples of using the PRT>
% * <prtDocFunctionList.html A list of commonly used functions>
%
% Copyright 2011 New Folder Consulting L.L.C. 
