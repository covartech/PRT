function C = prtClassGenVbDpMmLogDiscBag(DS,PrtOptions)
% C = prtClassGenVbDpMmLogDisc(DS,PrtOptions)

C.PrtOptions = PrtOptions;
C.PrtDataSet = DS;

%%
SourcePrior = logDiscPrior(DS.nFeatures-1);
%P = vbdpmmbagPrior(C.PrtOptions.nMaxComponents ,SourcePrior);
P = vbdpmmPrior(C.PrtOptions.nMaxComponents ,SourcePrior);

XStack = cat(2,DS.getTargets(),DS.getObservations(:,2:end));
fileInds = DS.getObservations(:,1);

uFile = unique(fileInds);
X = cell(length(uFile),1);
for iFile = 1:length(uFile)
    X{iFile} = XStack(fileInds==iFile,:);
end

C.Q = vbdpmmbag(X,P,C.PrtOptions.VbOptions);

%%

