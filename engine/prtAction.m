%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef prtAction %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (Hidden, SetAccess=private) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % All of the Private fields in options function
        name = 'passThrough';
        nameAbbreviation = 'PASS';
        generateFunction = @(DataSet,Options)struct([]); % Dummy default
        runFunction = @(Classifier,DataSet)DataSet; % Dummy default
        supervised = true;
        nativeMaryCapable = true;
        nativeBinaryCapable = true;
        actionType = 'classifier';
        verboseStorage = false;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (Hidden) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        PlotOptions = prtPlotOpt;
        MaryEmulationOptions = [];
        BinaryEmulationOptions = [];
        twoClassParadigm = 'binary';
        
        dataSetUpperBounds = [];
        dataSetLowerBounds = [];
        dataSetNFeatures = [];
        dataSetIsLabeled = false;
        dataSetIsMary = false;
        dataSetNClasses = 1;
        
        PrtDataSet = [];
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (Hidden, SetAccess=private, GetAccess=private) %%%%%%%%%%%%%
        Parameters = [];
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        PrtOptions = [];
        UserData = [];
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Constructor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = prtAction(varargin) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if nargin == 0
                % Nothing. Given an empty one
                return
            end
            
            % Get the default prtAction object
            obj = prtAction;
            if nargin < 3
                error('prt:prtAction:invalidInput','Invalid number of inputs');
            else
                % We have at least three inputs and know that we have these
                % three
                InputDataSet = varargin{1};
                OptionsObj = varargin{2};
                ParamStruct = varargin{3};
            end
            
            % Get the string value parts if we have any
            stringValuePairs = {};
            if nargin > 3
                stringValuePairs = varargin(4:end);
            end
            if ~isempty(stringValuePairs)
                % Check Parameter string, value pairs
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
                    error('prt:prtAction:invalidInputs','Additional input arguments must be specified as parameter string, value pairs.')
                end
                
                % Now we loop through and apply the properties
                for iPair = 1:length(paramNames)
                    obj.(paramNames{iPair}) = paramValues{iPair};
                end
            end
            
            % Interpret Options
            if isstruct(OptionsObj)
                % Parse the private fields
                privateFields = fieldnames(OptionsObj.Private);
                for iField = 1:length(privateFields)
                    cFieldName = privateFields{iField};
                    switch cFieldName
                        case 'classifierName'
                            obj.name = OptionsObj.Private.(cFieldName);
                        case 'classifierNameAbbreviation'
                            obj.nameAbbreviation = OptionsObj.Private.(cFieldName);
                        case 'PrtObjectType'
                            obj.actionType = OptionsObj.Private.(cFieldName);
                        otherwise
                            % For everything else
                            obj.(cFieldName) = OptionsObj.Private.(cFieldName);
                    end
                end
                
                % Parse the rest of the "required" fields
                InParameters = rmfield(OptionsObj,'Private');
                paramNames = fieldnames(InParameters);
                
                for iField = 1:length(paramNames)
                    if ismember(paramNames{iField},{'PlotOptions', 'MaryEmulationOptions','BinaryEmulationOptions','twoClassParadigm','verboseStorage'});
                        obj.(paramNames{iField}) = InParameters.(paramNames{iField});
                        InParameters = rmfield(InParameters, paramNames{iField});
                    end
                end
                
                % InParameters is now a struct containing only the
                % classifier specific options
                obj.PrtOptions = InParameters;
                
            else
                error('prt:prtAction:invalidInputs','OptionsObj must be a Struct.')
            end
            
            % Summary of InputDataSet
            if ~isempty(InputDataSet)
                obj.dataSetUpperBounds = max(InputDataSet.getObservations());
                obj.dataSetLowerBounds = min(InputDataSet.getObservations());
                obj.dataSetNFeatures = InputDataSet.nFeatures;
                
                try %#ok
                    obj.dataSetIsLabeled = ~isempty(InputDataSet.targets);
                end
                try %#ok
                    obj.dataSetIsMary = InputDataSet.isMary;
                end
                try %#ok
                    obj.dataSetNClasses = InputDataSet.nClasses;
                end
            end
            
            % If we requested verbose storage save the DataDet
            if obj.verboseStorage
                obj.PrtDataSet = InputDataSet;
            end
            
            % The rest of the fields (the real parameters)
            obj.Parameters = ParamStruct;
            
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
        function varargout = subsref(Obj,S) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            varargout = cell(1,max([1 nargout]));
            if isequal(S(1).type,'.')
                if ismember(S(1).subs, fieldnames(Obj))
                    % Requested field is a member of the Parameters struct
                    % Let the struct subsref do the work
                    [varargout{:}] = builtin('subsref',Obj.Parameters,S);
                    
                    return
                end
            end
            % Call the standard subsref() and let that spit errors if
            % necessary
            [varargout{:}] = builtin('subsref',Obj,S);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function Obj = subsasgn(Obj,S,val) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function display(Obj) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            inName = inputname(1);
            fprintf('%s = \n',inName)
            
            displayName = sprintf('PRT %s - %s', Obj.actionType, Obj.name);
            
            if numel(Obj) > 1
                dimString = sprintf('%dx',size(R)');
                dimString = dimString(1:end-1);
                
                fprintf('\t%s array of %s objects \n', dimString, displayName)
            else
                fprintf('\t%s \n',displayName)
            end
            display(Obj.Parameters)
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function varargout = plot(Obj) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            switch Obj.actionType
                case 'classifier'            
                    imageHandle = prtPlotClassifierConfidence(Obj);
            
                    if ~isempty(Obj.PrtDataSet)
                        
                        if prtUtilDetermineMary(Obj)
                            [M,N] = getSubplotDimensions(Obj.dataSetNClasses);
                        else
                            [M,N] = getSubplotDimensions(1);
                        end
                        for subImage = 1:M*N
                            subplot(M,N,subImage)
                            hold on;
                            [handles,legendStrings] = plot(Obj.PrtDataSet);
                            hold off;
                            HandleStructure.Axes(subImage) = struct('imageHandle',{imageHandle(subImage)},'handles',{handles},'legendStrings',{legendStrings});
                        end
                    else
                        [M,N] = getSubplotDimensions(1);
                        for subImage = 1:M*N
                            HandleStructure.Axes(subImage) = struct('imageHandle',{imageHandle(subImage)},'handles',{[]},'legendStrings',{[]});
                        end
                    end
                    
                    varargout = {};
                    if nargout > 0
                        varargout = {HandleStructure};
                    end
                otherwise
                    error('prt:prtAction:plot','Plot is not implemented for this action type');
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%