function Y = prtUtilY(varargin)
% DPRTY     Quickly generate class labels for the DPRT.
%
% Syntax: Y = dprtY(nH0,nH1,nH2,...)
%
% Inputs:
%   nH0 - The number of H0 samples
%   nH1 - The number of H1 samples
%       ...
%
% Outputs:
%   Y - A DPRT complient labeled vector
%
% Example:
%   Y = dprtY(100,100);
%   Y = dprtY([],100,100);
%   Y = dprtY(100,0,100);
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: dprtData*

% Copyright 2010, New Folder Consulting, L.L.C.

Y = [];

if nargin == 1
    if length(varargin{1}) > 1
        
        temp = mat2cell(varargin{1}(:),ones(length(varargin{1}),1),1);
        Y = dprtY(temp{:});
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