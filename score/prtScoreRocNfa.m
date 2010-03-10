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

% Author: Peter Torrione
% Revised by: Kenneth D. Morton Jr.
% Duke University, Department of Electrical and Computer Engineering
% Email Address: collinslab@gmail.com
% Created: unknown
% Last revision: 17-April-2006

% Revision: 17-April-2006
%   Added nPfSamples and nPdSamples to allow linear sampling along those
%   spaces as well as along the ROC space.  Also added long example
%   detailing how to use each to the help entry. Have not incorporated in a
%   new DPRT release; awaiting responses

% Revision: 27-June-2007
%   Change the calculation of auc to the proposed by Hand and Till, 2001
%   Don't ask me why I did this.


[pf,pd,auc,thresholds,classLabels] = prtScoreRoc(ds,y,varargin{:});
nMiss = length(find(y == 0));
nf = pf*nMiss;