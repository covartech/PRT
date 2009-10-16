function PrtFeatSelOpt = prtFeatSelOptExhaustive

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRIVATE STUFF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PrtFeatSelOpt.Private.featureSelectionName = 'Exhaustive Feature Selection';
PrtFeatSelOpt.Private.featureSelectionAbbreviation = 'EFS';
PrtFeatSelOpt.Private.generateFunction = @prtFeatSelGenExhaustive;
PrtFeatSelOpt.Private.runFunction = @prtFeatSelRunExhaustive;
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