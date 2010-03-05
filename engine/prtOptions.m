classdef prtOptions < dynamicprops
    properties (Hidden, SetAccess=private)
        % All of the Private fields in options function
        name = 'passThrough';
        nameAbbreviation = 'PASS';
        generateFunction = @(DataSet,Options)struct('Nothing',[]); % Dummy default
        runFunction = @(Classifier,DataSet)DataSet; % Dummy default
        supervised = true;
        nativeMaryCapable = true;
        nativeBinaryCapable = true;
        prtAlgorithmType = 'passthrough';
    end
    properties (Hidden)
        PlotOptions = prtPlotOpt;
        MaryEmulationOptions = [];
        BinaryEmulationOptions = [];
        twoClassParadigm = 'binary';
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
                    % Specified as a Struct (traditional options file)
                    % Since we inherited from dynamic props we can call
                    % addprop() as necessary
                    
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
                                obj.prtAlgorithmType = OptionsStruct.Private.(cFieldName);
                            otherwise
                                % For everything else
                                obj.(cFieldName) = OptionsStruct.Private.(cFieldName);
                        end
                    end
                    
                    % Parse the rest of the fields
                    optionsFields = fieldnames(rmfield(OptionsStruct,'Private'));
                    
                    for iField = 1:length(optionsFields)
                        try
                            cProp = obj.addprop(optionsFields{iField});
                            obj.(optionsFields{iField}) = OptionsStruct.(optionsFields{iField});
                        catch ME
                            if isfield(obj, optionsFields{iField})
                                error('prt:prtOptions:badOptionsField', 'Error creating options field. Possibly a bad name.');
                            end
                        end
                        
                        %P.GetMethod = @(self)(getFeatFor(self, P, lsd_kv, fefield{f}, featext{f}, prescreen, id));
                        %P.SetAccess = 'private';
                    end
                    
                otherwise
                    % Assume parameter value pairs (not done yet)
                    error('prt:prtOptions:constructor','Only structure input is currently supported.')
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