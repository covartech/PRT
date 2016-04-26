function options = prtOptionsSetDefault(varargin)
% PRTOPTIONSSETDEFAULT Set the current PRT options as the default
%   These are options stored as a mat file with name prtOptionsFileName()
%   This function also returns the options as a structure.
%
%   options = prtOptionsSetDefault() % Loads the current options
%   options = prtOptionsSetDefault(options)
%   options = prtOptionsSetDefault(optionsTypeStr, optionsParamStr, optionsParameterValue,...); % First calls prtOptionsSet, then prtOptionsSetDefault();
%
%
%   Example:
%       % Sets the default symbol size to be 4 instead of 8
%       prtOptionsSetDefault('prtOptionsDataSetClassPlot','symbolSize',4);
%
% See also. prtOptionsGet, prtOptionsSet, prtOptionsGetDefault
%           prtOptionsGetFactory, prtOptionsSetFactory







if nargin == 0
    options = prtOptionsGet();
elseif nargin == 1
    options = varargin{1};
else
    options = prtOptionsSet(varargin{:});
end

save(prtOptionsFileName(),'options');

% We must clear the function prtOptionsGet to purge persistent variables
% which are now out of date.
clear prtOptionsGet
