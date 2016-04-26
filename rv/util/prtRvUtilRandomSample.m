function x = prtRvUtilRandomSample(probabilities, nSamples, population)
% prtRvUtilRandomSample - Draw from a population with specified probabilities
%
% x = prtRvUtilRandomSample(probabilities, nSamples, population)
% x = prtRvUtilRandomSample(nObjects, nSamples, population)








if numel(probabilities) == 1 % Assume nObjects
    assert(probabilities >= 1,'nObjects must be greater than or equal to 1');
    probabilities = 1./probabilities * ones(1,probabilities);
else
    if isempty(probabilities) && nargin > 2 && ~isempty(population)
        probabilities = ones(1,numel(population));
        probabilities = probabilities./sum(probabilities);
    end
    probabilities = probabilities(:)';
    assert(prtUtilApproxEqual(sum(probabilities),1,1e-6),'probabilities must sum to 1');
end

if nargin < 2 || isempty(nSamples)
    nSamples = 1;
end

[dontNeed, x] = histc(rand(nSamples,1),min([0 cumsum(probabilities)],1)); %#ok<ASGLU>

if nargin > 2
    x = population(x,:);
end
    
