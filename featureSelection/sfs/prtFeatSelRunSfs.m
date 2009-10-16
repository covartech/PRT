function DS = prtFeatSelRunSfs(prtFeatSelector,DS)
%DS = prtFeatSelRunSfs(prtFeatSelector,DS)

DS = prtDataSet(DS,'data',DS.data(:,prtFeatSelector.selectedFeatures));
