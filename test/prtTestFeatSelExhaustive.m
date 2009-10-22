function result = prtTestFeatSelExhaustive

%%
result = true;
%%

DS = prtDataUnimodal;
DS = prtDataSetLabeled(DS,DS);
DS = prtDataSetLabeled(DS.data + randn(size(DS.data))*2,DS.dataLabels);

opt = prtFeatSelOptExhaustive;
opt.nFeatures = 4;

Algo = prtGenerate(DS,opt);

R = prtRun(Algo,DS);
