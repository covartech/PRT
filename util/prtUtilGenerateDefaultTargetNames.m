function targNames = prtUtilGenerateDefaultTargetNames(indices2)
% targNames = prtUtilGenerateDefaultTargetNames(indices2)

% Previously static in prtDataSetBase
%     function targNames = generateDefaultTargetNames(indices2)
%         targNames = prtUtilCellPrintf('Target %d',num2cell(indices2));
%         targNames = targNames(:);
%     end
targNames = prtUtilCellPrintf('Target %d',num2cell(indices2));
targNames = targNames(:);