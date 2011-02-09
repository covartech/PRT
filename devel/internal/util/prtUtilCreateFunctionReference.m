function prtUtilCreateFunctionReference(saveRoot)

if nargin < 1
    saveRoot = prtRoot;
end

prtUtilClassNameToHtmlDoc('prtDataSetStandard',saveRoot)
prtUtilClassNameToHtmlDoc('prtDataSetRegress',saveRoot)
prtUtilClassNameToHtmlDoc('prtDataSetClass',saveRoot)

prtUtilClassNameToHtmlDoc('prtAction',saveRoot)
prtUtilClassNameToHtmlDoc('prtClass',saveRoot)
prtUtilClassNameToHtmlDoc('prtDecision',saveRoot)
prtUtilClassNameToHtmlDoc('prtFeatSel',saveRoot)
prtUtilClassNameToHtmlDoc('prtPreProc',saveRoot)
prtUtilClassNameToHtmlDoc('prtOutlierRemoval',saveRoot)
prtUtilClassNameToHtmlDoc('prtRegress',saveRoot)
prtUtilClassNameToHtmlDoc('prtCluster',saveRoot)
