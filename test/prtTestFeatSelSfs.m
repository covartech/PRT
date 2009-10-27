function result = prtTestFeatSelSfs

%%
result = true;
%%

DS = prtDataUnimodal;
DS = DS.setObservations([DS.getObservations,DS.getObservations + randn(size(DS.getObservations))*10]);

opt = prtFeatSelOptSfs;
opt.nFeatures = 4;

Algo = prtGenerate(DS,opt);

R = prtRun(Algo,DS);
