%% PRT: Pattern Recognition Tools for MATLAB
% The PRT is an object oriented approach to pattern recognition in MATLAB.
% An object oriented approach unifies the syntax of many of the various
% components of typical pattern recognition algorithms. This unified syntax
% allows you to rapidly interchange components to optimize performance.

%% Getting Started Quickly
% To get started quickly, check out the <prtPublishGettingStarted.html
% Getting Started Guide>. This will walk you through some of the most
% common things you will do with the PRT and get you acquainted with the
% most common PRT objects.

%% PRT Organization
% As an object oriented approach, the PRT is organized into classes and
% subclasses. You can use this table of contents to start your  exploration
% about each of the base classes in the PRT, their subclasses and learn how
% to create your own subclasses to create custom components that work in
% harmony with the rest of the PRT. For a more detailed description of the
% structure of PRT see <prtPublishToolboxStructure.html Toolbox
% Structure>.

%% PRT Organization Outline
% <html>
% <ul>
%   <li> <a href="prtPublishDataSetBase.html"> prtDataSetBase </a>
%   <ul>
%       <li> <a href="prtPublishDataSetStandard.html"> prtDataSetStandard </a>
%       <ul>
%           <li> <a href="prtPublishDataSetRegress.html"> prtDataSetRegress </a>
%           <li> <a href="prtPublishDataSetClass.html"> prtDataSetClass </a>
%       </ul>
%   </ul>
%   <li> <a href="prtPublishDataGen.html"> prtDataGen* </a>
%   <ul>
%       <li> <a href="prtPublishDataGenUnimodal.html"> prtDataGenUnimodal </a> 
%       <li> <a href="prtPublishDataGenBimodal.html"> prtDataGenBimodal </a> 
%       <li> <a href="prtPublishDataGenCircles.html"> prtDataGenCircles </a>
%       <li> <a href="prtPublishDataGenIris.html"> prtDataGenIris </a>
%       <li> <a href="prtPublishDataGenOldFaithful.html"> prtDataGenOldFaithful </a>
%   </ul>
%   <li> prtAction
%   <ul>
%       <li> prtAlgorithm
%       <li> prtClass
%       <ul>
%           <li> prtClassAdaBoost
%           <li> prtClassBagging
%           <li> prtClassBinaryToMaryOneVsAll
%           <li> prtClassBumping
%           <li> prtClassCap
%           <li> prtClassDlrt
%           <li> prtClassFld
%           <li> prtClassGlrt
%           <li> prtClassKmeansPrototypes
%           <li> prtClassKmsd
%           <li> prtClassKnn
%           <li> prtClassLibSvm
%           <li> prtClassLogisticDiscriminant
%           <li> prtClassMap
%           <li> prtClassMatlabNnet
%           <li> prtClassMatlabTreeBagger
%           <li> prtClassNaiveBayes
%           <li> prtClassPlsda
%           <li> prtClassRvm
%           <li> prtClassRvmFigueiredo
%           <li> prtClassRvmSequential
%           <li> prtClassSvm
%           <li> prtClassTreeBaggingCap
%       </ul>
%       <li> prtRegress
%       <ul>
%           <li> prtRegressLslr
%           <li> prtRegressGP
%           <li> prtRegressRvm
%           <li> prtRegressRvmSequential
%       </ul>
%       <li> prtPreProc
%       <ul>
%           <li> prtPreProcEnergyNorm
%           <li> prtPreProcHistEq
%           <li> prtPreProcHistEqKde
%           <li> prtPreProcLda
%           <li> prtPreProcLogDisc
%           <li> prtPreProcMinMaxRows
%           <li> prtPreProcNstdOutlierRemove
%           <li> prtPreProcPca
%           <li> prtPreProcPls
%           <li> prtPreProcSharpen
%           <li> prtPreProcZeroMeanColumns
%           <li> prtPreProcZeroMeanRows
%           <li> prtPreProcZeroMinRows
%           <li> prtPreProcZmuv
%       </ul>
%       <li> prtFeatSel
%       <ul>
%           <li> prtFeatSelExhaustive
%           <li> prtFeatSelStatic
%           <li> prtFeatSelSfs
%       </ul>
%       <li> prtCluster
%       <ul>
%           <li> prtClusterKmeans
%           <li> prtClusterGmm
%       </ul>
%       <li> prtDecision
%       <ul>
%           <li> prtDecisionBinaryMinPe
%           <li> prtDecisionBinarySpecifiedPd
%           <li> prtDecisionBinarySpecifiedPf
%           <li> prtDecisionMap
%           <li> Writing your own prtDecision
%       </ul>
%       <li> Writing your own prtAction
%   </ul>
%   <li> prtScore*
%   <ul>
%       <li> prtScoreAuc
%       <li> prtScoreConfusionMatrix
%       <li> prtScoreRoc
%       <li> prtScoreCost
%       <li> prtScorePercentCorrect
%       <li> prtScoreRmse
%       <li> prtScoreRocNfa
%   </ul>
%   <li> prtEval*
%   <ul>
%       <li> prtEvalAuc
%       <li> prtEvalMinCost
%       <li> prtEvalPdAtPf
%       <li> prtEvalPercentCorrect
%       <li> prtEvalPfAtPd
%   </ul>
%   <li> prtRv
%   <ul>
%       <li> prtRvDiscrete
%       <li> prtRvGmm
%       <li> prtRvIndependent
%       <li> prtRvKde
%       <li> prtRvMixture
%       <li> prtRvMultinomial
%       <li> prtRvMvn 
%       <li> prtRvUniform
%       <li> prtRvUniformImproper
%       <li> prtRvVq
%       <li> Writing your own prtRv
%   </ul> 
%   <li> prtKernel
%   <ul>
%       <li> prtKernelUnary
%       <ul>
%           <li> prtKernelDc
%           <li> prtKernelDirect
%       </ul>
%       <li> prtKernelBinary
%       <ul>
%           <li> prtKernelPolynomial
%           <li> prtKernelRbf
%           <li> prtKernelRbfDimensionalScale
%       </ul>
%       <li> Writing your own prtKernel
%   </ul>
%   <li> Writing your own prtAction
% </ul>
% </html>