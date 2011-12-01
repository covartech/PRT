function output = prtEmlClassLogisticDiscriminantRun(inputX,prtEmlLogisticDiscriminantStruct)
% output = prtEmlClassLogisticDiscriminantRun(inputX,prtEmlLogisticDiscriminantStruct)
% 
%   As a prtEml*Run function, prtEmlClassLogisticDiscriminantRun takes
%   individual vectors of features and outputs scalar values corresponding
%   to the class estimates of the classifier.  The classifier structure
%   should be the second input.  Note that the second input is not a
%   prtClass object.

%#eml

internalX = cat(1,1,inputX(:));
outX = prtEmlLogisticDiscriminantStruct.w'*internalX;
output = 1./(1 + exp(-outX));