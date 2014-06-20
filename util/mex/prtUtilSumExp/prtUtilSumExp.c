#include "mex.h"
#include <math.h>

void addexp(double* x, 
            int* xSize,
            double* z,
            double* maxLogs)
{
    /* We actually dont want the maxLogs variable but we dont want to do allocation here.*/
    int i, j;
    
    for(i = 0; i < xSize[1]; i++){
        maxLogs[i] = x[i*xSize[0]];
        for(j = 1; j < xSize[0]; j++){
            if(x[i*xSize[0]+ j] > maxLogs[i]){
                maxLogs[i] = x[i*xSize[0] + j];
            }
        }
    }
    
    /* Do the Add exp magic */
    for(i = 0; i < xSize[1]; i++){
        z[i] = 0;
        for(j = 0; j < xSize[0]; j++){
            z[i] = z[i] + exp(x[i*xSize[0] + j] - maxLogs[i]);
        }
        z[i] = maxLogs[i] + log(z[i]);
    }
}


/*z = sumexp(x)  sums down the columns of x*/
void mexFunction(
        int nlhs,              /* Number of left hand side (output) arguments */
        mxArray *plhs[],       /* Array of left hand side arguments */
        int nrhs,              /* Number of right hand side (input) arguments */
        const mxArray *prhs[]  /* Array of right hand side arguments */
        )
{
    double *x, *z;
    int xNDims, *xSize, *zSize;
    double *maxLogs;
    
    if (nrhs != 1){
        mexErrMsgTxt("sumexp() requires exactly 1 argument.");
    }
    xNDims = mxGetNumberOfDimensions(prhs[0]);
    xSize = (int *) mxGetDimensions(prhs[0]);
    x = mxGetPr(prhs[0]);
    if (xNDims != 2){
        mexErrMsgTxt("sumexp() only accepts 2D input.");
    }
    if (nrhs != 1){
        mexErrMsgTxt("Invalid number of inputs. Must be 1.");
        return;
    }
    
    
    /*
    // Here is the full m code
    //////////////////////////////////////
    //           big = max(x);
    //           if (min(size(x)) > 1)
    //             len = size(x,1);
    //           else
    //             len = 1;
    //           end;
    //           z = big + log(sum( exp(x - ones(len,1)*big) ));
    */
    
    /* Make output: z */
    zSize = mxCalloc(2, sizeof(int));
    zSize[0] = 1;
    zSize[1] = xSize[1];
    
    plhs[0] = mxCreateNumericArray(2, zSize, mxDOUBLE_CLASS, mxREAL);
    z = mxGetPr(plhs[0]);
    
    /* Make a helper vector for addexp */
    maxLogs = mxCalloc(xSize[1], sizeof(double));
    
    /* Call the actual addexp */
    addexp(x, xSize, z, maxLogs);
    
    
    /* Clean up */
    mxFree(zSize);
    mxFree(maxLogs);
    return;
}
