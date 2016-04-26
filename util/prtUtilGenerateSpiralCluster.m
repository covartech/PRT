function X = generateSpiralCluster(t,f,theta,mux,muy,dx,dy,std)
% xxx Need Help xxx







if nargin < 4
    mux = 0;
    muy = 0;
end
if nargin < 6
    dx = 1;
    dy = 1;
end
if nargin < 8
    std = 1;
end
x = dx.*t.*sin(t.*f + theta) + randn(size(t))*std + mux;
y = dy.*t.*cos(t.*f + theta) + randn(size(t))*std + muy;
X = cat(2,x(:),y(:));
