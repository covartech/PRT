close all
clear classes

selectionDataSet = nfHvscXls2PartDataSetClass(fullfile(hvscRoot,'util','truth','hvscDataDescription.csv'));

uiObj = prtUiDataSetStandardObservationInfoSelect(selectionDataSet.observationInfo);
%%
