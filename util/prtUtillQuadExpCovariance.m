function K = prtUtillQuadExpCovariance(x1, x2, theta0, theta1, theta2, theta3)
% xxx Need Help xxx
% K = prtUtillQuadExpCovariance(x1, x2, theta0, theta1, theta2, theta3)
%
% Common covariance function for Gaussian Processes
%
% Bishop, Pattern Recognition and Machine Learning Eq. 6.63







if nargin < 6 || isempty(theta3)
    theta3 = 0;
end

if nargin < 5 || isempty(theta2)
    theta2 = 0;
end

if nargin < 4 || isempty(theta1)
    theta1 = 1;
end

if nargin < 3 || isempty(theta0)
    theta0 = 1;
end

K = theta0 * exp(-theta1/2 * prtDistanceEuclidean(x1,x2).^2) + theta2 + theta3*x1*x2';
