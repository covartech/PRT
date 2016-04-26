function options = prtOptionsSet(varargin)
% PRTOPTIONSSET Set the current options for the PRT
%   These options are only for the current session and will be discarded if
%   the MATLAB function cache is cleared. This can happen frequently.
%   Therefore you will probably want to make options changes permenent. 
%   To make these options permenent use prtOptionsSetDefault();
%   
%   options = prtOptionsSet(optionsTypeStr, optionsParamStr, optionsParameterValue,...);
%
%   Inputs must be provided in triples
%       optionsTypeStr        - The name of the options class to be
%                               modified
%       optionsParamStr       - The name of the parameter within the
%                               options class
%       optionsParameterValue - The new value for the specified parameter
%
%
% See also. prtOptionsGet, prtOptionsSet, prtOptionsGetDefault
%           prtOptionsGetFactory, prtOptionsSetFactory







assert(mod(length(varargin),3)==0,'prtOptionsSet requires that inputs are provided in triplets (optionsTypeStr, optionsParamStr, optionsParameterValue).');
        
subOptionsNames = varargin(1:3:end);
paramNames = varargin(2:3:end);
        
assert(iscellstr(subOptionsNames),'options types must be strings.');
assert(iscellstr(paramNames),'options parameter names must be strings.');
        
% Feed inputs to prtOptionsGet using undocumented calling syntax
% The function prtOptionsGet holds the persistantly loaded options
% structure, since we are only setting the parameters temporarly, we modify
% them in the prtOptionsGet workspace.
options = prtOptionsGet([], [], varargin{:});
