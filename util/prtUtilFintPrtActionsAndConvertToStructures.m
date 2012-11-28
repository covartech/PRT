function cVal = prtUtilFintPrtActionsAndConvertToStructures(cVal)

if isa(cVal,'prtAction')
    cVal = cVal.toStructure;
elseif iscell(cVal)
    % Current element is a cell that may contain prtActions
    for iCell = 1:numel(cVal)
        cVal{iCell} = prtUtilFintPrtActionsAndConvertToStructures(cVal{iCell});
    end
elseif isstruct(cVal)
    subFieldNames = fieldnames(cVal);
    for iField = 1:length(subFieldNames)
        cVal.(subFieldNames{iField}) =  prtUtilFintPrtActionsAndConvertToStructures(cVal.(subFieldNames{iField}));
    end
end