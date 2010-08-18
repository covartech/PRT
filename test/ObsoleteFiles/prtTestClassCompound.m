function result = prtTestClassCompound

%%
result = true;
%%
DS = prtDataUnimodal;
DS = DS.setObservations([DS.getObservations,DS.getObservations + randn(size(DS.getObservations))]);

opt{1} = prtPreProcZmuv;
opt{2} = {prtFeatSelExhaustive,prtClassFld};
opt{3} = prtClassRvm;

Algo = prtAlgorithm(opt);
Algo = Algo.train(DS);

yOut = Algo.run(DS);
