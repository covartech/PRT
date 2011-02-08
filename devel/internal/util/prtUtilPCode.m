function prtUtilPCode(fileName)

% Create P-File Version
pcode(fileName,'-inplace');

% Delete M-File Version
delete(fileName); 