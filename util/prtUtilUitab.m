function h = prtUtilUitab(varargin)






if verLessThan('matlab','8.4')
    error(javachk('swing'));

    h = uitools.uitab(varargin{:});
    h = double(h); 
else
    h = uitab(varargin{:});
end


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

