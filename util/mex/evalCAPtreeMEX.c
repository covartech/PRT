//Yout(j,i) = evalCAPtreeMEX(tree,X)

#include "matrix.h"
#include "mex.h"
void mexFunction(int nlhs, mxArray *plhs[],
    int nrhs, const mxArray *prhs[]) {

	bool voted = 0;
	int index = 1, i, count;
	int found = 0;
	const int *wSize, *featureIndicesSize, *xSize;
	const double *wData, *xData, *terminalVoteData, *featureIndicesData, *thresholdData, *treeIndicesData;
	double *voteData;
	double yOut;
	mxArray *W, *featureIndices, *threshold, *terminalVote, *treeIndices;
	mwIndex singleIndex = 0;

    
	/*Require two input arguments: tree and X*/
    if (nrhs != 2)
        mexErrMsgTxt("evalCAPtreeMex requires two input arguments");
    if (nlhs != 1)
        mexErrMsgTxt("evalCAPtreeMex requires one output arguments");
	
	// Check the fields of the tree for W, featureIndices, threshold, terminalVote, and treeIndices
	W = mxGetField(prhs[0],0,"W");
	if (W == NULL)
		mexErrMsgTxt("evalCAPtreeMex requires argument 1 must have field 'W'");

	wSize = mxGetDimensions(W);

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
	if (terminalVote == NULL)
		mexErrMsgTxt("evalCAPtreeMex requires argument 1 must have field 'treeIndices'");

	// Get the Pointers-to-real data we need
	xData = mxGetPr(prhs[1]);
	xSize = mxGetDimensions(prhs[1]);
	if (xSize[0] != 1)
		mexErrMsgTxt("evalCAPtreeMex only operates on one data point at a time");
	

	wData = mxGetPr(W);
	featureIndicesData = mxGetPr(featureIndices);
	thresholdData = mxGetPr(threshold);
	terminalVoteData = mxGetPr(terminalVote);
	treeIndicesData = mxGetPr(treeIndices);

	plhs[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
	voteData = mxGetPr(plhs[0]);
	while(!voted){
		count = 0;
		//if any(isfinite(tree.W(:,index)))
		if (mxIsFinite(wData[(index-1)*wSize[0]+1])){
			yOut = 0;
			for (i = 0; i < wSize[0]; i++){
				yOut += wData[(index-1)*wSize[0]+i] * xData[(int)featureIndicesData[(index-1)*wSize[0]+i]-1];
				//mexPrintf("%.2f * %.2f [%d] = %.2f\n",wData[(index-1)*wSize[0]+i],xData[(int)featureIndicesData[(index-1)*wSize[0]+i]-1],(int)featureIndicesData[(index-1)*wSize[0]+i]-1,yOut);
			}
			yOut = yOut - thresholdData[index-1];
			//mexPrintf("Yout = %.2f\n",yOut);
			if (yOut >= 0){ //find the second (right) branch
				found = 0;
				i = -1;
				while (found <= 1){
					i = i+1;
					if ((int)treeIndicesData[i] == (int)index){
						found = found + 1;
					}
					//mexPrintf("Right: %d; %d == %d\n",count,(int)treeIndicesData[i],(int)index);
				}
				index = i+1;
			}else{  //find the first (left) branch
				found = 0;
				i = -1;
				while (found <= 0){
					i = i+1;
					if (treeIndicesData[i] == index){
						found = found + 1;
					}
					//mexPrintf("Left %d; %d == %d\n",count,(int)treeIndicesData[i],(int)index);
				}
				index = i+1;
			}
			
		}else{
			voteData[0] = terminalVoteData[index-1];
			voted = 1;
			return;
		}
	}
}

