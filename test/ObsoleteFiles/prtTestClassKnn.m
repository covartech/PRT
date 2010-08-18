function result = prtTestClassKnn
%%

result = true; % Haven't screwed up yet

% Test default KNN options on prtDataUnimodal
DS1 = prtDataUnimodal;
DS2 = prtDataUnimodal;

worstCaseErrorRate = 0.1; % An edjucated guess

C = train(prtClassKnn,DS1);
DSOutput = C.run(DS2);


cResult = abs(sum((DSOutput.getObservations() > C.k/2) - DS2.getTargets)./DS2.nObservations) < worstCaseErrorRate;

result = result & cResult; % Do this after each sub-test

%%
DSOutput = kfolds(prtClassKnn('k',21),DS1,10);

cResult = abs(sum((DSOutput.getObservations() > C.k/2) - DS1.getTargets)./DS1.nObservations) < worstCaseErrorRate;

result = result & cResult; % Do this after each sub-test