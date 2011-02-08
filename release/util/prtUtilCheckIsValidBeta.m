function valid = prtUtilCheckIsValidBeta(saltString)
%valid = prtUtilCheckIsValidBeta
%   P-code this, and call it where appropriate.  Calls to this function
%   should also be inside P-code; otherwise there's an easy way to defeat
%   this...
%

%this can be slow to get dates every time; and annoying to error every
%second after we've warned someone already
persistent isValid

nDaysWarning = 30;
betaDateString = 'January 1, 2012';
websiteAddress = 'www.newFolderConsulting.com';

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