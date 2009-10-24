function [useMary, emulate] = prtUtilDetermineMary(varargin)
% prtUtilDetermineMary A helper function for prtGenerate
%
% Syntax: [useMary, emulate] = prtUtilDetermineMary(PrtDataSet,PrtClassOpt)
%         [useMary, emulate] = prtUtilDetermineMary(PrtClassifier)
%

if nargin == 2 && isa(varargin{1},'prtDataSetClass') 
    maryData = varargin{1}.isMary;
    PrtClassOpt = varargin{2};
elseif prtUtilIsClassifier(varargin{1})
    maryData = varargin{1}.PrtDataSet.isMary;
    PrtClassOpt = varargin{1}.PrtOptions;
else
    error('Invalid inputs')
end

maryEmulationSpecified = isfield(PrtClassOpt,'MaryEmulationOptions') && ...
    ~isempty(PrtClassOpt.MaryEmulationOptions);

binaryEmulationSpecified = isfield(PrtClassOpt,'BinaryEmulationOptions') && ...
    ~isempty(PrtClassOpt.BinaryEmulationOptions) && ...
    ~isempty(PrtClassOpt.BinaryEmulationOptions.classAssignment);

if isfield(PrtClassOpt,'twoClassParadigm')
    preferBinary = strcmpi(PrtClassOpt.twoClassParadigm,'binary');
else % Forgot to add a twoClassParadigm
    preferBinary = 1;
end

if maryData
    if maryEmulationSpecified
        if PrtClassOpt.Private.nativeBinaryCapable
            useMary = true;
            emulate = true;
        else
            error('prt:MarySpec','M-ary Emulation is not possible because the classifier does not support binary classification.')
        end
    elseif binaryEmulationSpecified
        if PrtClassOpt.Private.nativeMaryCapable
            useMary = false;
            emulate = true;
        else
            error('prt:MarySpec','Binary Emulation is not possible because the classifier does not support m-ary classification.')
        end
    else %PrtClassOpt.MaryEmulationOptions not specified
        if PrtClassOpt.Private.nativeMaryCapable
            useMary = true;
            emulate = false;
        else
            error('prt:MarySpec','M-ary classification is not supported by this classifier. To perform M-ary classification, you will need to specifify MaryEmulationOptions. See prtDocMary');
        end
    end
else %Binary Data
    if preferBinary
        if PrtClassOpt.Private.nativeBinaryCapable
            useMary = false;
            emulate = false;
        elseif PrtClassOpt.Private.nativeMaryCapable && binaryEmulationSpecified
            useMary = false;
            emulate = true;
        else
            error('prt:MarySpec','Binary classification is not supported by this classifier. To perform Binary classification, you will need to specifify BinaryEmulationOptions. See prtDocMary');
        end
    else %Prefer Mary
        if PrtClassOpt.Private.nativeMaryCapable
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