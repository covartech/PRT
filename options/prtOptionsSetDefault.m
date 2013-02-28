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

% Copyright (c) 2013 New Folder Consulting
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.


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
