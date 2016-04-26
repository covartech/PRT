function [U, S, V, AHat] = prtUtilSvdEm(A,k,varargin)
% [U, S, V, AHat] = prtUtilSvdEm(A,k)
% Preform SVD decomposition for a matrix with missing values
% Missing values should be represented by NaN






p = inputParser;
p.addParamValue('nMaxIterations',100);
p.addParamValue('verbosePlot', false);
p.addParamValue('verboseText', false);
p.addParamValue('proportionChangeThreshold', 5e-5);

p.parse(varargin{:});

nMaxIterations = p.Results.nMaxIterations;
verbosePlot = p.Results.verbosePlot;
verboseText = p.Results.verboseText;
proportionChangeThreshold = p.Results.proportionChangeThreshold;

hasVote = ~isnan(A);

% Initialization
% Average of the row and col avergages
% I have no idea how good this is. It is the first thing I thought of
AHat = bsxfun(@plus,repmat(nanmean(A,2),1,size(A,2)),nanmean(A,1))/2;
AHat(isnan(AHat)) = 0; % All nan rows or columns will still have nans. Set to 0?

logLike = nan(nMaxIterations,1);
for iter = 1:nMaxIterations
    % Set the true data where it belongs
    AHat(hasVote) = A(hasVote);
    oldAHatNoVote = AHat(~hasVote);
    
    [U,S,V] = svds(AHat,k);
    AHat = AHat*(V*V');
    
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
