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
