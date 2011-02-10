%% prtDataGenSwissRoll
%
% This data generation method can be used to generate a data set containing
% data from the classic Swiss-Roll data set.  This data is drawn from a 2-D
% manifold embedded in 3-dimensions.  The 2-D manifold locations are in
% ds.getTargets, and the 3-dimensional embedding is in ds.getObservations.
%
% The output of this function is a prtDataSetRegress.
%
% <matlab:doc('prtDataGenSwissRoll') M-file documentation>
%
% <prtPublishDataGen.html prtDataGen Functions>
%
% <prtPublishGettingStarted.html Getting Started> 
%   

ds = prtDataGenSwissRoll;
x = ds.getObservations;
y = ds.getTargets;
x = x(1:20:end,:);
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
