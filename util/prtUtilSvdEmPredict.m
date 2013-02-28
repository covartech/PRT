function [XHat, evaluationMetric] =  prtUtilSvdEmPredict(X,U,S,V)
% [XHat, evaluationMetric] = prtUtilSvdEmPredict(X,U,S,V)
% Used to predict missing entries given learned SVD decomposition

% Copyright (c) 2013 New Folder Consulting
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.


nMaxIterations = 500;
proportionChangeThreshold = 5e-5;

hasVotes = ~isnan(X);

% Initialize
UHat = repmat(mean(U,1),size(X,1),1);
XHat = UHat*S*V';
XHat(hasVotes) = X(hasVotes);

pinvTerm = pinv(sqrt(S)*V')*sqrt(S)*V';

evaluationMetric = nan(nMaxIterations,1);
for iter = 1:nMaxIterations
    XHat = XHat*pinvTerm;
    XHat(hasVotes) = X(hasVotes);
    
     if iter > 1
        evaluationMetric(iter) = norm(XHat-oldXHat,'fro');
        proportionChange = -(evaluationMetric(iter)-evaluationMetric(iter-1))/abs(mean(evaluationMetric((iter-1):iter)));
        if proportionChange < proportionChangeThreshold
            break
        end
     else
        evaluationMetric(iter) = nan;
     end
    
    oldXHat = XHat;
end
