function PrtFeatSelOpt = prtFeatSelOptSfs

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRIVATE STUFF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PrtFeatSelOpt.Private.featureSelectionName = 'Sequential Forward Search';
PrtFeatSelOpt.Private.featureSelectionAbbreviation = 'SFS';
PrtFeatSelOpt.Private.generateFunction = @prtFeatSelGenSfs;
PrtFeatSelOpt.Private.runFunction = @prtFeatSelRunSfs;
PrtFeatSelOpt.Private.supervised = true;
PrtFeatSelOpt.Private.nativeMaryCapable = true;  %let the classifier worry about that
PrtFeatSelOpt.Private.nativeBinaryCapable = true;
PrtFeatSelOpt.Private.PrtObjectType = 'featureSelector';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PrtFeatSelOpt.nFeatures = 3;
PrtFeatSelOpt.EvaluationMethod = 'wrapper';
PrtFeatSelOpt.EvaluationMetric = @(DS)prtScoreAuc(DS,prtClassOptFld);
PrtFeatSelOpt.showProgressBar = true;