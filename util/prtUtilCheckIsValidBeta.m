function valid = prtUtilCheckIsValidBeta
%valid = prtUtilCheckIsValidBeta
%   P-code this, and call it where appropriate.  Calls to this function
%   should also be inside P-code; otherwise there's an easy way to defeat
%   this...
%
%   Even if this is P-coded, there's still an easy way to defeat this.
%   Just make a new function called prtUtilCheckIsValidBeta and have it
%   output true.... that's not good.  Do we have to make this a static
%   method of every class that needs to check if the Beta is valid?  I
%   think maybe...
%
%   In any case, this seems like the basic function structure we want

%this can be slow to get dates every time; and annoying to error every
%second after we've warned someone already
persistent isValid

nDaysWarning = 30;
betaDateString = 'January 1, 2012';
websiteAddress = 'www.newFolderConsulting.com';

if isempty(isValid)
    
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