function [ClassifierResults,Etc] = prtClassRunLVQ(PrtClassLVQ,PrtDataSet)
%[ClassifierResults,Etc] = prtClassRunLVQ(PrtClassLVQ,PrtDataSet)
%   Run the LVQ prototype algorithm on the data in PrtDataSet.  This
%   returns an unlabeled data set containing the expected classlabels for
%   each data point.
%
%   See: Hastie, Tibshirani, Friedman, "The Elements of Statistical
%   Learning", Chappter 13, p. 414.

% Peter Torrione

%the run is exactly the same as prtClassRunKmeansPrototypes
[ClassifierResults,Etc] = prtClassRunKmeansPrototypes(PrtClassLVQ,PrtDataSet);