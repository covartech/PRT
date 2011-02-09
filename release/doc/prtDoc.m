function prtDoc(topic)
% prtDoc - Provides easy access to the PRT function reference documenation
%
% prtDoc(topicStr)
%
% 
% Example:
%   prtDoc('prtDataSetClass')

web(fullfile(prtRoot,'doc','functionReference',cat(2,strrep(topic,'.',filesep),'.html')),'-helpbrowser');
