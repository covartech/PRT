function obsNames = prtUtilGenerateDefaultObservationNames(indices2)
% obsNames = prtUtilGenerateDefaultObservationNames(indices2)

% Previously static in prtDataSetBase
%     function obsNames = generateDefaultObservationNames(indices2)
%         obsNames = prtUtilCellPrintf('Observation %d',num2cell(indices2));
%         obsNames = obsNames(:);
%     end
obsNames = prtUtilCellPrintf('Observation %d',num2cell(indices2));
obsNames = obsNames(:);
