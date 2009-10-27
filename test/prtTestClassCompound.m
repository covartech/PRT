function result = prtTestClassCompound

%%
result = true;
%%
opt{1} = prtPreProcOptZmuv;
opt{2} = {prtFeatSelOptExhaustive,prtClassOptFld};
opt{3} = prtClassOptRvmJeffreys;

DS = prtDataUnimodal;
DS = DS.setObservations([DS.getObservations,DS.getObservations + randn(size(DS.getObservations))]);

Algo = prtGenerate(DS,opt);

R = prtRun(Algo,DS);
