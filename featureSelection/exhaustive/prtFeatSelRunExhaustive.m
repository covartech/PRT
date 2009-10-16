function DS = prtFeatSelRunExhaustive(prtFeatSelector,DS)
%DS = prtFeatSelRunExhaustive(prtFeatSelector,DS)

DS = prtDataSet(DS,'data',DS.data(:,prtFeatSelector.selectedFeatures));
