function prtFeatSelector = prtFeatSelGenStatic(DS,PrtFeatSelOpt) %#ok<INUSL>
%prtFeatSelector = prtFeatSelGenStatic(DS,PrtFeatSelOpt)

prtFeatSelector.performance = nan;
prtFeatSelector.selectedFeatures = PrtFeatSelOpt.selectedFeatures;
prtFeatSelector.PrtOptions = PrtFeatSelOpt;