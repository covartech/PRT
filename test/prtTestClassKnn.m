function result = prtTestClassKnn

result = true; % Haven't screwed up yet

%% Test default KNN options on prtDataUnimodal
DS1 = prtDataUnimodal;
DS2 = prtDataUnimodal;

C = prtGenerate(DS1,prtClassOptKnn);

DS = prtRun(C,DS2);

cResult = abs(sum(DS.MapGuess-DS2.getLabels)./DS2.nObservations)< 0.1; % 0.1 is reasonable for this dataset

result = result & cResult; % Do this after each sub-test

