function output = prtOptionsGet(subOptionsName, paramName)
% prtOptionsGet
%   PRT options are MATLAB classes that reside in the +prtOptions package
%
%   output = prtOptionsGet()
%       Returns all prtOptions as a structure with field names equivalent 
%       to the class names.
%
%   output = prtOptionsGet(subOptionsName);
%       Returns an instatiation of the class subOptionsName
%       This is useful to obtain only a subset of options 
%           Example: output = prtOptionsGet('prtOptionsRvPlot')
%
%   output = prtOptionsGet(subOptionsName, paramName);
%       Returns the parameter paramName from the class subOptionsName
%       This is useful to obtain only a specific value
%           Example: output = prtOptionsGet('prtOptionsComputation','largestMatrixSize')
%
%   Additional options can be added to the PRT by adding additional classes
%   to the prtOptions package.
%
%   PRT options are cached in the .mat file
%       %USERPATH%/prt/options/prtOptionsSave.mat
%   where USERPATH is the MATLAB start directory. See userpath()
%   When this directory or file does not exist prtOptionsGetDefault() is
%   calssed.
%
% See also. prtOptionsSet, prtOptionsGetDefault prtOptionsSetDefault

persistent options

if ~exist('options','var')
    options = [];
end

saveDir = fullfile(strrep(userpath,';',''),'prt','options');
optionsFileName = 'prtOptionsSave.mat';

if isempty(options) % Options is not currently persistant in this funciton
    
    if ~isdir(saveDir)
        mkdir(saveDir);
    end
        
    if ~exist(fullfile(saveDir,optionsFileName),'file');
        newOptions = prtOptionsSetDefault();
        options = newOptions;
    else
        Loaded = load(fullfile(saveDir,optionsFileName),'options');
        options = Loaded.options;
    end
end

%At this point we can assume that we have the variable options which is
%the full structure of all of the options

switch nargin
    case 0
        output = options;
    case 1
        if ~isfield(options,subOptionsName)
            error('prt:prtOptionsGet','There is no prtOptions class named %s',subOptionsName);
        end
        output = options.(subOptionsName);
            
    case 2
        if ~isfield(options,subOptionsName)
            error('prt:prtOptionsGet','There is no prtOptions class named %s',subOptionsName);
        end

        % If the property name doesn't exist we let MATLAB throw the
        % standard bad property name for this class error.
        output = options.(subOptionsName).(paramName);
        
    otherwise
        error('prt:prtOptionsGet','Too many input arguments');
end



end


