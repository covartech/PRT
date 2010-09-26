%% prtDataGenCircles
% This data generation method can be used to generate data from two
% hypotheses, where each hypothesis is drawn from a distribution of points
% with approximately equal radius from the origin.  This data set is
% problematic for classifiers with linear boundaries, and most parametric
% classification approaches.
%
% The output of this function is a prtDataSetClass.
%
% <matlab:doc('prtDataGenCircles') M-file documentation>
%
% <prtPublishDataGen.html prtDataGen Functions>
%
% <prtPublishGettingStarted.html Getting Started> 
%

ds = prtDataGenCircles;
plot(ds);

%%
% See also: 
% <prtPublishDataGenBimodal.html prtDataGenBimodal>
% <prtPublishDataGenCircles.html prtDataGenCircles>
% <prtPublishDataGenIris.html prtDataGenIris>
% <prtPublishDataGenManual.html prtDataGenManual>
% <prtPublishDataGenMary.html prtDataGenMary>
% <prtPublishDataGenNoisySinc.html prtDataGenNoisySinc>
% <prtPublishDataGenOldFaithful.html prtDataGenOldFaithful>
% <prtPublishDataGenPca.html prtDataGenPca>
% <prtPublishDataGenProstate.html prtDataGenProstate>
% <prtPublishDataGenSinc.html prtDataGenSinc>
% <prtPublishDataGenSpiral.html prtDataGenSpiral>
% <prtPublishDataGenSpiral3.html prtDataGenSpiral3>
% <prtPublishDataGenSwissRoll.html prtDataGenSwissRoll>
% <prtPublishDataGenUnimodal.html prtDataGenUnimodal>
% <prtPublishDataGenXor.html prtDataGenXor>
% <prtPublishDataGenBimodal prtDataGenBimodal>
% <prtPublishDataGenCircles prtDataGenCircles>
% <prtPublishDataGenIris prtDataGenIris>
% <prtPublishDataGenManual prtDataGenManual>
% <prtPublishDataGenMary prtDataGenMary>
% <prtPublishDataGenNoisySinc prtDataGenNoisySinc>
% <prtPublishDataGenOldFaithful prtDataGenOldFaithful>
% <prtPublishDataGenPca prtDataGenPca>
% <prtPublishDataGenProstate prtDataGenProstate>
% <prtPublishDataGenSinc prtDataGenSinc>
% <prtPublishDataGenSpiral prtDataGenSpiral>
% <prtPublishDataGenSpiral3 prtDataGenSpiral3>
% <prtPublishDataGenSwissRoll prtDataGenSwissRoll>
% <prtPublishDataGenUnimodal prtDataGenUnimodal>
% <prtPublishDataGenXor prtDataGenXor>