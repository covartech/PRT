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


/* [elnAlpha, elnBeta, elnGamma, elnXi] = vbForwardBackwards(logInit, logTransitions, logStateLike) */
void mexFunction(
        int nlhs,              /* Number of left hand side (output) arguments */
        mxArray *plhs[],       /* Array of left hand side arguments */
        int nrhs,              /* Number of right hand side (input) arguments */
        const mxArray *prhs[]  /* Array of right hand side arguments */
        )
{

    double *logInit, *logTransitions, *logStateLike, *alpha, *beta, *gamma, *xi;
    int *logInitSize, *logTransitionsSize, *logStateLikeSize, *alphaSize;
    
    int t, iState, jState;
    double *helperAddExpVector, *helperNStatesMat, *helperNStatesVec, *helperNStatesVec2;
    int helperSumSize[2];
    int xiSize[3];
    int xiSumSize[2];
    
    if (nrhs != 3){
        mexErrMsgTxt("Invalid number of inputs. Must be 3.");
        return;
    }
    
    /* Sizes */
    logInitSize = (int *) mxGetDimensions(prhs[0]);
    logTransitionsSize = (int *) mxGetDimensions(prhs[1]);
    logStateLikeSize = (int *) mxGetDimensions(prhs[2]);
    
    /* Size helper variables */
    helperSumSize[0] = logTransitionsSize[0];
    helperSumSize[1] = 1;
    
    xiSize[0] = logTransitionsSize[0];
    xiSize[1] = logTransitionsSize[0];
    xiSize[2] = logStateLikeSize[1];
    
    xiSumSize[0] = logTransitionsSize[0]*logTransitionsSize[0];
    xiSumSize[1] = 1;
    
    /* Actual Input Data */
    logInit = mxGetPr(prhs[0]);
    logTransitions = mxGetPr(prhs[1]);
    logStateLike = mxGetPr(prhs[2]);
    
    /* Create Helper Variables */
    helperAddExpVector = mxCalloc(logTransitionsSize[0], sizeof(double)); /* nStates */
    helperNStatesMat = mxCalloc(logTransitionsSize[0]*logTransitionsSize[0], sizeof(double)); /* nStates,nStates */
    helperNStatesVec = mxCalloc(logTransitionsSize[0], sizeof(double)); /* nStates */
    helperNStatesVec2 = mxCalloc(logTransitionsSize[0], sizeof(double)); /* nStates */
    
        
    /*/////////////////////////////////////////////////////////////////////
    // Alpha - Forwards ///////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////*/
    plhs[0] = mxCreateNumericArray(2, logStateLikeSize, mxDOUBLE_CLASS, mxREAL);
    alpha = mxGetPr(plhs[0]);
    /* Initial */
    /* M >> elnAlpha(:, 1) = logInit+logStateLike(:, 1); */
    for(iState = 0; iState < logStateLikeSize[0]; iState++){
        alpha[iState] = logInit[iState] + logStateLike[iState];
    }
    
    /* Loop through /////
    ////// M Code ///////
    //     for t = 2:nData;
    //         elnAlpha(:,t) = sumexp(bsxfun(@plus,elnAlpha(:,t-1), logTransitions))' + logStateLike(:,t);
    //         if all(isnan(elnAlpha(:,t)))
    //             elnAlpha(:,t) = -log(size(elnAlpha,1));
    //         end
    //     end
    //////////////////// */
    for(t = 1; t < logStateLikeSize[1]; t++){
        /* M >> bsxfun(@plus,elnAlpha(:,t-1), logTransitions) */
        for(jState = 0; jState < logTransitionsSize[0]; jState++){
            for(iState = 0; iState < logTransitionsSize[0]; iState++){
                helperNStatesMat[jState*logTransitionsSize[0] + iState] = alpha[(t-1)*logTransitionsSize[0] + iState] + logTransitions[jState*logTransitionsSize[0] + iState];
            }
        }

        /* M >> sumexp(bsxfun(@plus,elnAlpha(:,t-1), logTransitions))'; */
        /* M / C >> helperNStatesVec = sumexp(helperNStatesMat); */
        addexp(helperNStatesMat, logTransitionsSize, helperNStatesVec, helperAddExpVector);
        
        /* Save this in the alpha matrix */
        for(iState = 0; iState < logTransitionsSize[0]; iState++){
            alpha[t*logTransitionsSize[0] + iState] = helperNStatesVec[iState] + logStateLike[t*logTransitionsSize[0] + iState];
        }
    }
    /*///////////////////////////////////////////////////////////////////*/
    
    /*/////////////////////////////////////////////////////////////////////
    //Beta - Backwards ////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////*/
    /* Only do it if we need to*/
    if(nlhs > 1){
        plhs[1] = mxCreateNumericArray(2, logStateLikeSize, mxDOUBLE_CLASS, mxREAL);
        beta = mxGetPr(plhs[1]);
        /*///// M Code ///////
        //         elnBeta = zeros(nStates,nData);
        //         elnBeta(:,end) = 0;
        //         for t = nData-1:-1:1;
        //             elnBeta(:,t) = sumexp(bsxfun(@plus,logTransitions',(logStateLike(:,t+1) + elnBeta(:,t+1))))';
        //             if all(isnan(elnBeta(:,t)))
        //                 elnBeta(:,t) = -log(size(elnBeta,1));
        //             end
        //         end
        ///////////////////*/        
        
        /* M >> elnBeta(:,end) = 0; */
        for(iState = 0; iState < logStateLikeSize[0]; iState++){
            beta[(logStateLikeSize[1]-1)*logTransitionsSize[0] + iState] = 0;
        }
        /* The primary Loop */
        for(t = (logStateLikeSize[1]-2); t >=0 ; t--){
            /* M >> bsxfun(@plus,logTransitions',(logStateLike(:,t+1) + elnBeta(:,t+1))) */
            for(jState = 0; jState < logTransitionsSize[0]; jState++){
                for(iState = 0; iState < logTransitionsSize[0]; iState++){
                    helperNStatesMat[jState*logTransitionsSize[0] + iState] = logStateLike[(t+1)*logTransitionsSize[0] + iState] + beta[(t+1)*logTransitionsSize[0] + iState] + logTransitions[iState*logTransitionsSize[0] + jState];
                }
            }
            
            /* M >> sumexp(bsxfun(@plus,logTransitions',(logStateLike(:,t+1) + elnBeta(:,t+1))); */
            /* M / C >> helperNStatesVec = sumexp(helperNStatesMat); */
            addexp(helperNStatesMat, logTransitionsSize, helperNStatesVec, helperAddExpVector);
            
            /* Save this in the beta matrix */
            for(iState = 0; iState < logTransitionsSize[0]; iState++){
                beta[t*logTransitionsSize[0] + iState] = helperNStatesVec[iState];
            }
        }
    
    }
    /*///////////////////////////////////////////////////////////////////*/
    
    /*/////////////////////////////////////////////////////////////////////
    // Gamma //////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////*/
    /* Only do it if we need to */
    if(nlhs > 2){
        plhs[2] = mxCreateNumericArray(2, logStateLikeSize, mxDOUBLE_CLASS, mxREAL);
        gamma = mxGetPr(plhs[2]);
        
        /*/ M Code
        // elnGamma = bsxfun(@minus,elnGamma,sumexp(elnGamma));
        // Instead of doing one giant addexp we do one lots of little ones.
        // This might use more flops but less mem. */
        for(t = 0; t < logStateLikeSize[1]; t++){
            for(iState = 0; iState < logTransitionsSize[0]; iState++){
            	 helperNStatesVec2[iState] = alpha[t*logTransitionsSize[0] + iState] + beta[t*logTransitionsSize[0] + iState];
            }
        
            /* This addexp is different because we are summing just over a vector giving a scalar */
            addexp(helperNStatesVec2, helperSumSize, helperNStatesVec, helperAddExpVector);
            
            for(iState = 0; iState < logTransitionsSize[0]; iState++){
                gamma[t*logTransitionsSize[0] + iState] = helperNStatesVec2[iState] - helperNStatesVec[0];
            }
        }
    }
    /*///////////////////////////////////////////////////////////////////*/
    
    /*/////////////////////////////////////////////////////////////////////
    // Xi /////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////*/
    /* Only do it if we need to */
    if(nlhs > 3){
        plhs[3] = mxCreateNumericArray(3, xiSize, mxDOUBLE_CLASS, mxREAL);
        xi = mxGetPr(plhs[3]);
        /* M Code /////////////////////////////
        //         elnXi = zeros([nStates, nStates, nData]);
        //         for t = 1:nData-1;
        //             elnXit = bsxfun(@plus, bsxfun(@plus, logTransitions, (logStateLike(:, t+1) + elnBeta(:, t+1))'),elnAlpha(:,t));
        //             elnXi(:, :, t) = elnXit-sumexp(elnXit(:));
        //         end
        //         elnXi(:, :, end) = -Inf;
        ////////////////////////////////////*/
        
        
        for(t = 0; t < (logStateLikeSize[1]-1); t++){
            /* M >> bsxfun(@plus, bsxfun(@plus, logTransitions, (logStateLike(:, t+1) + elnBeta(:, t+1))'),elnAlpha(:,t)) */
            for(jState = 0; jState < logTransitionsSize[0]; jState++){
                for(iState = 0; iState < logTransitionsSize[0]; iState++){
                    helperNStatesMat[jState*logTransitionsSize[0] + iState] = logTransitions[iState*logTransitionsSize[0] + jState] + logStateLike[(t+1)*logTransitionsSize[0] + iState] + beta[(t+1)*logTransitionsSize[0] + iState] + alpha[t*logTransitionsSize[0] + jState];
                }
            }
            
            /* This addexp is different from the rest because we are summing over the entire square giving a scalar */
            addexp(helperNStatesMat, xiSumSize, helperNStatesVec, helperAddExpVector);
            
            /* subtract out this so that we can normalize it */
            for(jState = 0; jState < logTransitionsSize[0]; jState++){
                for(iState = 0; iState < logTransitionsSize[0]; iState++){
                    xi[t*logTransitionsSize[0]*logTransitionsSize[0] + iState*logTransitionsSize[0] + jState] = helperNStatesMat[jState*logTransitionsSize[0] + iState] - helperNStatesVec[0];
                }
            }
        }
        
    
        /* elnXi(:, :, end) = -Inf; */
        t = (logStateLikeSize[1]-1); 
        for(jState = 0; jState < logTransitionsSize[0]; jState++){
            for(iState = 0; iState < logTransitionsSize[0]; iState++){
                xi[t*logTransitionsSize[0]*logTransitionsSize[0] + iState*logTransitionsSize[0] + jState] = -1e300;
            }
        }
    }
    
    /* Clean up */
    mxFree(helperAddExpVector);
    mxFree(helperNStatesMat);
    mxFree(helperNStatesVec);
    mxFree(helperNStatesVec2);
    return;
}
