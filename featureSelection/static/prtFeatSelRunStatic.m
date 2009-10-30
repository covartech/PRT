function [DS,Etc] = prtFeatSelRunStatic(prtFeatSelector,DS)
%DS = prtFeatSelRunSfs(prtFeatSelector,DS)

Etc = [];
DS = DS.retainFeatures(prtFeatSelector.selectedFeatures);
