%% Toolbox Structure / M-File Naming Conventions
%
% The PRT was designed to provide a powerfun yet extensible tool for
% implementing pattern classification and machine learning algorithms on a
% wide range of data sets in both classification, regression, and
% un-supervised clustering frameworks.  
%
% To keep the functionality of different M-files clear, we have separated
% the M-files in the PRT into different groups.  In the order these
% functions are presented in this document, these groups are (sample
% M-files from each group are included in parenthesis after the group
% name):
%
% * Data generation techniques          (e.g. prtDataGenUnimodal)
% * DataSet Objects                     (e.g. prtDataSetClass)
% * Classification algorithms           (e.g. prtClassFld)
% * Regression algorithms               (e.g. prtRegressLslr)
% * Unsupervised clustering algorithms  (e.g. prt***)
% * Preprocessing algorithms            (e.g. prtPreProcPca)
% * Feature selection algorithms        (e.g. prtFeatSelSfs)
% * Decision making algorithms          (e.g. prtDecisionBinaryMinPe)
% * Scoring and Evaluation functions    (e.g. prtScoreRoc)
% 
% This is not an exhaustive list of the kinds of functions available in the
% PRT (this doesn't include prtDistance or prtKernel functions, for
% example), but it does give an overview of some of the most commonly used
% functions.  A few things to note:
%
%   1) All the M-files (functions and classses) in the PRT begin with the
%   three letters "prt".  This helps avoid namespace conflicts between the
%   prt function prtScoreRoc and any other function you might have called
%   "scoreRoc.m".
%
%   2) The PRT M-file names were designed with MATLAB tab-completion in
%   mind - so PRT M-file names progress from general strings on the left,
%   i.e. "prt", "Class" to specific strings - i.e. "Rvm" in the case of
%   "prtClassRvm".  As a result, it is easy to find a list of all the PRT
%   classification M-files, just type "prtClass" at the MATLAB command
%   prompt, then hit the "tab" key to bring up a list of all the
%   PRT classification objects available.
%
%   Valid strings that can follow "prt" in PRT function naming are: Class,
%   DataGen, Decision, Distance, Eval, FeatSel, Kernel, PreProc, Regress,
%   Rv, Score, and Util. 
%
%   You might find some other functions in the PRT that start with
%   prt<SomeOtherString>.  These functions are generally for internal use
%   only, and are subject to change in future versions of the PRT.