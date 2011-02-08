function prtPackage(prtTarget)

if nargin == 0
    prtTarget = 'C:\Users\Pete\Desktop\nfPrtExport';
end

disp('boo ya');
%Write the contents.m file
cd(prtRoot);
[v,s] = system('svn info');
s = textscan(s,'%s');
version = s{1}{12};

string = sprintf('%% Pattern Recognition Toolbox\n%% Version %s %s',version,datestr(now,1))
fid = fopen(fullfile(prtRoot,'contents.m'),'w');
fprintf(fid,'%s',string);
fclose(fid);

prtVerCtrl('commit',sprintf('packaging revision %s',version));

%package the directory
local = prtRoot;
target = prtTarget;
command = sprintf('svn export %s %s',local,target);
system(command);

end