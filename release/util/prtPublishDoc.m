function prtPublishDoc
% Internal function
% xxx Need Help xxx
%prtPublishDoc
%   Utility function to publish all prtPublish* M-files in prtRoot\doc to
%   HTML files.

docDir = fullfile(prtRoot,'doc');
mfilelist = subDir(docDir,'prtPublish*.m');

for i = 1:length(mfilelist)
    publish(mfilelist{i});
end
close all;