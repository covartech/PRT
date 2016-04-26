function [data1,data2] = prtUtilDistanceParseInputs(dataSet1,dataSet2,dimCheck)
%[data1,data2] = prtUtilDistanceParseInputs(dataSet1,dataSet2)
%[data1,data2] = prtUtilDistanceParseInputs(dataSet1,dataSet2,dimCheck) 
% Boolean, whether to check data dimensionality
% Internal
% xxx Need Help xxx







if nargin < 3
    dimCheck = true;
end
if (isnumeric(dataSet1) && isnumeric(dataSet2)) || (islogical(dataSet1) && islogical(dataSet2))
    data1 = dataSet1;
    data2 = dataSet2;
elseif isa(dataSet1,'prtDataSetBase') && isa(dataSet2,'prtDataSetBase')
    data1 = dataSet1.getObservations;
    data2 = dataSet2.getObservations;
else
    error('prt:prtUtilDistanceParseInputs:invalidInputs','prtDistance functions require first two inputs to be numeric or prtDataSetBase, but inputs were: %s and %s',class(dataSet1),class(dataSet2));
end
if dimCheck
    if size(data1,2) ~= size(data2,2)
        error('prt:prtUtilDistanceParseInputs:invalidInputs','prtDistance functions require the dimensionality of the two inputs to match, but inputs are of dimension %d and %d',size(data1,2),size(data2,2));
    end
end
