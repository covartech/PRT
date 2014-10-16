function prtUtilRemoveOldLicense(fileName,doIt)
% prtUtilRemoveOldLicense(fileName)
%   Used internaly to update license information in the PRT
%
%  Uses prtUtilLicense to get the right license string.
%  Ignores files containing prtExternal or prtDoc.
%  Ignores files that already have "% Copyright (c) 2013 New Folder Consulting" in
%  them.
%  May duplicate copyrights in other files, so be careful.
%  When we update the license file, we need to write prtUtilRemoveLicense
%
%  Edit this M-file to see how to call it to make it actually do something.
%   This functionality is too dangerous to DOC.  Just edit the M-file and
%   poke around.

% Copyright (c) 2014 CoVar Applied Technologies
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


% To make it do something, make doIt true...




% g = subDir(prtRoot,'*.m');
% for i = 1:length(g); prtUtilApplyLicense(g{i}); end

if nargin < 2
    doIt = false;
end

if ~isempty(strfind(lower(fileName),'prtexternal'))
    [p,f] = fileparts(fileName);
    fprintf('prtExternal file ignored: %s (in %s)\n',p,f);
    return;
end
if ~isempty(strfind(lower(fileName),'prtdoc'))
    [p,f] = fileparts(fileName);
    fprintf('prtDoc file ignored: %s (in %s)\n',f,p);
    return;
end 

fid = fopen(fileName);
s = fscanf(fid,'%c');
fclose(fid);

oldLicense = {prtUtilLicense(1)};
for i = 1:length(oldLicense)
    s = strrep(s,oldLicense{i},''); % remove any old license
end
keyboard
if doIt
    fOut = fopen(fileName,'w');
    fprintf(fOut,'%s',s);
    fclose(fOut);
else
    disp('Not doing anything; see the help');
end
