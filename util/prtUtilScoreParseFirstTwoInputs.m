function [guess,truth,classNames] = prtUtilScoreParseFirstTwoInputs(arg1,arg2)
%[guess,truth] = prtUtilScoreParseFirstTwoInputs(arg1,arg2)

if (isnumeric(arg1) || islogical(arg1)) && (isnumeric(arg2) || islogical(arg2))
    guess = arg1;
    truth = arg2;
    tempDs = prtDataSetClass(guess,truth);
    classNames = tempDs.getClassNames;
elseif isa(arg1,'prtDataSetBase')
    guess = arg1.getObservations;
    truth = arg2.getTargets;
    classNames = arg2.getClassNames;
else
    error('Both input arguments must be either numeric, or sub-classes of prtDataSetBase, but inputs are: %s and %s',class(arg1),class(arg2));
end
