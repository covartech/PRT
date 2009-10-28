function [guess,truth,classLabels] = prtUtilScoreParseFirstTwoInputs(arg1,arg2)
%[guess,truth] = prtUtilScoreParseFirstTwoInputs(arg1,arg2)

if isa(arg1,'double') || isa(arg1,'logical')
    guess = arg1;
elseif isa(arg1,'prtDataSetBase')
    guess = arg1.getObservations;
else
    error('arg1 must be a double or logical array or a prtDataSetBase');
end

if isa(arg2,'double') || isa(arg2,'logical')
    truth = arg2;
    tempDs = prtDataSetClass(randn(size(truth,1),1),truth);
    classLabels = tempDs.getClassNames;
elseif isa(arg2,'prtDataSetClass')
    classLabels = arg2.getClassNames;
    truth = arg2.getTargets;
else
    error('arg2 must be a double or logical array or a prtDataSetClass');
end
