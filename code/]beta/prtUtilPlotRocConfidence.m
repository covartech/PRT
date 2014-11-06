function varargout = prtUtilPlotRocConfidence(varargin)
% PRSCOREROCCONFIDENCEPLOT Plot ROCs with confidence
%
% Syntax: prtUtilPlotRocConfidence(PF1,PD1,edgePds1,PF2,PD2,edgePds2,...)
%         prtUtilPlotRocConfidence(PF1,PD1,edgePds1,'b',PF2,PD2,edgePds2,'r',...)
%
%   This is a little naive in that you cannot mix and match these two
%   input styles.
%
% Inputs:
%  PF - Probability of False Alarm vs threshold
%  PD - Probability of Detection vs threshold
%  edgePds - Upper and lower bounds on ROC curves
%             (see prtScoreRocBayesianBootStrap)
%
% Outputs:
%  h - The handles to plots and fills. Lines are in column 1 Fills in
%   columns 2.
%
% Example:
%  DS = prtDataGenUnimodal;
%  Class = prtClassFld;
%
%  Output = kfolds(Class,DS);
%  Output = prtDataSetClass(Output,DS);
%
%  [pfSamples, pdMean, pdConfRegion, pds] = prtScoreRocBayesianBootstrap(Output.getObservations() ,Output.getTargets());
%  prtUtilPlotRocConfidence(pfSamples,pdMean,pdConfRegion)

% Copyright (c) 2013 New Folder Consulting
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.



faceAlphaValue = 0.4;

PlotStruct = rocConfidencePlotInputParse(varargin{:});

holdState = ishold;
h = zeros(length(PlotStruct),2);

% Plot all of the fills first
for iPlot = 1:length(PlotStruct)
    h(iPlot,2) = fill(PlotStruct(iPlot).confPF(:),PlotStruct(iPlot).confPD(:),PlotStruct(iPlot).color,'FaceAlpha',faceAlphaValue);
    if iPlot == 1
        hold on
    end
end

for iPlot = 1:length(PlotStruct)
    if ischar(PlotStruct(iPlot).color)
        h(iPlot,1) = plot(PlotStruct(iPlot).PF,PlotStruct(iPlot).PD,PlotStruct(iPlot).color);
    else
        h(iPlot,1) = plot(PlotStruct(iPlot).PF,PlotStruct(iPlot).PD,'color',PlotStruct(iPlot).color);
    end
end

%axis([0 1 0 1])
ylim([0 1]) % Pd is always on y but FAR might be on X

if nargout > 0
    varargout = {h};
else
    varargout = {};
end
  

if ~holdState
    hold off
end

function PlotStruct = rocConfidencePlotInputParse(varargin)
% ROCCONFIDENCEPLOTINPUTPARSE

if nargin == 3
    nInputsPerPlot = 3;
    colors = lines(nargin/3);
else
    if ischar(varargin{4}) && ~mod(nargin,4); %specifying colors
        % Specifying line styles
        nInputsPerPlot = 4;
    elseif ~mod(nargin,3)
        nInputsPerPlot = 3;
        colors = lines(nargin/3);
    else
        error('Invalid input numbers')
    end
end

nPlots = nargin/nInputsPerPlot;

for iPlot = 1:nPlots
    PlotStruct(iPlot).PF = varargin{nInputsPerPlot*(iPlot-1) + 1};
    PlotStruct(iPlot).PD = varargin{nInputsPerPlot*(iPlot-1) + 2};
    PlotStruct(iPlot).confPD = varargin{nInputsPerPlot*(iPlot-1) + 3};
    PlotStruct(iPlot).confPD(:,2) = flipud(PlotStruct(iPlot).confPD(:,2));
    PlotStruct(iPlot).confPF = cat(2,PlotStruct(iPlot).PF, flipud(PlotStruct(iPlot).PF));
    
    % Flip these to conform to old code
    PlotStruct(iPlot).confPD = flipud(PlotStruct(iPlot).confPD);
    PlotStruct(iPlot).confPF = flipud(PlotStruct(iPlot).confPF);
    
    % Add extra points so that the edges of the resulting fill aren't slanty
    PlotStruct(iPlot).confPF = cat(1,cat(2,PlotStruct(iPlot).confPF(end,2),PlotStruct(iPlot).confPF(end,1)),PlotStruct(iPlot).confPF);
    PlotStruct(iPlot).confPD = cat(1,cat(2,PlotStruct(iPlot).confPD(1,1),PlotStruct(iPlot).confPD(1,2)),PlotStruct(iPlot).confPD);
    
    
    if nInputsPerPlot == 3
        PlotStruct(iPlot).color = colors(iPlot,:);
    else
        PlotStruct(iPlot).color = varargin{nInputsPerPlot*(iPlot-1) + 4};
    end
end
