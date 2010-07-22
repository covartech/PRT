function prtVerCtrl(command,varargin)

repoLoc = 'http:///svn.newfolderconsulting.com/prt';

if strcmpi(command,'checkout') && nargin == 0
    varargin = {repoLoc varargin{1}};
end

[status, results] = svn(prtRoot,command,varargin{:});

disp(strtrim(results))


emailList = {'pete@newfolderconsulting.com','kenny@newfolderconsulting.com','sandy@newfolderconsulting.com','lesli@newfolderconsulting.com','skeene@gmail.com'};

% If we committed we should send an email to everyone
if strcmpi(command,'commit') && status==0
    for iEmail = 1:length(emailList);
        if ispc
            try
                sendmail(emailList{iEmail},'NF PRT has been updated',{sprintf('Update message: %s\n\n',varargin{1}) strtrim(results)});
            catch %#ok
                warning('An error was encountered sending email.') %#ok
            end
        end
    end
end
