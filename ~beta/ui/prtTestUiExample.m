close all
clear classes

load('ezTufDataSet','dsAmvn');
ds = dsAmvn;
clear dsAmvn;

figure
rocObj = prtUiRocSelector('prtDs', ds.retainFeatures(1));
figure
selectorObj = prtUiDataSetStandardObservationInfoSelect('prtDs',ds,'retainedObsUpdateCallback',@(x)updateRetainObs(rocObj, x));

%%

close all
clear classes

load('ezTufDataSet','dsAmvn');
ds = dsAmvn;
clear dsAmvn;

uiObj = prtUiRocExplorer(ds);
