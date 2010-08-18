function result = prtTestClassLogDisc

result = true; % Haven't screwed up yet

%% Test default KNN options on prtDataUnimodal
DS1 = prtDataUnimodal;
DS2 = prtDataUnimodal;

C = prtGenerate(DS1,prtClassOptLogDisc);

PrtClassOut = prtRun(C,DS2);
[pf,pd,auc] = roc(getObservations(PrtClassOut),getTargets(DS2));
cResult = auc > .9;

result = result & cResult; % Do this after each sub-test

