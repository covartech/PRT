function result = prtTestRvMvn

result = true; % Haven't screwed up yet

%% Test if we can draw from an MVN RV and then estimate the same mean
trueMean = -2;
N = prtRvMvn(trueMean,1);
X = N.draw(1000);

NL = prtRvMvn(X);

cResult = abs(trueMean-NL.mean)< 0.1; % 0.1 is reasonable for 1000 samples with std=1

result = result & cResult; % Do this after each sub-test

%% More subtests?