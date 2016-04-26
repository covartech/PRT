function [pcScores, P] = prtUtilPcaEm(X,nComponents,convergenceThreshold,nMaxIterations)
% [pcScores, P] = prtUtilPcaEm(X,nComponents,convergenceThreshold,nMaxIterations)








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
