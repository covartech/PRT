function [pC, pCConf] = prtScorePercentCorrect(guess,truth,alpha)
% PERCENTCORRECT    Calculate percent correct of two classifications guess, truth
% 
% Syntax: pC = percentCorrect(guess,truth,alpha = 0.05)
%
% Inputs:
%   guess - Guess classification
%   truth - True classification
%   alpha - Confidence region (default 0.05)
%
% Outputs:
%   pC - Percent correct
%   pCConf - Confidence Bounds on percent correct
%
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none

% Author: Kenneth D. Morton Jr.
% Duke University, Department of Electrical and Computer Engineering
% Email Address: collinslab@gmail.com
% Created: 16-Dec-2006 13:29:07

[guess,truth] = prtUtilScoreParseFirstTwoInputs(guess,truth);

if nargout > 1
    if nargin > 2
        [pC, pCConf] = binofit(sum(guess == truth),length(guess),alpha);
    else
        [pC, pCConf] = binofit(sum(guess == truth),length(guess));
    end
else
    pC = sum(guess == truth)./length(guess);
end