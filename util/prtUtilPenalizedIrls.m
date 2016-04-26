function [mu, U, w, likelihood] = prtUtilPenalizedIrls(y,cPhi,mu,A)
%% [mu, U, w, likelihood] = prtUtilPenalizedIrls(y,cPhi,mu,A)






nMaxIterations = 100; % Max outer iterations
gThreshold = 1e-6; % Termination criterion
nMaxStepSizeIterations = 20; % Per outer iteration how many steps to take
                             % Steps decrease by a factor of 1/2 each time
                            
% Get initial error just so we know where we started
[dataNegativeLogLikelihood, yHat] = modelError(y,cPhi,mu);
weightNegativeLogLikelihood = (diag(A)'*(mu.^2))/2; % mu'*A*mu
oldTotalNegativeLogLikelihood = dataNegativeLogLikelihood + weightNegativeLogLikelihood;

totalNegativeLogLikelihood = oldTotalNegativeLogLikelihood;
               
for iteration = 1:nMaxIterations
    % Calculate find direction to go in
    
    % Error gradient
    e = (y - yHat); % Eq. 10 of Nabney, 1999
    g = cPhi'*e - diag(A).*mu; % In paragraph above Eq. 10 of Nabney, 1999
    
    % Compute the likelihood-dependent analogue of the noise precision.
    w = yHat.*(1-yHat); % In paragraph above Eq. 10 of Nabney, 1999
    
    % Compute the Hessian
    cPhiBeta = bsxfun(@times,cPhi,w);
    H = (cPhiBeta'*cPhi + A);
    
    
    % Invert Hessian
    [U, pdErr] = chol(H);
    % Make sure its positive definite
    if pdErr
        error('Ill conditioned hessian. Consider modifying your basis')
    end
    
    % Check convergence
    if all(abs(g)<gThreshold)
        break
    end
    % Use chol decomp trick to invert nicely and calculate direction
    hessianInvDir = U \ (U' \ g); % inv(H)*g
    
    stepSize = 1;
    for stepIteration = 1:nMaxStepSizeIterations
        
        muStar = mu + stepSize*hessianInvDir;
        
        % Compute total error (negative log likelihood
        [dataNegativeLogLikelihood, yHat] = modelError(y,cPhi,muStar);
        weightNegativeLogLikelihood = (diag(A)'*(muStar.^2))/2;
        
        totalNegativeLogLikelihood = dataNegativeLogLikelihood + weightNegativeLogLikelihood;
        
        if totalNegativeLogLikelihood < oldTotalNegativeLogLikelihood
            break
        else
            % We made things worse so descrease the step size.
            stepSize = stepSize/2;
        end
    end
    
    if stepIteration == nMaxStepSizeIterations
        % Went to the max on the inner loop means we are around numerical
        % precision. So exit
        %warning('bad exit : %0.4f',totalNegativeLogLikelihood-oldTotalNegativeLogLikelihood)
        totalNegativeLogLikelihood = oldTotalNegativeLogLikelihood;
        break
    else
        % Keep going
        mu = muStar;
        oldTotalNegativeLogLikelihood = totalNegativeLogLikelihood;
    end
end


likelihood = -totalNegativeLogLikelihood;



function [negativeLogLikelihood, yHat] = modelError(y,cPhi,mu)

yHat = 1 ./ (1+exp(-cPhi*mu));

yHat0 = (yHat==0);
yHat1 = (yHat==1);
negativeLogLikelihood = -(y(~yHat0)'*log(yHat(~yHat0)) + (1-y(~yHat1))'*log(1-yHat(~yHat1)));

