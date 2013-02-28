function Y = prtUtilY(varargin)
% prtUtilY     Quickly generate class labels for the PRT.
%
% Syntax: Y = prtUtilY(nH0,nH1,nH2,...)
%
% Inputs:
%   nH0 - The number of H0 samples
%   nH1 - The number of H1 samples
%       ...
%
% Outputs:
%   Y - A PRT compliant labeled vector
%
% Example:
%   Y = prtUtilY(100,100);
%   Y = prtUtilY([],100,100);
%   Y = prtUtilY(100,0,100);
%
% See also: prtDataGen*

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


Y = [];

if nargin == 1
    if length(varargin{1}) > 1
        
        temp = mat2cell(varargin{1}(:),ones(length(varargin{1}),1),1);
        Y = prtUtilY(temp{:});
    else
        Y = zeros(varargin{1},1);
    end
    return
end
    

for iInput = 1:nargin
    nHi = varargin{iInput};
    if ~isempty(nHi)
        if nHi > 0
            Y(end+1:end+nHi,1) = iInput-1;
        end
    end
end
