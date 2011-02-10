function prtDoc(varargin)
% prtDoc prt Documentation Shortcut
%

if nargin
    doc(varargin{:});
else
    web(fullfile(prtRoot,'doc','html','prtPublishGettingStarted.html'))
end