function prtUtilTestErrorDisplay(ME)
%passed = prtUtilTestErrorDisplay(bool)

fprintf('PRT Test Failed on line %d of %s\n',ME.stack.line,ME.stack.file);