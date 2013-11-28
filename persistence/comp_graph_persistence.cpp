#include <mex.h>
#include <math.h>
#include <vector>
#include <memory.h>
#include <stdlib.h>
#include <stdio.h>
#include <iostream>
#include <assert.h>

#include "comp_persistence.h"

using namespace std;

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	if(nrhs != 2){
		mexErrMsgTxt("Two inputs required.");
	}

    if((mxGetClassID(prhs[0]) != mxDOUBLE_CLASS) ||
        (mxGetClassID(prhs[1]) != mxDOUBLE_CLASS)){
		mexErrMsgTxt("Inputs 1 and 2 must be arrays of doubles.");
	}

    // Vector to store the function f (provided as a second argument).
    vector<double> f;

    double *prf;
    prf = (double *)mxGetPr(prhs[1]);
    
    // The number of vertices in the graph is given by the size of the function
    // vector.
    int nv = mxGetNumberOfElements(prhs[1]);
    
    // Read in the function vector. It should have V elements.
    f.resize(nv);
    for (int i = 0; i < nv ; i++)  {
        f[i] = (double)*prf;
        prf++;
    }
   
    // Vector to store the edges in the graph. These are stored as 2D array,
    // where all the neighbors of vertex i are stored in edges[i].
    vector<vector<unsigned int > > edges;
    edges.resize(nv);

    // Reference to the first argument, which should point to the edge matrix,
    // given as a Ex2 matrix, where E is the total number of edges.
    double *prE;
    int ne = mxGetNumberOfElements(prhs[0]);

    // Assume that the edge matrix has size Ex2 so the total
    // number of elements must be even.
    if((ne % 2 != 0)) {
        mexErrMsgTxt("Edge matrix should have an even number of elements.");
    }
    
    // Read in the edges.
    // NOTE: We don't check for uniqueness. In principle the same edge can
    //       appear multiple times.
    prE = (double *)mxGetPr(prhs[0]);
    for (int i = 0; i < ne/2 ; i++)  {
        // Vertex references are given in Matlab-style (1-indexed), so we have
        // to convert them to 0-indexed style. 
        unsigned int vid0 = ((unsigned int)*prE)-1;
        prE++;
        unsigned int vid1 = ((unsigned int)*prE)-1;
        prE++;
        
        // For every pair (vid0, vid1) given as a row of matrix E, we create
        // two edges vid0->vid1, and vid1->vid0.
        edges[vid0].push_back(vid1);
        edges[vid1].push_back(vid0);
    }
    
    // Vector of local maximum / persistence pairs, to be used as output.
    vector<pair<unsigned int, double> > peaks; 
    
    compute_persistence(edges, f, peaks);
    
    // Number of local maxima (points in the persistence diagram).
    unsigned int np = peaks.size();

    // Output two matrices -- the indices of local maxima and their associated
    // persistence values.
	plhs[0] = mxCreateDoubleMatrix(np, 1, mxREAL);
	plhs[1] = mxCreateDoubleMatrix(np, 1, mxREAL);
	
    double *II, *JJ;
	II = mxGetPr(plhs[0]);
    JJ = mxGetPr(plhs[1]);
    
	for(mwSize i = 0; i < np; i ++){
		II[i] = peaks[i].first;
        JJ[i] = peaks[i].second;
	}
}


