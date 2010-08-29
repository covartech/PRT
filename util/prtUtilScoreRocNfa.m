function [NF,PD] = prtUtilScoreRocNfa(varargin)
% rocNFA - Generate a PD vs. # FA pseudo-ROC curve.
%
%   Syntax: [NF,PD] = prtUtilScoreRocNfa(...)
%
%   Inputs:
%       See prtUtilScoreRoc.m
%
%   Outputs:
%       NF - double Vec - Similar to Pf (see prtUtilScoreRoc.m) but taking discrete integer values
%       corresponding to 1, 2, 3, ... N false alarms.
%       
%       PD - double Vec - Probability of detection
%
% Example:
%     X = cat(1,mvnrnd([0 0],eye(2),500),mvnrnd([2 2],[1 .5; .5 1],500));
%     Y = cat(1,zeros(500,1),ones(500,1)); 
%     DS = dprtKFolds(X,Y,optionsGLRT,200);
%     prtUtilScoreRocNfa(DS,Y)

% Copyright 2010, New Folder Consulting, L.L.C.

[PF,PD] = prtUtilScoreRoc(varargin{:});
Nmiss = length(find(varargin{2} == 0));
NF = PF*Nmiss;

%if there are no outputs; plot the ROC;
if nargout == 0
    plot(NF,PD);
    varargout = {};
else
    varargout = {NF, PD};
end