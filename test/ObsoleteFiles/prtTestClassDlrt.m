function result = prtTestClassDlrt

result = true; % Haven't screwed up yet

%% Test default KNN options on prtDataGenUnimodal
DS1 = prtDataGenUnimodal;
DS2 = prtDataGenUnimodal;

C = prtGenerate(DS1,prtClassOptDlrt);

PrtClassOut = prtRun(C,DS2);
[pf,pd,auc] = roc(getObservations(PrtClassOut),getTargets(DS2));
cResult = auc > .9;

result = result & cResult; % Do this after each sub-test

