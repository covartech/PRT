function h = prtUtilUitab(varargin)



error(javachk('swing'));

h = uitools.uitab(varargin{:});
h = double(h); 
%%
% out = cell(nargout,1);
% if verLessThan('matlab', '7.11')
%     [out{:}] = uitab('v0',varargin{:});
% else
%     % In MATLAB 7.11 a warning is always displayed
%     [out{:}] = uitab(varargin{:});
% end
% varargout = {};
% if nargout
%     varargout = out;
% end

