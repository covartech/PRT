function fun = prtUtilFeatureNameModificationFunctionHandleCreator(str, varargin)
% prtUtilFeatureNameModificationFunctionHandleCreator(str, other, inputs,...)
%	Creates a function handle of the form:
%		@(strIn, index)sprintf(str, other, inputs, ...)
% This is provided as a separate file so that large work spaces are avoided
% when creating a function handle.
%
% This is/should be used when creating a prtAction and overloading
%	getFeatureNameModificationFunction()
%
% There are two special strings that can appear within
%	#strIn# will be replaced with the strIn input argument
%	#index# will be replaced with the index argument

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


hasStrIn = ~isempty(strfind(str,'#strIn#'));
hasIndex = ~isempty(strfind(str,'#index#'));
hasAdditionalInputs = nargin > 1;

if hasStrIn
	if hasIndex
		if hasAdditionalInputs
			fun = @(strIn, index)sprintf(strrep(strrep(str,'#strIn#',strIn),'#index#', sprintf('%d',index)), varargin{:});
		else
			fun = @(strIn, index)strrep(strrep(str,'#strIn#',strIn),'#index#', sprintf('%d',index));
		end
	else
		if hasAdditionalInputs
			fun = @(strIn, index)sprintf(strrep(str,'#strIn#',strIn), varargin{:});
		else
			fun = @(strIn, index)strrep(str,'#strIn#',strIn);
		end
		
	end
else
	if hasIndex
		if hasAdditionalInputs
			fun = @(strIn, index)sprintf(strrep(str,'#index#', sprintf('%d',index)), varargin{:});
		else
			fun = @(strIn, index)strrep(str,'#index#', sprintf('%d',index));
		end
	else
		if hasAdditionalInputs
			fun = @(strIn, index)sprintf(str, varargin{:});
		else
			fun = @(strIn, index)str;
		end
	end
end
