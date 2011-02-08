%% prtDataOldFaithful
%
% This data generation method can be used to generate a data set containing
% measurements of eruptions from Yellowstone's Old Faithful geyser.  The
% data is unlabeled, but can be seen to come from two distinct clusters in
% terms of the two measured features - eruption time (m), and waiting time
% between eruptions (m).
%
% The output of this function is an unlabeled prtDataSetClass.
%
% <matlab:doc('prtDataOldFaithful') M-file documentation>
%
% <prtPublishDataGen.html prtDataGen Functions>
%
% <prtPublishGettingStarted.html Getting Started> 
%

ds = prtDataGenOldFaithful;
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
% <prtPublishDataGenProstate.html prtDataGenProstate>
% <prtPublishDataGenSpiral.html prtDataGenSpiral>
% <prtPublishDataGenSpiral3.html prtDataGenSpiral3>
% <prtPublishDataGenSwissRoll.html prtDataGenSwissRoll>
% <prtPublishDataGenUnimodal.html prtDataGenUnimodal>
% <prtPublishDataGenXor.html prtDataGenXor>
