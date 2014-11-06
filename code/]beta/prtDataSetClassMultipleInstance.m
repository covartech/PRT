classdef prtDataSetClassMultipleInstance < prtDataSetInMem & prtDataInterfaceCategoricalTargets
    % prtDataSetClassMultipleInstance < prtDataSetInMem & prtDataInterfaceCategoricalTargets
    %   Class container for multiple instance (MI) data
    %
    % dsMil = prtDataSetClassMultipleInstance(milStruct,targets) generates
    %   a multiple instance (MI) data set from the nObs x 1 structure
    %   milStruct and the nObs x 1 label vector "targets".  The structure
    %   milStruct must have a field called "data", which is a
    %   nInstances x nFeatures matrix.  
    %
    %   For example, to generate a MI data set, we might do the following:
    %
    % prtPath('beta')
    % rvH1 = prtRvMvn('mu',[3 3],'sigma',eye(2));
    % rvH0 = prtRvMvn('mu',[0 0],'sigma',eye(2));
    %
    % nObservations = 100;
    % nInstPerBag = 10;
    %
    % targets = nan(nObservations,1);
    % milStruct = struct;
    % for i = 1:nObservations
    %     x = rvH0.draw(nInstPerBag);
    %     targets(i,1) = 0;
    %
    %     if ~mod(i,2)
    %         targets(i,1) = 1;
    %         x(1,:) = rvH1.draw(1);
    %     end
    %     milStruct(i,1).data = x;
    % end
    % dsMil = prtDataSetClassMultipleInstance(milStruct,targets);
    %    
    % 
    %  
    %  

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


    methods (Access = protected)
        function self = update(self)
            % Updated chached target info
            self = updateTargetCache(self);
            % Updated chached data info
            self = updateObservationsCache(self);
        end
    end
    
    properties (Dependent, SetAccess='protected')
        expandedData
        expandedTargets
        bagInds
        nBags
        nTotalObservations
        nObservationsPerBag
    end
    
    methods
        
        function Summary = summarize(self)
            % Summarize   Summarize the prtDataSetStandard object
            %
            % SUMMARY = dataSet.summarize() Summarizes the prtDataSetStandard
            % object and returns the result in the struct SUMMARY.
            Summary = summarize(toPrtDataSetClass(self));
        end
        
        function obj = prtDataSetClassMultipleInstance(varargin)
            %obj = prtDataSetImage(varargin)
            obj.data.data = [];
            
            if nargin == 0
                return;
            end
            if isa(varargin{1},'prtDataSetClass')
                obj = varargin{1};
                varargin = varargin(2:end);
            end
            
            %handle first input data:
            if length(varargin) >= 1 && (isa(varargin{1},'struct'))
                obj = obj.setObservations(varargin{1});
                varargin = varargin(2:end);
                %handle first input data, second input targets:
                if length(varargin) >= 1 && ~isa(varargin{1},'char')
                    if (isa(varargin{1},'double') || isa(varargin{1},'logical'))
                        obj = obj.setTargets(varargin{1});
                        varargin = varargin(2:end);
                    else
                        error('prtDataSet:InvalidTargets','Targets must be a double or logical array; but targets provided is a %s',class(varargin{1}));
                    end
                end
            end
           
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
            obj = obj.update;
        end
        
        function val = get.nTotalObservations(self)
            val = getNumTotalObservations(self);
        end
        function nTotObs = getNumTotalObservations(self)
            nTotObs = sum(self.nObservationsPerBag);
        end
            
        function val = get.expandedTargets(self)
            val = getExpandedTargets(self);
        end
        function bigTargets = getExpandedTargets(self)
            nObsPerBag = self.nObservationsPerBag;
            littleTargets = self.targets;
            
            if isempty(littleTargets)
                bigTargets = [];
                return
            end
            
            bigTargets = zeros(self.nTotalObservations,size(littleTargets,2));
            cEnd = 0;
            for iBag = 1:length(nObsPerBag)
                cY = repmat(littleTargets(iBag,:),nObsPerBag(iBag),1);
                bigTargets(cEnd+(1:nObsPerBag(iBag)),:) = cY;
                cEnd = cEnd + nObsPerBag(iBag);
            end            
        end
        function val = get.expandedData(self)
            val = getExpandedData(self);
        end
        function bigData = getExpandedData(self)
            bigData = cat(1,self.data.data);          
        end
        function val = get.bagInds(self)
            val = getBagInds(self);
        end
        function bagInds = getBagInds(self)
            nObsPerBag = self.nObservationsPerBag;
            bagInds = zeros(self.nTotalObservations,1);
            cEnd = 0;
            for iBag = 1:length(nObsPerBag)
                bagInds(cEnd+(1:nObsPerBag(iBag))) = iBag*ones(nObsPerBag(iBag),1);
                cEnd = cEnd + nObsPerBag(iBag);
            end             
        end
        
        function val = get.nBags(self)
            val = getNumBags(self);
        end        
        function nBags = getNumBags(self)
            nBags = self.nObservations;
        end
        function val = get.nObservationsPerBag(self)
            val = getNumObservationsPerBag(self);
        end
        function nOpb = getNumObservationsPerBag(self)
            nOpb = arrayfun(@(s)size(s.data,1),self.data);
        end
        
        function dsClass = toPrtDataSetClass(self)
            dsClass = prtDataSetClass(self.expandedData, self.expandedTargets);
        end
        
        function self = fromPrtDataSetClassData(self,dsClass,bagInds_)
            if nargin < 3
                bagInds_ = self.getBagInds;
            end
            
            uBags = unique(bagInds_);
            for i = 1:length(uBags);
                current = find(bagInds_ == uBags(i));
                self.data(i).data = dsClass.data(current,:);
                self.targets(i) = unique(dsClass.targets(current,:));
            end
        end
    end
    methods (Hidden, Static)
        
        function dsMil = fromAchutStruct(achutStruct)
            
            bagNums = achutStruct.bagNum;
            uBagNums = unique(bagNums);
            
            d = struct('data',nan(length(uBagNums),size(achutStruct,2)));
            y = nan(length(uBagNums),1);
            
            for bagNumInd = 1:length(uBagNums);
                cBag = uBagNums(bagNumInd);
                current = achutStruct.bagNum == cBag;
                
                d(bagNumInd,1).data = achutStruct.data(current,:);
                y(bagNumInd,1) = unique(achutStruct.label(current));

            end
            y = double(y == 1);
            dsMil = prtDataSetClassMultipleInstance(d,y);
        end
    end
        
end
