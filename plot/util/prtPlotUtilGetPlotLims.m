function [plotMins,plotMaxs] = prtPlotUtilGetPlotLims(PrtClassifier,PrtDataSet)
% Here we get the limits for plotting:
if nargin == 1 || isempty(PrtDataSet)
    testY = [];
    testX = [];
else    
    testX = getObservations(PrtDataSet);
    %     if isfield(PrtClassifier.PrtOptions,'PreProcess')
    %         testX = dprtPreProcess(testX, testY, PrtClassifier.PrtOptions.PreProcess);
    %     end
end

trainX = getObservations(PrtClassifier.PrtDataSet);
plotMins = min(cat(1,trainX,testX));
plotMaxs = max(cat(1,trainX,testX));