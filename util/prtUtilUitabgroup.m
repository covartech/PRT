function h = prtUtilUitabgroup(varargin)







if verLessThan('matlab','8.4')
    error(javachk('swing'));
    warning('off','MATLAB:uitabgroup:OldVersion');

    h = uitools.uitabgroup(varargin{:});
    h = double(h); 
else
    h = uitabgroup(varargin{:});
end
    

% out = cell(nargout,1);
% 
% if verLessThan('matlab', '7.11')
%     [out{:}] = uitabgroup('v0',varargin{:});
% else
%     [out{:}] = uitabgroup(varargin{:});
% end
% 
% varargout = {};
% if nargout
%     varargout = out;
% end
