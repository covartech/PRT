function [DS,Etc] = prtFeatSelRunSfs(prtFeatSelector,DS)
%DS = prtFeatSelRunSfs(prtFeatSelector,DS)

Etc = [];
DS = DS.retainFeatures(prtFeatSelector.selectedFeatures);
