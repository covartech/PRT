function result = prtTestRv

result = true;

try
    figure
    
    %% MVN
    R = prtRvMvn;
    R = mle(prtRvMvn,randn(10,2));
    R.covarianceStructure = 'diagonal';
    
    plotPdf(R)
    %% Multinomial (Discrete)
    
    R = prtRvMultinomial;
    R = mle(prtRvMultinomial,[100 90 10]);
    R = mle(prtRvMultinomial,R.draw(100));
    
    plotPdf(R)
    
    %% Mixture with MVN 2D
    
    N(1) = prtRvMvn('mu',1*[-1 -1],'sigma',[2 -0.9; -0.9 1]);
    N(2) = prtRvMvn('mu',1*[1 1],'sigma',[1 0.2; 0.2 2]);
    
    GMM = prtRvMixture('components',N,'mixingProportions',prtRvMultinomial('probabilities',[0.7 0.3]));
    
    plotPdf(GMM)
    title('Truth')
    
    [X,Y] = GMM.draw(1000);
    LGMM = mle(prtRvMixture('components',repmat(prtRvMvn,2,1)),X);
    
    plotPdf(LGMM);
    title('Learned');
    hold on;
    plot(prtDataSetClass(X,Y));
    hold off;
    
    %% Mixture with MVN 1D
    
    N(1) = prtRvMvn('mu',-19,'sigma',2);
    N(2) = prtRvMvn('mu',1,'sigma',1);
    
    GMM = prtRvMixture('components',N,'mixingProportions',prtRvMultinomial('probabilities',[0.7 0.3]));
    
    plotCdf(GMM)
    title('Truth')
    
    [X,Y] = GMM.draw(1000);
    LGMM = mle(prtRvMixture('components',repmat(prtRvMvn,2,1)),X);
    
    plotCdf(LGMM);
    title('Learned')
    
    %% GMM
    
    LGMM2 = mle(prtRvGmm('nComponents',2),X);
    
    plotPdf(LGMM2)
    title('GMM')
    %%
    
    R = prtRvUniform('lowerBounds',[0 0],'upperBounds',[1 1]);
    
    plotCdf(R,[-2 4 0 5])
    
    %%
    
    R = mle(prtRvUniform,draw(prtRvMvn('mu',[1 2],'sigma',2*eye(2)),100));
    
    plotPdf(R)
    %%
    
    R = mle(prtRvUniformImproper,draw(prtRvMvn('mu',[1 2],'sigma',2*eye(2)),100));
    plotPdf(R)
    
    %%
    
    R = prtRvDiscrete('symbols',(10:12)','probabilities',[0.3 0.3 0.4]);
    
    R2 = R.mle(R.draw(1000));
    plotPdf(R2);
    
    %%
    
    R = mle(prtRvDiscrete,draw(prtRvMvn('mu',[1 2],'sigma',2*eye(2)),100));
    
    plotPdf(R);
    
    %%
    
    N(1) = prtRvMvn('mu',1*[-1 -1],'sigma',[2 -0.9; -0.9 1]);
    N(2) = prtRvMvn('mu',1*[1 1],'sigma',[1 0.2; 0.2 2]);
    
    GMM = prtRvMixture('components',N,'mixingProportions',prtRvMultinomial('probabilities',[0.4 0.6]));
    
    plotPdf(GMM)
    title('Truth')
    
    [X,Y] = GMM.draw(1000);
    
    
    LGMM2 = mle(prtRvGmm('nComponents',2,'covariancePool',true,'covarianceStructure','diag'),X);
    
    plotPdf(LGMM2)
    title('GMM')
    hold on;
    plot(prtDataSetClass(X,Y));
    hold off;
    %%
    
    
    N(1) = prtRvMvn('mu',1*[-1 -1],'sigma',[2 -0.9; -0.9 1]);
    N(2) = prtRvMvn('mu',1*[1 1],'sigma',[1 0.2; 0.2 2]);
    
    GMM = prtRvMixture('components',N,'mixingProportions',prtRvMultinomial('probabilities',[0.4 0.6]));
    
    plotPdf(GMM)
    title('Truth')
    
    [X,Y] = GMM.draw(1000);
    %%
    
    R = mle(prtRvVq('nCategories',100),X);
    
    R.pdf(R.draw(10));
    close;
catch
    result = false;
end