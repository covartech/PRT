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
