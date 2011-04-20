function [guess,truth,classNames] = prtUtilScoreParseFirstTwoInputs(arg1,arg2,whoami)
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
        tempDs = prtDataSetClass(guess,truth);
        classNames = tempDs.getClassNames;
    end
elseif isa(arg1,'prtDataSetBase') && isa(arg2,'prtDataSetBase')
    assert(arg2.isLabeled,'prtScore functions with one input requires a labeled data set');
    guess = arg1.getObservations;
    if nargout > 1
        truth = arg2.getTargets;
    end
    if nargout > 2
        classNames = arg2.getClassNames;
    end
else
    error('Both input arguments must be either numeric, or sub-classes of prtDataSetBase, but inputs are: %s and %s',class(arg1),class(arg2));
end
