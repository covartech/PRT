function DataSet = prtDataGenMovieLens
% prtDataGenMovieLens  Reads the Movie Lens 100,000 data set
%
%   DataSet = prtDataGenMovieLens generates a prtDataSetClass from the
%   Movie Lens 100,000 data set.
% 
%   http://www.grouplens.org/node/73
%
%   Example:
%
%   ds = prtDataGenMovieLens;
%
%   See also: prtDataSetClass, prtDataGenBiModal, prtDataGenIris,
%   prtDataGenManual, prtDataGenMary, prtDataGenNoisySinc,
%   prtDataGenOldFaithful,prtDataGenProtate, prtDataGenSprial,
%   prtDataGenSpiral3Regress, prtDataGenUnimodal, prtDataGenSwissRoll,
%   prtDataGenUnimodal, prtDataGenXor







Loaded = load('prtDataGenMovieLensSave.mat');

DataSet = Loaded.ds;
