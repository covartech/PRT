classdef prtDataSetImage < prtDataSetInMem & prtDataInterfaceCategoricalTargets
    % prtDataSetImage < prtDataSetInMem & prtDataInterfaceCategoricalTargets
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
    
    methods
        
        function obj = prtDataSetImage(varargin)
            %obj = prtDataSetImage(varargin)
            
            if nargin == 0
                return;
            end
            if isa(varargin{1},'prtDataSetClass')
                obj = varargin{1};
                varargin = varargin(2:end);
            end
            
            %handle first input data:
            if length(varargin) >= 1 && (isa(varargin{1},'prtDataTypeImage'))
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
        
        
        
        function self = setData(self,dataIn,varargin)
            
            if ~isa(dataIn,'prtDataTypeImage') || ~isvector(dataIn);
                error('prtDataSetImage:setData','The data field of a prtDataSetImage must be an array of prtDataTypeImage objects');
            else
                dataIn = dataIn(:);
            end
            if nargin > 2
                self.internalData(varargin{:}) = dataIn;
            else
                self.internalData = dataIn;
            end
           
            if self.internalSizeConsitencyCheck
                prtDataSetInMem.checkConsistency(self.internalData,self.internalTargets);
            end
            self = self.update;
        end
        
        function Summary = summarize(self,Summary) 
            if nargin==1
                Summary = struct;
            end
            Summary = summarize@prtDataInterfaceCategoricalTargets(self,Summary);
            Summary = summarize@prtDataSetInMem(self,Summary);
        end
    end
end
