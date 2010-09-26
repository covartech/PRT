function [nf,pd,auc,thresholds,classLabels] = prtScoreRocNfa(ds,y,varargin)
% rocNFA - Generate a PD vs. # FA pseudo-ROC curve.
%
%   Syntax: [NF,PD] = rocNfa(...)
%
%   Inputs:
%       See roc.m
%
%   Outputs:
%       NF - double Vec - Similar to Pf (see roc.m) but taking discrete integer values
%       corresponding to 1, 2, 3, ... N false alarms.
%       
%       PD - double Vec - Probability of detection
%

% Copyright 2010, New Folder Consulting, L.L.C.

[pf,pd,auc,thresholds,classLabels] = prtScoreRoc(ds,y,varargin{:});
nMiss = length(find(y == 0));
nf = pf*nMiss;

if nargout == 0
    plot(nf,pd);
    xlabel('#FA');
    ylabel('Pd');
    clear pf pd auc thresholds classLabels
end
