function [plotMins,plotMaxs] = prtPlotUtilGetPlotLims(PrtClassifier,PrtDataSet)
% Internal function, 
% xxx Need Help xxx







% Here we get the limits for plotting:
if nargin == 1 || isempty(PrtDataSet)
    testY = [];
    testX = [];
else    
    testX = getObservations(PrtDataSet);
end

trainX = getObservations(PrtClassifier.PrtDataSet);
plotMins = min(cat(1,trainX,testX));
plotMaxs = max(cat(1,trainX,testX));
