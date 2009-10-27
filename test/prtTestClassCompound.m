function result = prtTestClassCompound

%%
result = true;
%%
opt{1} = prtPreProcOptZmuv;
opt{2} = {prtFeatSelOptExhaustive,prtPreProcOptZmuv};
opt{3} = prtClassOptFld;

DS = prtDataUnimodal;
DS = joinFeatures(DS,DS);

Algo = prtGenerate(DS,opt);

R = prtRun(Algo,DS);
