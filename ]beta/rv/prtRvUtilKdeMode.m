function [modeVal, pdfSamples, kdeRv] = prtRvUtilKdeMode(x, varargin)

p = inputParser;
p.addOptional('nSamplesForPdf',1000);
p.addOptional('rv',prtRvKde);

p.parse(varargin{:});
r = p.Results;

rv = mle(r.rv,x);
xSamples = sort(cat(1,linspace(min(x), max(x),r.nSamplesForPdf)',x),'ascend');
pdfSamples = rv.pdf(xSamples);
    
[~,maxInd] = max(pdfSamples);

modeVal = xSamples(maxInd);