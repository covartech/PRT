function D = prtDistanceCosineAngle(dataSet1,dataSet2)
%prtDistanceCosineAngle   Cosine Angle
%   
%   DIST = prtDistanceCosineAngle(DS1,DS2) calculates the angle between two
%   vectors via:
%       cosTheta = sum(x.*y)/(sqrt(sum(x.^2))+sqrt(sum(y.^2)))
%       dist = acos(cosTheta)
%   
%   For more information, see:
%   
%   http://en.wikipedia.org/wiki/Cosine_similarity
%







[data1,data2] = prtUtilDistanceParseInputs(dataSet1,dataSet2);
dMat = data1*data2';
eMat = bsxfun(@times,sqrt(sum(data1.^2,2)),sqrt(sum(data2.^2,2)'));
cosTheta = dMat./eMat;

%handle numerical precision before acos spits imaginary
cosTheta(cosTheta < -1) = -1;
cosTheta(cosTheta > 1) = 1;

D = acos(cosTheta);
