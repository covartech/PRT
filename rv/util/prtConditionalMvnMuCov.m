function [condMu,condCov] = prtConditionalMvnMuCov(x,indices,globalMu,globalCov)
%[condMu,condCov] = conditionalMuCov(x,indices,globalMu,globalCov)







indices2 = indices;
indices1 = setdiff(1:length(globalMu),indices);

mu2 = globalMu(indices2);
mu1 = globalMu(indices1);

cov22 = globalCov(indices2,indices2);
cov12 = globalCov(indices1,indices2);
cov21 = globalCov(indices2,indices1);
cov11 = globalCov(indices1,indices1);

condMu = mu1 + (cov12*cov22^-1*(x - mu2)')';
condCov = cov11 - cov12*cov22^-1*cov21; 
