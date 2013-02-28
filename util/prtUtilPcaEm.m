function [pcScores, P] = prtUtilPcaEm(X,nComponents,convergenceThreshold,nMaxIterations)
% [pcScores, P] = prtUtilPcaEm(X,nComponents,convergenceThreshold,nMaxIterations)
%
% Source: Wikipedia (how amature)
% xxx Need Help xxx

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


% Input checks and what not
if nargin < 2 || isempty(nComponents)
    nComponents = size(X,2);
end

if nComponents > size(X,2)
    nComponents = size(X,2);
end

if nargin < 3 || isempty(convergenceThreshold)
    convergenceThreshold = 1e-5;
end

if nargin < 4 || isempty(nMaxIterations)
    nMaxIterations = 100;
end

% Here we go!
P = nan(size(X,2),nComponents);
E = X;
for iComp = 1:nComponents

    % Guess a component
    p = randn(size(X,2),1);
    
    % EM it
    for iter = 1:nMaxIterations
        oldp = p;
        
        p = ((E*p)'*E)';
        p = p./norm(p);
        
        done = norm(p-oldp) < convergenceThreshold;
        
        if done
            break
        end
    end
   
    % Remove it
    E = E-(E*p)*p';
    
    
    % Save it
    P(:,iComp) = p;
end

pcScores = X*P;
