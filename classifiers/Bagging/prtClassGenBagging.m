function PrtBagging = prtClassGenBagging(DS,ClassifierOptions)

PrtBagging.PrtDataSet = DS;
PrtBagging.PrtOptions = ClassifierOptions;
for i = 1:ClassifierOptions.nBags
    PrtBagging.Classifiers(i) = prtGenerate(DS.bootstrap(DS.nObservations),ClassifierOptions.ClassifierOptions);
end