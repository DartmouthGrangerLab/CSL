#include "cokus.cpp"
#include "util.h"

void GibbsSamplerLDA(double ALPHA, double BETA, int W, int T, int D, int NN, int OUTPUT, int n, int *z, int *d, int *w, int *wp, int *dp, int *ztot, int *order, double *probs, int startcond )
{
    
  int wi,di,i,ii,j,topic, rp, temp, iter, wioffset, dioffset;
  double totprob, WBETA, r, max;

  if (startcond == 1) {
      /* start from previously saved state */
      for (i=0; i<n; i++)
      {
          wi = w[ i ];
          di = d[ i ];
          topic = z[ i ];
          wp[ wi*T + topic ]++; // increment wp count matrix
          dp[ di*T + topic ]++; // increment dp count matrix
          ztot[ topic ]++; // increment ztot matrix
      }
  }
  
  if (startcond == 0) {
  /* random initialization */
      for (i=0; i<n; i++)
      {
          wi = w[ i ];
          di = d[ i ];
          // pick a random topic 0..T-1
          topic = (int) ( (double) randomMT() * (double) T / (double) (4294967296.0 + 1.0) );
          z[ i ] = topic; // assign this word token to this topic
          wp[ wi*T + topic ]++; // increment wp count matrix
          dp[ di*T + topic ]++; // increment dp count matrix
          ztot[ topic ]++; // increment ztot matrix
      }
  }
  
  
  for (i=0; i<n; i++) order[i]=i; // fill with increasing series
  for (i=0; i<(n-1); i++) {
      // pick a random integer between i and nw
      rp = i + (int) ((double) (n-i) * (double) randomMT() / (double) (4294967296.0 + 1.0));
      
      // switch contents on position i and position rp
      temp = order[rp];
      order[rp]=order[i];
      order[i]=temp;
  }
  
  //for (i=0; i<n; i++) mexPrintf( "i=%3d order[i]=%3d\n" , i , order[ i ] );
  WBETA = (double) (W*BETA);
  for (iter=0; iter<NN; iter++) {
	mexPrintf( "Outer loop iter %d of %d\n", iter,NN);
      for (ii = 0; ii < n; ii++) {
          i = order[ ii ]; // current word token to assess
          
          wi  = w[i]; // current word index
          di  = d[i]; // current document index  
          topic = z[i]; // current topic assignment to word token
          ztot[topic]--;  // substract this from counts
          
          wioffset = wi*T;
          dioffset = di*T;
          
          wp[wioffset+topic]--;
          dp[dioffset+topic]--;
          
          //mexPrintf( "(1) Working on ii=%d i=%d wi=%d di=%d topic=%d wp=%d dp=%d\n" , ii , i , wi , di , topic , wp[wi+topic*W] , dp[wi+topic*D] );
          
          totprob = (double) 0;
          for (j = 0; j < T; j++) {
              probs[j] = ((double) wp[ wioffset+j ] + (double) BETA)/( (double) ztot[j]+ (double) WBETA)*( (double) dp[ dioffset+ j ] + (double) ALPHA);
              totprob += probs[j];
          }
          
          // sample a topic from the distribution
          r = (double) totprob * (double) randomMT() / (double) 4294967296.0;
          max = probs[0];
          topic = 0;
          while (r>max) {
              topic++;
              max += probs[topic];
          }
           
          z[i] = topic; // assign current word token i to topic j
          wp[wioffset + topic ]++; // and update counts
          dp[dioffset + topic ]++;
          ztot[topic]++;
      }
  }
}
		
void Run_LDA(vector<vector<double> >& DMap, int KK, int* dp, int* wp, double alpha, double beta, int seed)
{
    int *z, *d, *w, *order, *ztot;
    int ntokens = 0;
	int NN = DMap.size();
	int MM = DMap[0].size();
	int nItr = 1000;
	double *probs;
    // seeding
    seedMT( 1 + seed * 2 ); // seeding only works on uneven numbers

    for (int i = 0; i < NN; i++)
        ntokens += (int)Vector_Sum(DMap[i]);

    /* allocate memory */
    z  = new int [ntokens];
    d  = new int [ntokens];
    w  = new int [ntokens];
    order  = new int [ntokens];
    probs  = new double [ntokens];
    ztot  = new int [KK];
    for (int i = 0; i < ntokens; i++)
    {
        z[i] = 0;
        d[i] = 0;
        w[i] = 0;
        order[i] = 0;
        probs[i] = 0;

    }
    for (int kidx = 0; kidx < KK; kidx++)
    {
        ztot[kidx] = 0;
        for (int i = 0; i < NN; i++)
            dp[i*KK+kidx] = 0;
        for (int j = 0; j < MM; j++)
            wp[j*KK+kidx] = 0;
    }

    // copy over the word and document indices into internal format
    int cnt = 0;
    for (int i = 0; i < NN; i++) 
    {
        for (int j = 0; j < MM; j++)    
        {
            for (int windx = 0; windx < (int)DMap[i][j]; windx++)
            {
                w[ cnt ] = j;
                d[ cnt ] = i;
                cnt ++;
            }
        }
    }    

    /* run the model */
    GibbsSamplerLDA( alpha, beta, MM, KK, NN, nItr, 0, ntokens, z, d, w, wp, dp, ztot, order, probs, 0 );
}



