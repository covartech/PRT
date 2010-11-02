function output = prtEmlLogisticDiscriminantRun(inputX,logisticDiscriminantStruct)
%#eml

internalX = cat(1,1,inputX(:));
% logDisc = initializeLogDisc;
logDisc = logisticDiscriminantStruct;
outX = logDisc.w'*internalX;
output = 1./(1 + exp(-outX));

% function logDisc = initializeLogDisc
% logDisc.w = [-3.38684584859082;2.15251466433441;1.77842906638334;4.21639318717135;1.64549363006092];