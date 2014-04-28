function svm = prtClassSvm(varargin)
% svm = prtClassSvm(varargin)
warning('prtClassSvm:prtClassSvm','prtClassSvm is now a simple wrapper for prtClassLibSvm, and will be removed.  Please use prtClassLibSvm instead');
svm = prtClassLibSvm(varargin{:});
