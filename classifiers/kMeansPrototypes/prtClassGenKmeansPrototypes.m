function PrtClassKmeansPrototypes = prtClassGenKmeansPrototypes(PrtDataSet,PrtClassOpt)
%PrtClassFld = prtClassGenKmeansPrototypes(PrtDataSet,PrtClassOpt)
%   Generate a K-means prototype classification algorithm.  
%
%   See: Hastie, Tibshirani, Friedman, "The Elements of Statistical
%   Learning", Chappter 13, p. 412.

% Peter Torrione

x = getObservations(PrtDataSet);
y = getLabels(PrtDataSet);

n = PrtDataSet.nObservations;
p = PrtDataSet.nDimensions;

uY = unique(y);
PrtClassKmeansPrototypes.uY = uY; % we need this for later

%For each class, extract the Fuzzy K-Means class centers:
classMeans = cell(1,length(uY));
for i = 1:length(uY)
    classMeans{i} = prtUtilFuzzyKmeans(x(y == uY(i),:),PrtClassOpt.PrtUtilOptFuzzyKmeans);
end

PrtClassKmeansPrototypes.PrtDataSet = PrtDataSet;
PrtClassKmeansPrototypes.PrtOptions = PrtClassOpt;
PrtClassKmeansPrototypes.classMeans = classMeans;