function y = voigtProfile(x,sigma,gamma,N)
%y = voigtProfile(x,sigma,gamma)
%y = voigtProfile(x,sigma,gamma,N)

if nargin < 4
    N = 10;
end

z = (x + 1i*gamma)./(sigma*sqrt(2)); 
y = real(voigtCef(z,N))./(sigma*sqrt(2));

function w = voigtCef(z,N)
% w = cef(z,N) 
%  Computes the function w(z) = exp(-z^2) erfc(-iz) using a rational 
%  series with N terms.  It is assumed that Im(z) > 0 or Im(z) = 0.
%
%                             Andre Weideman, 1995

M = 2*N;  M2 = 2*M;  k = [-M+1:1:M-1]';    % M2 = no. of sampling points.
L = sqrt(N/sqrt(2));                       % Optimal choice of L.
theta = k*pi/M; t = L*tan(theta/2);        % Define variables theta and t.
f = exp(-t.^2).*(L^2+t.^2); f = [0; f];    % Function to be transformed.
a = real(fft(fftshift(f)))/M2;             % Coefficients of transform.
a = flipud(a(2:N+1));                      % Reorder coefficients.
Z = (L+1i*z)./(L-1i*z); p = polyval(a,Z);    % Polynomial evaluation.
w = 2*p./(L-1i*z).^2+(1/sqrt(pi))./(L-1i*z); % Evaluate w(z).


