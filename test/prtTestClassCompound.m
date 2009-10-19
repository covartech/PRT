function result = prtTestClassCompound

%%
result = true;
%%
opt{1} = prtPreProcOptZmuv;
opt{2} = {prtFeatSelOptExhaustive,prtPreProcOptZmuv};
opt{3} = prtClassOptFld;

DS = prtDataUnimodal;
DS = prtDataSetLabeled(DS,DS);
DS = prtDataSetLabeled(DS.data + randn(size(DS.data))*2,DS.dataLabels);

Algo = prtGenerate(DS,opt);

R = prtRun(Algo,DS);
