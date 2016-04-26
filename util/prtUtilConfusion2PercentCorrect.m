function pC = prtUtilConfusion2PercentCorrect(confusionMat)
% prtUtilConfusion2PercentCorrect  Calculates the percent correct from a confunsion matrix.
%   This is done by summing the percentages allong the diagonal. If the
%   confusion matrix lists number of responses and not percentages, this
%   this is accounted for.
%
% Syntax:  pC = prtUtilConfusion2PercentCorrect(confusionMat)
%
% Inputs:
%   confusionMat - nClass x nClass matrix listing the number of responses 
%       for a given truth. Truths are listed vertically moving downward.
%       Responses are listed horizontally moving right.
%
% Outputs:
%   pC - The percent correct for the confusion matrix
%
% Example 1: 
% Example 2: 
%   confusionMat = [4 1 0 0; 0 2 1 0; 0 1 2 1; 0 1 2 3];
%   prtUtilConfusion2PercentCorrect(confusionMat)
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%







if any(~prtUtilIsNaturalNumber(confusionMat(:)))
    error('requires counting number - confusionCountMatrix, not confusionPercentMatrix');
end

assert(ndims(confusionMat)==2 && size(confusionMat,1)==size(confusionMat,2),'prt:prtUtilConfusion2PercentCorrect:BadInput','prtUtilConfusion2PercentCorrect requires a square confusion matrix. A non square confusion matrix possible implies a mismatch between the true targets and the assigned targets. This is ambiguous.')

% The confusion matrix lists the number of responses not percentages.
% We must change the matrix to a percentage matrix.
occurances = repmat(sum(confusionMat,2),1,size(confusionMat,2));

%For normalization, set 0 --> inf; this discounts rows where we had no
%examples in truth
normOccurances = occurances;
normOccurances(occurances == 0) = inf;
confusionMat = confusionMat./normOccurances;

pC = sum(diag(confusionMat).*occurances(:,1))./sum(occurances(:,1));

function is = prtUtilIsNaturalNumber(x)

is = (x == round(x) & x >= 0);
