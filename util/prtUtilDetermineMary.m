function [useMary, emulate] = prtUtilDetermineMary(varargin)
% Internal
% xxx Need Help xxx
% prtUtilDetermineMary A helper function for prtGenerate
%
% Syntax: [useMary, emulate] = prtUtilDetermineMary(PrtDataSet,PrtClassOpt)
%         [useMary, emulate] = prtUtilDetermineMary(PrtClassifier)
%








if nargin == 2 && isa(varargin{1},'prtDataSetClass') 
    maryData = varargin{1}.isMary;
    
    if isstruct(varargin{2})
        isNativeMaryCapable = varargin{2}.Private.nativeMaryCapable;
        isNativeBinaryCapable = varargin{2}.Private.nativeBinaryCapable;
        if isfield(varargin{2},'MaryEmulationOptions')
            MaryEmulationOptions = varargin{2}.MaryEmulationOptions;
        else
            MaryEmulationOptions = [];
        end
        if isfield(varargin{2},'BinaryEmulationOptions')
            BinaryEmulationOptions = varargin{2}.BinaryEmulationOptions;
        else
            BinaryEmulationOptions = [];
        end
        if isfield(varargin{2},'twoClassParadigm')
            preferBinary = strcmpi(varargin{2}.twoClassParadigm,'binary');
        else % Forgot to add a twoClassParadigm
            preferBinary = 1;
        end
    else
        error('Not done yet')
    end
elseif nargin == 2 && isa(varargin{1},'prtDataSetUnLabeled')
    useMary = false;
    emulate = false;
    return;
elseif nargin == 2 && isa(varargin{1},'prtDataSetRegress')
    useMary = false;
    emulate = false;
    return;
elseif isa(varargin{1},'prtClass')
    DataSetSummary = varargin{1}.dataSetSummary;
    maryData = false;
    if isfield(DataSetSummary,'isMary')
        maryData = DataSetSummary.isMary;
    end
    preferBinary = strcmpi(varargin{1}.twoClassParadigm,'binary');
    isNativeMaryCapable = varargin{1}.maryCapable;
    isNativeBinaryCapable = varargin{1}.binaryCapable;
else
    % Assume every thing is cool. Regressor etc.
    useMary = false;
    emulate = false;
    return
end

maryEmulationSpecified = ~isempty(MaryEmulationOptions);
binaryEmulationSpecified = ~isempty(BinaryEmulationOptions) && ~isempty(BinaryEmulationOptions.classAssignment);

if maryData
    if maryEmulationSpecified
        if isNativeBinaryCapable
            useMary = true;
            emulate = true;
        else
            error('prt:MarySpec','M-ary Emulation is not possible because the classifier does not support binary classification.')
        end
    elseif binaryEmulationSpecified
        if isNativeMaryCapable
            useMary = false;
            emulate = true;
        else
            error('prt:MarySpec','Binary Emulation is not possible because the classifier does not support m-ary classification.')
        end
    else %PrtClassOpt.MaryEmulationOptions not specified
        if isNativeMaryCapable
            useMary = true;
            emulate = false;
        else
            error('prt:MarySpec','M-ary classification is not supported by this classifier. To perform M-ary classification, you will need to specifify MaryEmulationOptions. See prtDocMary');
        end
    end
else %Binary Data
    if preferBinary
        if isNativeBinaryCapable
            useMary = false;
            emulate = false;
        elseif isNativeMaryCapable && binaryEmulationSpecified
            useMary = false;
            emulate = true;
        else
            error('prt:MarySpec','Binary classification is not supported by this classifier. To perform Binary classification, you will need to specifify BinaryEmulationOptions. See prtDocMary');
        end
    else %Prefer Mary
        if isNativeMaryCapable
            useMary = true;
            emulate = false;
        else % Mary is not possible
            if maryEmulationSpecified
                useMary = true;
                emulate = true;
            else
                error('prt:MarySpec','M-ary classification is not supported by this classifier.  To perform M-ary classification, you will need to specifify MaryEmulationOptions. See prtDocMary');
            end
        end
    end
end
