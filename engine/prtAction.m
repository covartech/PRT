classdef prtAction < dynamicprops
    properties (Hidden, SetAccess=private)
        % All of the Private fields in options function
        Options = prtOptions(); % Default dummy options
    end
    properties (Hidden)
        upperBounds = [];
        lowerBounds = [];
    end
    
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Constructor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = prtAction(varargin)
            if nargin == 0
                % Nothing. Given an empty one
                return
            end
            
            % Get the default prtAction object
            obj = prtAction; 
            
            if nargin == 1
            	% Specified with only a struct
                % Since we inherited from dynamic props we can call
                % addprop() as necessary
                ParamStruct = varargin{1};
                
                OptionsObj = ParamStruct.PrtOptions; % Options must exist
                
                if isfield(ParamStruct,'PrtDataSet')
                    InputDataSet = ParamStruct.PrtDataSet; 
                else
                    InputDataSet = [];
                end
            end
            if nargin == 3
                InputDataSet = varargin{1};
                OptionsObj = varargin{2};
                ParamStruct = varargin{3};
            end
               
            if isfield(ParamStruct,'PrtOptions')
                ParamStruct = rmfield(ParamStruct,'PrtOptions');
            end
            if isfield(ParamStruct,'PrtDataSet')
                ParamStruct = rmfield(ParamStruct,'PrtDataSet');
            end
            
            % Bounds from InputDataSet
            if ~isempty(InputDataSet)
                obj.upperBounds = max(InputDataSet.getObservations());
                obj.lowerBounds = min(InputDataSet.getObservations());
            end
            
            % Save the Options field
            obj.Options = OptionsObj;
            
            % Parse the rest of the fields
            paramNames = fieldnames(ParamStruct);
            
            for iField = 1:length(paramNames)
                try
                    cProp = obj.addprop(paramNames{iField});
                    obj.(paramNames{iField}) = ParamStruct.(paramNames{iField});
                catch ME
                    if isfield(obj, paramNames{iField})
                        error('prt:Action:badParamName', 'Error creating field. Possibly a bad name.');
                    end
                end
                
                %P.GetMethod = @(self)(getFeatFor(self, P, lsd_kv, fefield{f}, featext{f}, prescreen, id));
                %P.SetAccess = 'private';
            end
                    
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function f = fieldnames(self, varargin)
            % Dynamic properties don't usually show up in the 'fieldnames'
            % report for an array of objects, so we'll force the issue.
            f = properties(self(1));
        end
        function tf = isfield(self, fieldname)
            tf = ismember(fieldname,fieldnames(self));
        end
    end
end