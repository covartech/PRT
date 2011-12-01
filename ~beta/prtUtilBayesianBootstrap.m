function [boot, sampleIndices, weights] = prtUtilBayesianBootstrap(population,nSamples)
% xxx Need Help xxx

if nargin < 2 || isempty(nSamples)
    nSamples = size(population,1);
end

weights = prtRvUtilDirichletDraw(ones(1,size(population,1)),1);

sampleIndices = randsample(1:size(population,1),nSamples,true,weights);

boot = population(sampleIndices,:);