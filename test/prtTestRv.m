%% MVN
R = prtRvMvn;
R = prtRvMvn(randn(10,2));
R = prtRvMvn('covarianceStructure','diagonal');
R = prtRvMvn(bsxfun(@plus,mvnrnd([0 1],[1 0.2; 0.2 2],100),[10 5]),'covarianceStructure','spherical');

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
title('Learned');
hold on;
plot(prtDataSetClass(X,Y));
hold off;

%% Mixture with MVN 1D

N(1) = prtRvMvn('Mean',-19,'Covariance',2);
N(2) = prtRvMvn('Mean',1,'Covariance',1);

GMM = prtRvMixture('components',N,'mixingProportions',prtRvMultinomial('probabilities',[0.7 0.3]));

plotCdf(GMM)
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

R = prtRvUniform('lowerBounds',[0 0],'upperBounds',[1 1]);

plotCdf(R,[-2 4 0 5])

%%

R = prtRvUniform(draw(prtRvMvn('Mean',[1 2],'Covariance',2*eye(2)),100));

plotPdf(R)
%%

R = prtRvUniformImproper(draw(prtRvMvn('Mean',[1 2],'Covariance',2*eye(2)),100));
plotPdf(R)

%% 

R = prtRvDiscrete('symbols',(10:12)','probabilities',[0.3 0.3 0.4]);

R2 = R.mle(R.draw(1000));
plotCdf(R2);

%%

R = prtRvDiscrete('symbols',(10:12)','probabilities',[0.3 0.3 0.4]);

R2 = R.mle(R.draw(1000));
plotCdf(R2);

R.pdf(R.draw(1000))
%%

R = prtRvDiscrete('symbols',randn(3,10),'probabilities',[0.3 0.3 0.4]);

R2 = R.mle(R.draw(1000));
plotCdf(R2);

R.pdf(R.draw(1000))
%%

N(1) = prtRvMvn('Mean',1*[-1 -1],'Covariance',[2 -0.9; -0.9 1]);
N(2) = prtRvMvn('Mean',1*[1 1],'Covariance',[1 0.2; 0.2 2]);

GMM = prtRvMixture('components',N,'mixingProportions',prtRvMultinomial('probabilities',[0.4 0.6]));

plotPdf(GMM)
title('Truth')

[X,Y] = GMM.draw(1000);


LGMM2 = prtRvGmm(X,'nComponents',2,'covariancePool',true,'covarianceStructure','diag');

plotPdf(LGMM2)
title('GMM')
hold on;
plot(prtDataSetClass(X,Y));
hold off;
%%


N(1) = prtRvMvn('Mean',1*[-1 -1],'Covariance',[2 -0.9; -0.9 1]);
N(2) = prtRvMvn('Mean',1*[1 1],'Covariance',[1 0.2; 0.2 2]);

GMM = prtRvMixture('components',N,'mixingProportions',prtRvMultinomial('probabilities',[0.4 0.6]));

plotPdf(GMM)
title('Truth')

[X,Y] = GMM.draw(1000);
%%

R = prtRvVq(X,'nCategories',100);

R.pdf(R.draw(10))