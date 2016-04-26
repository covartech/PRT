function [guess, truth, allClassNames, uniqueTruthValues, classNames1, classNames2, uGuess, uTruth] = prtUtilScoreParseFirstTwoInputs(arg1,arg2,whoami)
% xxx Need Help xxx
% Internal functin
%[guess,truth] = prtUtilScoreParseFirstTwoInputs(arg1,arg2)








%this is a hack to allow prtUtilScoreRoc to take matrices
if nargin < 3
    whoami = 'unknown';
end

if isempty(arg2)
    arg2 = arg1;
end

if (isnumeric(arg1) || islogical(arg1)) && (isnumeric(arg2) || islogical(arg2))
    %assert(size(arg1,1) == size(arg2,1),'prtScore functions require input arguments to have same number of rows, but input 1 is size %s, and input 2 is size %s',mat2str(size(arg1)),mat2str(size(arg2)));
    %assert(size(arg1,2) == 1 && size(arg2,2) == 1,'prtScore functions require input arguments to have one column, but input 1 is size %s, and input 2 is size %s',mat2str(size(arg1)),mat2str(size(arg2)));
    assert(size(arg1,1) == size(arg2,1),'prtScore functions require input arguments to have same number of rows');
    
    %This is not true; we accept matrices in prtUtilScoreRoc
    %this is a hack to allow prtUtilScoreRoc to take matrices of X data
    assert((size(arg1,2) == 1 || strcmpi(whoami,'prtScoreRoc')) && size(arg2,2) == 1,'prtScore functions require input arguments to have one column');
    
    guess = arg1;
    if nargout > 1
        truth = arg2;
    end
    if nargout > 2
        uGuess = unique(guess(:));
        uTruth = unique(truth(:));
        uniqueTruthValues = unique(cat(1,uGuess,uTruth));
        
        tempDs = prtDataSetClass(nan(size(uniqueTruthValues,1),1),uniqueTruthValues);
        allClassNames = tempDs.getClassNames;
        
        tempDs = prtDataSetClass(nan(size(uGuess,1),1),uGuess);
        classNames1 = tempDs.getClassNames;
        
        tempDs = prtDataSetClass(nan(size(uTruth,1),1),uTruth);
        classNames2 = tempDs.getClassNames;
    end
    
    
elseif isa(arg1,'prtDataSetBase') && isa(arg2,'prtDataSetBase')
    assert(arg2.isLabeled,'prtScore functions with one input requires a labeled data set');
    guess = arg1.getObservations;
    if nargout > 1
        truth = arg2.getTargets;
    end
    
    if nargout > 2
        
        classNames1 = arg1.classNames;
        classNames2 = arg2.classNames;
        
        uGuess = arg1.uniqueClasses;
        uTruth = arg2.uniqueClasses;
        
        [uniqueTruthValues, uJointInds] = unique(cat(1,uTruth(:),uGuess(:)));
        
        % allClassNames is dominated by the truth strings in the case of
        % colliding truth values.
        allClassNames = {classNames2{:},classNames1{:}}';
        allClassNames = allClassNames(uJointInds);
    end
else
    error('Both input arguments must be either numeric, or sub-classes of prtDataSetBase, but inputs are: %s and %s',class(arg1),class(arg2));
end
