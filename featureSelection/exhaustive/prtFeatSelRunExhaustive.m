function [DS,Etc] = prtFeatSelRunExhaustive(prtFeatSelector,DS)
%DS = prtFeatSelRunExhaustive(prtFeatSelector,DS)
Etc = [];
DS = prtDataSet(DS,'data',DS.data(:,prtFeatSelector.selectedFeatures));
