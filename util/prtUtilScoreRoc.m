function [PF,PD,AUC,THRESH] = prtUtilScoreRoc(DS,Y,NROCsamples,NPFsamples,NPDsamples)
% ROC   Plot a reciever operator characteristic. 
%
% Syntax: 
%       [PF,PD,AUC,THRESH] = prtUtilScoreRoc(DS,Y);
%       [PF,PD,AUC,THRESH] = prtUtilScoreRoc(DS,Y,NROCsamples)
%
% Inputs:
%   DS - double Vec - A vector of N decisions statistics.
%   Y - int Vec - A vector of class labels.
%   NROCsamples - int - The number of linearly spaced samples to use for 
%       the threshold of the ROC curve.  Defaults to length(DS), with
%       non-linear spacing equivalent to sort(DS).  This is the usual
%       expected full ROC curve.
%
% Outputs:
%   PF - double Vec - Probability of falsa alarm as a function of
%       threshold.
%   PD - double Vec - Probability of detection as a function of threshold.
%   AUC - double - The area under the ROC curve.
%   THRESH - double Vec - The vector of thresholds used to determine the PF
%       and PD values.
%
% Example:
%   X = cat(1,mvnrnd([0 0],eye(2),500),mvnrnd([2 2],[1 .5; .5 1],500));
%   Y = cat(1,zeros(500,1),ones(500,1)); 
%   DS = dprtKFolds(X,Y,optionsGLRT,200);
%   prtUtilScoreRoc(DS,Y)
%
%   [...] = prtUtilScoreRoc(DS,Y,NROCsamples,NPFsamples,NPDsamples);
%       Allows the user to specify one of NROCsamples, NPFsamples, or
%       NPDsamples.  NROCsamples guarantees uniform (linear) sampling in
%       the DS space, NPF or NPD samples guarantee uniform (linear)
%       sampling in those respective spaces.  This is important when DS
%       values may be logarithmically spaced.  Note that only one of NROC,
%       NPF or NPDsamples may be non-empty.  So:  
%           prtUtilScoreRoc(DS,Y,[],[],100);
%       is a valid call, but:
%           prtUtilScoreRoc(DS,Y,[],100,100); 
%       is not valid.  If all N*samples variables are empty, ROC.M defalts
%       to sampling the ROC curve at every point in DS - i.e. the default
%       from above.
%
%       The following illustrates
%       the phenomenon and the resulting linear or non-linearly spaced
%       results:
%
%       close all; clear all; 
%       NrocSamp = 10;      %highly under-sampled ROC curve!
%       NdataSamp = 300;    
%       X = cat(1,randn(NdataSamp,1),randn(NdataSamp,1)+2);
%       X = exp(X);     %highly non-linear DS
%       Y = cat(1,zeros(NdataSamp,1), ones(NdataSamp,1));
%       [pffull,pdfull] = prtUtilScoreRoc(X,Y,[],[],[]); 
%       [pf1,pd1] = prtUtilScoreRoc(X,Y,NrocSamp,[],[]); 
%       [pf2,pd2] = prtUtilScoreRoc(X,Y,[],NrocSamp,[]); 
%       [pf3,pd3] = prtUtilScoreRoc(X,Y,[],[],NrocSamp);
%       figure(1);
%       h = plot(pffull,pdfull,pf1,pd1,pf2,pd2,pf3,pd3);
%       legend(h,{'Full','Linear DS','Linear PF','Linear PD'},4);
%       xlabel('PF'); ylabel('PD');
%       figure(2);
%       h = plot(1:length(pffull),pffull,1:length(pf1),pf1,1:length(pf2),pf2,1:length(pf3),pf3);
%       legend(h,{'PF Full','PF Linear DS','PF Linear PF','PF Linear PD'});
%       xlabel('Nsamples'); ylabel('PF');
%       figure(3);
%       h = plot(1:length(pdfull),pdfull,1:length(pd1),pd1,1:length(pd2),pd2,1:length(pd3),pd3);
%       legend(h,{'PD Full','PD Linear DS','PD Linear PF','PD Linear PD'});
%       xlabel('Nsamples'); ylabel('PD');
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: DPRT

% Copyright 2010, New Folder Consulting, L.L.C.

if ~isreal(DS(:))
    error('ROC requires input DS to be real');
end
if any(isnan(DS(:)))
    warning('PRT:prtUtilScoreRoc:dsContainsNans',['DS input to ROC function contains NaNs; these are interpreted as "missing data".  \n',...
        ' The resulting ROC curve may not acheive Pd or Pfa = 1'])
end
uY = unique(Y(:));
if length(uY) ~= 2  
    error('prt:prtUtilScoreRoc:tooFewClasses','ROC requires only 2 unique classes; unique(Y(:)) = %s\n',mat2str(unique(Y(:))));
end
if length(DS) ~= length(Y);
    error('length(ds) (%d) must equal length(y) (%d)',length(DS),length(Y));
