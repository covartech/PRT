#include "matrix.h"
#include "mex.h"
void mexFunction(int nlhs, mxArray *plhs[],
    int nrhs, const mxArray *prhs[]) {

	bool voted = 0;
	int index, iFeature, iSample, iVote, found, iTreeSearch;
    const int *wSize, *featureIndicesSize, *xSize;
	const double *wData, *xData, *terminalVoteData, *featureIndicesData, *thresholdData, *treeIndicesData, *nClasses;
	double *voteData;
	double yOut;
    
    mxArray *W, *featureIndices, *threshold, *terminalVote, *treeIndices;
	mwIndex singleIndex = 0;

	/*Require two input arguments: tree and X*/
    if (nrhs != 3)
        mexErrMsgTxt("evalCAPtreeMex requires three input arguments");
    if (nlhs != 1)
        mexErrMsgTxt("evalCAPtreeMex requires one output arguments");
	
	/* Check the fields of the tree for W, featureIndices, threshold, terminalVote, and treeIndices */
	W = mxGetField(prhs[0],0,"W");
	if (W == NULL)
		mexErrMsgTxt("evalCAPtreeMex requires argument 1 must have field 'W'");

	featureIndices = mxGetField(prhs[0],0,"featureIndices");
	if (featureIndices == NULL)
		mexErrMsgTxt("evalCAPtreeMex requires argument 1 must have field 'featureIndices'");

	threshold = mxGetField(prhs[0],0,"threshold");
	if (threshold == NULL)
		mexErrMsgTxt("evalCAPtreeMex requires argument 1 must have field 'threshold'");

	terminalVote = mxGetField(prhs[0],0,"terminalVote");
	if (terminalVote == NULL)
		mexErrMsgTxt("evalCAPtreeMex requires argument 1 must have field 'terminalVote'");

	treeIndices = mxGetField(prhs[0],0,"treeIndices");
	if (treeIndices == NULL)
		mexErrMsgTxt("evalCAPtreeMex requires argument 1 must have field 'treeIndices'");

    /* Get the data out of the struct */
	wData = mxGetPr(W);
    wSize = mxGetDimensions(W);
    featureIndicesData = mxGetPr(featureIndices);
	thresholdData = mxGetPr(threshold);
	terminalVoteData = mxGetPr(terminalVote);
	treeIndicesData = mxGetPr(treeIndices);
    
	/* Get the Pointers-to-real data we need */
	xData = mxGetPr(prhs[1]);
	xSize = mxGetDimensions(prhs[1]);
    nClasses = mxGetPr(prhs[2]);
 
	plhs[0] = mxCreateDoubleMatrix(xSize[0], (int)nClasses[0], mxREAL);
	voteData = mxGetPr(plhs[0]);
    
    for(iSample = 0; iSample < xSize[0]; iSample++){
        index = 1;
        voted = 0;
        found = 0;
        
        while(!voted){
            
            if (mxIsFinite(wData[(index-1)*wSize[0]])){
                yOut = 0;
                for (iFeature = 0; iFeature < wSize[0]; iFeature++){
                    yOut += wData[(index-1)*wSize[0]+iFeature] * xData[((int)featureIndicesData[(index-1)*wSize[0]+iFeature]-1)*xSize[0] + iSample];
                    /*mexPrintf("%.2f * %.2f [%d] = %.2f\n",wData[(index-1)*wSize[0]+i],xData[(int)featureIndicesData[(index-1)*wSize[0]+i]-1],(int)featureIndicesData[(index-1)*wSize[0]+i]-1,yOut);*/
                }
                yOut = yOut - thresholdData[index-1];
                
                if (yOut >= 0){ /*find the second (right) branch*/
                    found = 0;
                    iTreeSearch = -1;
                    while (found <= 1){
                        iTreeSearch = iTreeSearch+1;
                        if ((int)treeIndicesData[iTreeSearch] == (int)index){
                            found = found + 1;
                        }
                    }
                    index = iTreeSearch+1;
                }else{  /* find the first (left) branch */
                    found = 0;
                    iTreeSearch = -1;
                    while (found <= 0){
                        iTreeSearch = iTreeSearch+1;
                        if ((int)treeIndicesData[iTreeSearch] == (int)index){
                            found = found + 1;
                        }
                    }
                    index = iTreeSearch+1;
                }
            }else{
                for (iVote=0; iVote < nClasses[0]; iVote++){
                    if(iVote == (terminalVoteData[index-1]-1)){
                        voteData[(iVote * xSize[0]) + iSample] = 1;
                    }else{
                        voteData[(iVote * xSize[0]) + iSample] = 0;
                    }
                }
                voted = 1;
            }
        }
    }
    return;
}