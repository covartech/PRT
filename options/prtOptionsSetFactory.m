function options = prtOptionsSetFactory
% prtOptionsSetFactory  Set the factory options for the PRT
%   The factory options are obtained from prtOptionsGetFactory()
%   These options are then saved as a mat file in the PRT options file
%   location. This function also returns these options a structure.
%
%   defaultOptions = prtOptionsGetFactory()
%
% See also. prtOptionsGet, prtOptionsSet, prtOptionsGetDefault







options = prtOptionsGetFactory();
        
save(prtOptionsFileName(),'options');

% We must clear the function prtOptionsGet to purge persistent variables
% which are now out of date.
clear prtOptionsGet
