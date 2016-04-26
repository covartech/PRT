function [XHat, evaluationMetric] =  prtUtilSvdEmPredict(X,U,S,V)
% [XHat, evaluationMetric] = prtUtilSvdEmPredict(X,U,S,V)
% Used to predict missing entries given learned SVD decomposition







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
