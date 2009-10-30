function D = prtDistanceEarthMover(varargin)
%D = prtDistanceEarthMover(x1,w1,x2,w2)
%   Reuturn the earth mover distance from points in x1 with weights w1 to
%   points in x2 with weights w2. 
%
%       x1 (n1 x nDimensions)
%       w1 (n1 x 1)
%       x2 (n2 x nDimensions)
%       w2 (n2 x 1)
%
%D = prtDistanceEarthMover(w1,w2)
%   Return the earth mover distance from w1 to w2.  x1 and x2 are assumed
%   to be [1:n1]' and [1:n2]' respectively
%   
%
%   See: Rubner, Tomasi, Guibas.  The Earth Mover's Distance as a Metric
%   for Image Retrieval. 

switch nargin 
    case 2
        w1 = varargin{1};
        x1 = (1:size(w1,1))';
        
        w2 = varargin{2};
        x2 = (1:size(w2,1))';
    case 4
        x1 = varargin{1};
        w1 = varargin{2};
        
        x2 = varargin{3};
        w2 = varargin{4};
    otherwise
        error('prtDistanceEarthMover requires 2 or 4 inputs');
end

f = distance(x1,x2);
f = f';
f = f(:);

A = kron(eye(size(x1,1)),ones(1,size(x2,1)));
A = cat(1,A,kron(ones(1,size(x1,1)),eye(size(x2,1))));
b = [w1(:); w2(:)];

Aeq = ones(size(f));
beq = min([sum(w1),sum(w2)]);

[x,D] = linprog(f,A,b,Aeq',beq,zeros(size(f)));