end
newY = Y;
newY(Y==uY(1)) = 0;
newY(Y==uY(2)) = 1;
Y = newY;
% if ~isequal(unique(Y(:)),[0,1]') && ~isequal(unique(Y(:)),[0]') && ~isequal(unique(Y(:)),[1]')
%     error('ROC requires unique classes to be 0 and 1; unique(Y(:)) = %s\n',mat2str(unique(Y(:))));
% end
if (length(unique(Y)) == length(Y)) && length(Y) > 2
    warning('PRT:prtUtilScoreRoc:invalidY','Attempt to call ROC with Y ~ DS0; New ROC code requires prtUtilScoreRoc(DS,Y) - not prtUtilScoreRoc(DS1,DS0)...');
    DS_H1 = DS;
    DS_H0 = Y;
else
    % Input check
    if numel(DS) ~= length(DS)
        error('ROCs can only be realized in a 2 class case')
    end
    Y = Y(:);
    if ~isempty(setdiff(unique(Y),[0; 1]))
        warning('PRT:prtUtilScoreRoc:multiClassY',['ROCs can only be realized in a 2 class case. ' ...
            'Samples with Y~=0 will assumed to be members H1.'])
        Y(Y~=0) = 1;
    end
    
    DS_H1 = DS(Y==1);
    DS_H0 = DS(Y==0);
end

%handle the different possible input combinations:
if nargin == 2
    NROCsamples = [];
    NPFsamples = [];
    NPDsamples = [];
elseif nargin == 3
    NPFsamples = [];
    NPDsamples = [];
elseif nargin == 4
    NPDsamples = [];
end

mtVec = [~isempty(NROCsamples),~isempty(NPFsamples),~isempty(NPDsamples)];
if length(find(mtVec)) > 1
    error('Only one of NROCsamples (%s), NPFsamples (%s), NPDsamples (%s) can be non-empty',mat2str(size(NROCsamples)),...
        mat2str(size(NPFsamples)),mat2str(size(NPDsamples)));
end
%if the user has not specified the number of ROC samples, default to -1
if isempty(find(mtVec,1))
    NROCsamples = -1;
end

%initialize PF and PD
PF = zeros(NROCsamples+1,1);
PD = zeros(NROCsamples+1,1);

%make the DS_H* matrices into vectors
DS_H1 = DS_H1(:);  %reshape vectors to be Nx1
DS_H0 = DS_H0(:);

%count the total number of possible hits and misses
Nhit = length(DS_H1);
Nmiss = length(DS_H0);

%let the threshold range over the total range of DS values
if NROCsamples == -1
    %use length DS samples:
    THRESH = sort(DS);
    PF = zeros(length(DS)+1,1);
    PD = zeros(length(DS)+1,1);
    NROCsamples = length(DS);
elseif ~isempty(NROCsamples)
    %use NROCsamples:
    THRESH = linspace(min(DS),max(DS),NROCsamples);
elseif ~isempty(NPFsamples);
    %NPF code samples PF uniformly by sampling sorted DS_H0 uniformly
    DS_H0_sort = sort(DS_H0);
    pfvalsIndices = linspace(1,length(DS_H0_sort),NPFsamples-2); % Need min and max
    THRESH = DS_H0_sort(round(pfvalsIndices));
    THRESH = [min(DS);THRESH;max(DS)];
    NROCsamples = length(THRESH);
elseif ~isempty(NPDsamples);
    %NPD code samples PD uniformly by sampling sorted DS_H1 uniformly:
    DS_H1_sort = sort(DS_H1);
    pdvalsIndices = linspace(1,length(DS_H1_sort),NPDsamples);
    THRESH = DS_H1_sort(round(pdvalsIndices));
    THRESH = [min(DS);THRESH;max(DS)];
    NROCsamples = length(THRESH);
end

%for each possible threshold (THRESH determines spacing in DS/PD/PF space,
%see above)
for COUNT = 1:NROCsamples
    thresh = THRESH(COUNT);
    %DS_H0(DS_H0 >= thresh) are false alarms;
    PF(COUNT) = length(find(DS_H0 >= thresh));
    %DS_H1(DS_H1 >= thresh) are targets; 
    PD(COUNT) = length(find(DS_H1 >= thresh));
end

%normalize the number of false alarms and detections
if Nmiss == 0
    PF = nan(size(PF));
    PF = zeros(size(PF));
else
    PF = PF./Nmiss;
end
if Nhit == 0
    PD = nan(size(PD));
else
    PD = PD./Nhit;
end

if nargout > 2
    AUC = trapz(flipud(PF(:)),flipud(PD(:)));
    % [redhed, sortInd] = sort(DS);
    % AUC = (sum(find(Y(sortInd))) - Nhit*(Nhit + 1)/2) / (Nmiss*Nhit); % eq. 1 of Hand and Till, 2001
end

%if there are no outputs; plot the ROC;
if nargout == 0
    plot(PF,PD);
    clear PF PD AUC
end
