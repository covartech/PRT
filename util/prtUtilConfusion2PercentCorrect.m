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
%       for a given truth or the percentage of responses. Truths are listed
%       vertically moving downward. Responses are listed horizontally 
%       moving right.
%
% Outputs:
%   pC - The percent correct for the confusion matrix
%
% Example 1: 
%   confusionMat = [0.8 0.2 0 0; 0 0.66 0.33 0; ...
%                   0 0.25 0.5 0.25; 0 0.166 0.333 0.5];
%   prtUtilConfusion2PercentCorrect(confusionMat)
%
% Example 2: 
%   confusionMat = [4 1 0 0; 0 2 1 0; 0 1 2 1; 0 1 2 3];
%   prtUtilConfusion2PercentCorrect(confusionMat)
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%

if any(confusionMat(:) > 1) || any(sum(confusionMat,2) > 1.5)
    % The confusion matrix lists the number of responses not percentages.
    % We must change the matrix to a percentage matrix.
    occurances = repmat(sum(confusionMat,2),1,length(confusionMat));
    
    %For normalization, set 0 --> inf; this discounts rows where we had no
    %examples in truth
    normOccurances = occurances;
    normOccurances(occurances == 0) = inf;
    confusionMat = confusionMat./normOccurances;
    
    pC = sum(diag(confusionMat).*occurances(:,1))./sum(occurances(:,1));
else
    pC = mean(diag(confusionMat));
end

