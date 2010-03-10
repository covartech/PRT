classdef prtOptions 
    properties (Hidden)
        % All of the Private fields in options function
        name
        nameAbbreviation
        generateFunction
        runFunction
        supervised
        nativeMaryCapable
        nativeBinaryCapable
        actionType
    end
    properties (Hidden)
        PlotOptions = prtPlotOpt;
        MaryEmulationOptions = [];
        BinaryEmulationOptions = [];
        twoClassParadigm = 'binary';
    end
    properties %(Hidden, SetAccess=private, GetAccess=private)
        Parameters = [];
    end
    properties
        UserData = [];
    end
    
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Constructor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = prtOptions(varargin)
            switch nargin
                case 0 
                    % Nothing. Given an empty one
                    return;
                case 1
                    % Get the default prtOptionsObject
                    obj = prtOptions; 
                        
                    % Get the OptionsStruct
                    OptionsStruct = varargin{1};
                    
                    % Parse the private fields
                    privateFields = fieldnames(OptionsStruct.Private);
                    for iField = 1:length(privateFields)
                        cFieldName = privateFields{iField};
                        switch cFieldName
                            case 'classifierName'
                                obj.name = OptionsStruct.Private.(cFieldName);                                    
                            case 'classifierNameAbbreviation'
                                obj.nameAbbreviation = OptionsStruct.Private.(cFieldName);
                            case 'PrtObjectType'
                                obj.actionType = OptionsStruct.Private.(cFieldName);
                            otherwise
                                % For everything else
                                obj.(cFieldName) = OptionsStruct.Private.(cFieldName);
                        end
                    end
                    
                    
                    InParameters = rmfield(OptionsStruct,'Private');
                    paramNames = fieldnames(InParameters);
                    
                    for iField = 1:length(paramNames)
                        if ismember(paramNames{iField},{'PlotOptions', 'MaryEmulationOptions','BinaryEmulationOptions','twoClassParadigm'});
                            obj.(paramNames{iField}) = InParameters.(paramNames{iField});
                            InParameters = rmfield(InParameters, paramNames{iField});
                        end
                    end
                    
                    % The parameters that remain can go in the parameters
                    % structure
                    obj.Parameters = InParameters; 
                    
                otherwise
                     stringValuePairs = varargin;
                    % Check parameter string, value pairs
                    inputError = false;
                    if mod(length(stringValuePairs),2)
                        inputError = true;
                    end
            
                    paramNames = varargin(1:2:(end-1));
                    if ~iscellstr(paramNames)
                        inputError = true;
                    end
                    paramValues = varargin(2:2:end);
                    if inputError
                        error('prt:prtOptions:invalidInputs','Additional input arguments must be specified as parameter string, value pairs.')
                    end
            
            % Now we loop through and apply the properties
            for iPair = 1:length(paramNames)
                obj.(paramNames{iPair}) = paramValues{iPair};
            end
                    
                    
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function f = fieldnames(self, varargin) %%%%%%%%%%%%%%%%%%%%%%%%%%%
            f = fieldnames(self(1).Parameters);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function tf = isfield(self, fieldname) %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            tf = ismember(fieldname,fieldnames(self));
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function output = subsref(Obj,S) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if isequal(S(1).type,'.')
                if ismember(S(1).subs, fieldnames(Obj))
                    % Requested field is a member of the Parameters struct
                    % Let the struct subsref do the work
                    output = builtin('subsref',Obj.Parameters,S);
                    
                    % This would work but might break in an odd way for
                    % strange referencing
                    % output = Obj.Parameters.(S.subs);
                    return
                end
            end
            % Call the standard subsref() and let that spit errors if
            % necessary
            output = builtin('subsref',Obj,S);
        end
        
        function Obj = subsasgn(Obj,S,val)
            if isequal(S(1).type,'.')
                if ismember(S(1).subs, fieldnames(Obj))
                    % Requested field is a member of the Parameters struct
                    % Let the struct subsassign do the work
                    Obj.Parameters = builtin('subsasgn',Obj.Parameters, S, val);
                    
                    return
                end
            end
            % Call the standard subsasgn() and let that spit errors if
            % necessary
            Obj = builtin('subsasgn',Obj,S,val);
        end        
        
        function display(Obj)
            
            inName = inputname(1);
            fprintf('%s = \n',inName)
            
            displayName = sprintf('PRT %s Options - %s', Obj.actionType, Obj.name);
            
            if numel(Obj) > 1
                dimString = sprintf('%dx',size(R)');
                dimString = dimString(1:end-1);

                fprintf('\t%s array of %s objects \n', dimString, displayName)
            else
                fprintf('\t%s \n',displayName)
            end
            %StructObj = struct(Obj);
            %StructObj = rmfield(StructObj, 'Parameters');
            %display(StructObj);
            display(Obj.Parameters)
        end
    end
end