classdef prtDataSetImage < prtDataSetInMem & prtDataInterfaceCategoricalTargets
    % prtDataSetImage < prtDataSetInMem & prtDataInterfaceCategoricalTargets
    % 







    
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
