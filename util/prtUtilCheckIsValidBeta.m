function valid = prtUtilCheckIsValidBeta(saltString)
%valid = prtUtilCheckIsValidBeta
%   P-code this, and call it where appropriate.  Calls to this function
%   should also be inside P-code; otherwise there's an easy way to defeat
%   this...
%

% Copyright (c) 2013 New Folder Consulting
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


%this can be slow to get dates every time; and annoying to error every
%second after we've warned someone already
persistent isValid

nDaysWarning = 30;
betaDateString = 'January 1, 2012';
websiteAddress = 'www.newFolderConsulting.com/prt';

if isempty(isValid)
    
    internalSaltString = 'cmbrwwuvphcjlwjpxuwghhgksogwzcafuyeonnyutyycplbotbwmjjimkzuongslqkovjmjovuubmohbsnfvmbymqzxibrzdlzjq';
    if ~strcmpi(saltString,internalSaltString)
        isValid = []; %#ok<NASGU> %this ensures we keep erroring on every call when the PRT is invalid
        h = errordlg('prtUtilCheckIsValidBeta was not called with a correct salt string; please contact newFolderConsulting for additional help','prt:invalidSalt');
        uiwait(h);
        error('prt:invalidSalt','prtUtilCheckIsValidBeta was not called with a correct salt string; please contact newFolderConsulting for additional help');
    end
    betaExpirationDate = datenum(betaDateString);
    todayDate = datenum(date);
    
    if todayDate > betaExpirationDate;
        isValid = []; %#ok<NASGU> %this ensures we keep erroring on every call when the PRT is invalid
        h = errordlg(sprintf('The Beta version of the PRT expired on %s; please visit %s to obtain a license of the full featured PRT',betaDateString,websiteAddress),'prt:BetaExpired');
        uiwait(h);
        error('prt:BetaExpired','The Beta version of the PRT expired on %s; please visit %s to obtain a license of the full featured PRT',betaDateString,websiteAddress);
    elseif todayDate > betaExpirationDate - nDaysWarning
        h = warndlg(sprintf('The Beta version of the PRT will expire on %s (%d days from now); please visit %s to obtain a license of the full featured PRT',betaDateString, betaExpirationDate - todayDate, websiteAddress),'prt:BetaAlmostExpired');
        uiwait(h);
        warning('prt:BetaAlmostExpired','The Beta version of the PRT will expire on %s (%d days from now); please visit %s to obtain a license of the full featured PRT',betaDateString, betaExpirationDate - todayDate, websiteAddress);
    end
    isValid = true;
end
valid = isValid;
