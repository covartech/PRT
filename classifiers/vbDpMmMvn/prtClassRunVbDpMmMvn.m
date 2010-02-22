function [ClassifierResults,Etc] = prtClassRunVbDpMmMvn(C,DS)


%% Pre Proc
PreProcDS = prtRun(C.PreProc,DS);
%%
DecStat = zeros(DS.nObservations,length(C.GmmQs));

for iY = 1:length(C.GmmQs)
    [logLikes, phiMat] = ezDpMmPriorAlphaToLogLikes(PreProcDS.getObservations(),C.GmmQs{iY});
    
    maxLogLikes = max(phiMat,[],2);
    
    DecStat(:,iY) = maxLogLikes;
    
    keyboard
    
end

ClassifierResults = prtDataSet(DecStat);
Etc = [];