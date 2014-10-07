classdef prtDecisionBinaryBootstrapDataAtPd < prtDecisionBinary

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
    properties (SetAccess = private)

        name = 'BootstrapDataAtPd'
        nameAbbreviation = 'BSDPD';
    end
    
    properties
        pd = 1;
        nFolds
        confidence = 0.95;
        nBootStrapSamples = [];
        ThresholdSetSummary
        
        algorithm
        threshold
    end
    
    methods
        function Obj = prtDecisionBinaryBootstrapDataAtPd(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
        function threshold = getThreshold(Obj)
            threshold = Obj.threshold;
        end
    end
    methods (Access=protected,Hidden=true)
        function Obj = trainAction(Obj, DS)
            
            if isempty(Obj.nBootStrapSamples)
                Obj.nBootStrapSamples = DS.nObservations;
            end
            
            badIterations = false(Obj.nBootStrapSamples,1);
            pfAtPd1 = zeros(Obj.nBootStrapSamples,1);
            thresholdAtPd1 = zeros(Obj.nBootStrapSamples,1);
            for iBootStrap = 1:Obj.nBootStrapSamples
                [cDSBoot cSampleInds] = DS.bootstrap(Obj.nBootStrapSamples);
                
                try
                    algorithmOutput = Obj.algorithm.kfolds(cDSBoot,Obj.nFolds);
        
                    [rocPf,rocPd,thresholds] = prtScoreRoc(algorithmOutput.getObservations(),cDSBoot.getTargets());
            
                    [pfAtPd1(iBootStrap), thresholdAtPd1(iBootStrap)] = prtUtilPfAtPd1(rocPf,rocPd,thresholds);
                catch %#ok<CTCH>
                    badIterations(iBootStrap) = true;
                    pfAtPd1(iBootStrap) = nan;
                    thresholdAtPd1(iBootStrap) = nan;
                end
            end
        
            Obj.algorithm = Obj.algorithm.train(DS);
            algorithmOutput = Obj.algorithm.run(DS);
            algorithmOutput = algorithmOutput.setTargets(DS.getTargets);
            sortedH0Data = sort(algorithmOutput.getObservationsByClassInd(1),'ascend');
            
            sortedPfAtPd1 = sort(pfAtPd1,'ascend');
            
            sortedPfAtPd1Ind = max(min(round(Obj.confidence*length(sortedPfAtPd1)),length(sortedPfAtPd1)),1);
            thresholdInd = max(min(round((1-sortedPfAtPd1(sortedPfAtPd1Ind))*length(sortedH0Data)),length(sortedH0Data)),1);
            
            Obj.threshold = sortedH0Data(thresholdInd);
            Obj.ThresholdSetSummary.pfAtPd1 = pfAtPd1;
            Obj.classList = DS.uniqueClasses;
        end
        function DS = runAction(Obj,DS)
            algorithmOutput = Obj.algorithm.run(DS);
            DS = DS.setObservations((algorithmOutput.getObservations > Obj.getThreshold) + 1);
        end
    end
end
