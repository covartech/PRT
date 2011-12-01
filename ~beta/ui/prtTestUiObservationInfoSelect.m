close all
clear classes

selectionDataSet = nfHvscXls2PartDataSetClass(fullfile(hvscRoot,'util','truth','hvscDataDescription.csv'));

uiObj = prtUiDataSetStandardObservationInfoSelect(selectionDataSet.observationInfo);
%%
clear classes
close all

selectionDataSet = prtDataGenNcaaFootball2010_records;
selectionDataSet = selectionDataSet.select(@(S)((S.awayGames>=8) & (S.homeGames>=8) & ~S.includesSubDivisionTeam));
%%
uiObj = prtUiDataSetStandardObservationInfoSelect(selectionDataSet.observationInfo);
%%
uiObj = prtUiStructureTable(selectionDataSet.observationInfo);

%%
close all
clear classes

selectionDataSet = prtDataGenGlass;
%uiObj = prtUiStructureTable(selectionDataSet.observationInfo);
uiObj = prtUiDataSetStandardObservationInfoSelect(selectionDataSet.observationInfo);
%%