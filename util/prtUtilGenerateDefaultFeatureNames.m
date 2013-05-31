function featNames = prtUtilGenerateDefaultFeatureNames(indices2)
% featNames = prtUtilGenerateDefaultFeatureNames(indices2)

% Previously static in prtDataSetBase
%     function featNames = generateDefaultFeatureNames(indices2)
%         featNames = prtUtilCellPrintf('Feature %d',num2cell(indices2));
%         featNames = featNames(:);
%     end

featNames = prtUtilCellPrintf('Feature %d',num2cell(indices2));
featNames = featNames(:);
