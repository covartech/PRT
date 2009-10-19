function [ClassifierResults,Etc] = prtClassRunKmeansPrototypes(PrtClassKmeansPrototypes,PrtDataSet)
%[ClassifierResults,Etc] = prtClassRunKmeansPrototypes(PrtClassKmeansPrototypes,PrtDataSet)
%   Run the K-Means prototype algrithm on the data in PrtDataSet.  This
%   returns an unlabeled data set containing the expected classlabels for
%   each data point.
%
%   See: Hastie, Tibshirani, Friedman, "The Elements of Statistical
%   Learning", Chappter 13, p. 412.

% Peter Torrione

Etc = [];

%For each class, find the distance of all the data to each class center
fn = PrtClassKmeansPrototypes.PrtOptions.PrtUtilOptFuzzyKmeans.distanceMeasure;
distance = nan(PrtDataSet.nObservations,length(PrtClassKmeansPrototypes.classMeans));
for i = 1:length(PrtClassKmeansPrototypes.classMeans)
    d = fn(PrtDataSet.data,PrtClassKmeansPrototypes.classMeans{i});
    distance(:,i) = min(d,[],2);
end

%The smallest distance is the expected class:
[val,ind] = min(distance,[],2);
ind = PrtClassKmeansPrototypes.uY(ind);  %note, use uY to get the correct label

ClassifierResults = prtDataSetUnLabeled(ind);