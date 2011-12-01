%% prtDataGenSpiral3
%
% This data generation method can be used to generate a data set containing
% data from a spiraling distribution.  This data is a regression data set,
% and the third dimension of the data (z) can be regressed to using the
% data set observations.
%
% The output of this function is a prtDataSetRegress.
%
% <matlab:doc('prtDataGenSpiral3') M-file documentation>
%
% <prtPublishDataGen.html prtDataGen Functions>
%
% <prtPublishGettingStarted.html Getting Started> 
%

ds = prtDataGenSpiral3;
x = ds.getObservations;
plot3(x(:,1),x(:,2),x(:,3),'b.');

%%
% See also: 
% <prtPublishDataGenBimodal.html prtDataGenBimodal>
% <prtPublishDataGenCircles.html prtDataGenCircles>
% <prtPublishDataGenIris.html prtDataGenIris>
% <prtPublishDataGenManual.html prtDataGenManual>
% <prtPublishDataGenMary.html prtDataGenMary>
% <prtPublishDataGenNoisySinc.html prtDataGenNoisySinc>
% <prtPublishDataGenOldFaithful.html prtDataGenOldFaithful>
% <prtPublishDataGenProstate.html prtDataGenProstate>
% <prtPublishDataGenSpiral.html prtDataGenSpiral>
% <prtPublishDataGenSpiral3.html prtDataGenSpiral3>
% <prtPublishDataGenSwissRoll.html prtDataGenSwissRoll>
% <prtPublishDataGenUnimodal.html prtDataGenUnimodal>
% <prtPublishDataGenXor.html prtDataGenXor>
