function PrtFeatSelOpt = prtFeatSelOptStatic(selectedFeatures)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRIVATE STUFF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PrtFeatSelOpt.Private.featureSelectionName = 'Static Feature Selection';
PrtFeatSelOpt.Private.featureSelectionAbbreviation = 'Static';
PrtFeatSelOpt.Private.generateFunction = @prtFeatSelGenStatic;
PrtFeatSelOpt.Private.runFunction = @prtFeatSelRunStatic;
PrtFeatSelOpt.Private.supervised = true;
PrtFeatSelOpt.Private.nativeMaryCapable = true;  %let the classifier worry about that
PrtFeatSelOpt.Private.nativeBinaryCapable = true;
PrtFeatSelOpt.Private.PrtObjectType = 'featureSelector';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin == 0
    PrtFeatSelOpt.selectedFeatures = 1;
else
    PrtFeatSelOpt.selectedFeatures = selectedFeatures;
end
PrtFeatSelOpt.showProgressBar = true;