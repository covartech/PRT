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
