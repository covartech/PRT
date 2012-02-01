function [U, S, V, AHat] = prtUtilSvdEm(A,k)
% [U, S, V, AHat] = prtUtilSvdEm(A,k)
% Preform SVD decomposition for a matrix with missing values
% Missing values should be represented by NaN

nMaxIterations = 50;
verbosePlot = true;
verboseText = true;
proportionChangeThreshold = 5e-5;

hasVote = ~isnan(A);

% Initialization
% Average of the row and col avergages
% I have no idea how good this is. It is the first thing I thought of
AHat = bsxfun(@plus,repmat(nanmean(A,2),1,size(A,2)),nanmean(A,1))/2;

logLike = nan(nMaxIterations,1);
for iter = 1:nMaxIterations
    % Set the true data where it belongs
    AHat(hasVote) = A(hasVote);
    oldAHatNoVote = AHat(~hasVote);
    
    % Perform SVD - ML's built in does not allow one to specify the number
    % to retain. This is really a limitation of LAPACK not ML.
    [U,S,V] = svd(AHat,0);
    U = U(:,1:k);
    S = S(1:k,1:k);
    V = V(:,1:k);
    
    % H = V(:,1:k); % From Zhang, 2005
    AHat = AHat*V(:,1:k)*V(:,1:k)';
    
    trueDataError = sum((A(hasVote)-AHat(hasVote)).^2);
    
    noiseVar = trueDataError/sum(hasVote(:));
    
    logLike(iter) = -1/(2*noiseVar) * (trueDataError + sum((oldAHatNoVote - AHat(~hasVote)).^2));
    
    if iter > 1
        proportionChange = (logLike(iter)-logLike(iter-1))/abs(mean(logLike((iter-1):iter)));
        if verboseText
            fprintf('Iteration %03d: Approx. LL: %0.4f: Percent Change: %0.3g\n', iter, logLike(iter), proportionChange*100);
        end
        if proportionChange < proportionChangeThreshold
            if verboseText
                fprintf('\t Percent Change: %0.3g below threshold %0.3g. Exiting\n', proportionChange*100, proportionChangeThreshold*100);
            end
            break
        end
    else
        if verboseText
            fprintf('\n');
            fprintf('Iteration %03d: Approx. LL: %0.4f\n', iter, logLike(iter));
        end
    end
    
    if verbosePlot
        subplot(2,2,1)
        imagesc(A,[1 5])
        title('Original Matrix');
        
        subplot(2,2,2)
        imagesc(AHat,[1 5])
        title('Estimated Full Matrix');
        
        subplot(2,2,3:4)
        plot(logLike);
        title('Prop. To Log Likelihood')
        drawnow;
    end
end