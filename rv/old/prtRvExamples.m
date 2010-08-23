%%
N(1) = prtRvMvn(-2,1);
N(2) = prtRvMvn(2,1);

GMM = prtRvMixture(N,[0.6 0.4]);

[X, Y] = draw(GMM,200);
LGMM = prtRvMixture(2,prtRvMvn,X);

%%
N(1) = prtRvMvn(1*[-1 -1],[2 -0.9; -0.9 1]);
N(2) = prtRvMvn(1*[1 1],[1 0.2; 0.2 2]);

GMM = prtRvMixture(N,[0.5 0.5]);

figure
ezPdfPlot(GMM)
title('Truth')

[X,Y] = GMM.draw(1000);
LGMM = prtRvGmm(2,X);

figure
ezPdfPlot(LGMM);
title('Learned')
%%
