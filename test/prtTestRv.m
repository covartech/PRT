%% MVN
R = prtRvMvn;
R = prtRvMvn(randn(10,2));
R = prtRvMvn('covarianceStructure','diagonal');
R = prtRvMvn(bsxfun(@plus,randn(100,2),[10 5]),'covarianceStructure','spherical');

plotPdf(R)
%% Multinomial (Discrete)

R = prtRvMultinomial;
R = prtRvMultinomial([100 90 10]);
R = prtRvMultinomial(R.draw(100));

plotCdf(R)

%% Mixture with MVN 2D

N(1) = prtRvMvn('Mean',1*[-1 -1],'Covariance',[2 -0.9; -0.9 1]);
N(2) = prtRvMvn('Mean',1*[1 1],'Covariance',[1 0.2; 0.2 2]);

GMM = prtRvMixture('components',N,'mixingProportions',prtRvMultinomial('probabilities',[0.7 0.3]));

plotPdf(GMM)
title('Truth')

[X,Y] = GMM.draw(1000);
LGMM = prtRvMixture(X,'components',repmat(prtRvMvn,2,1));

figure
plotPdf(LGMM);
title('Learned')
%% Mixture with MVN 1D

N(1) = prtRvMvn('Mean',-19,'Covariance',2);
N(2) = prtRvMvn('Mean',1,'Covariance',1);

GMM = prtRvMixture('components',N,'mixingProportions',prtRvMultinomial('probabilities',[0.7 0.3]));

plotPdf(GMM)
title('Truth')

[X,Y] = GMM.draw(1000);
LGMM = prtRvMixture(X,'components',repmat(prtRvMvn,2,1));

figure
plotCdf(LGMM);
title('Learned')

%% GMM

LGMM2 = prtRvGmm(X,'nComponents',2);

plotPdf(LGMM2)
title('GMM')
%%

R = prtRvUniform('upperBounds',[2 3],'lowerBounds',[0 2]);

plotCdf(R,[-2 0 4 5])

%%

R = prtRvUniform(draw(prtRvMvn('Mean',1,'Covariance',1),100));

plotPdf(R)