function prtDoc(topic)
% prtDoc - Provides easy access to the PRT function reference documenation
%
% prtDoc(topicStr)
%
% 
% Example:
%   prtDoc('prtDataSetClass')



% if nargin < 1 || isempty(topic)
%     web(fullfile(prtRoot,'doc','prtDocLanding.html'),'-helpbrowser');
% else
%     assert(ischar(topic) && isvector(topic),'prt:prtDoc','topic must be a string');
%     
%     web(fullfile(prtRoot,'doc','functionReference',cat(2,strrep(topic(:)','.',filesep),'.html')),'-helpbrowser');
% end

webRoot = 'http://covartech.github.io/prtdoc/';

if nargin < 1 || isempty(topic)
    web(fullfile(webRoot,'prtDocLanding.html'),'-helpbrowser');
else
    assert(ischar(topic) && isvector(topic),'prt:prtDoc','topic must be a string');
    
    web(fullfile(webRoot,'functionReference',cat(2,strrep(topic(:)','.',filesep),'.html')),'-helpbrowser');
end
