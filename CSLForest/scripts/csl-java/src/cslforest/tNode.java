package cslforest;

import java.util.*;

/*
This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
Anyone is free to use this code. When using this code, you must cite:
1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
       available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
       available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
*/
class TNode {
    public ArrayList<Integer> memCnt = new ArrayList<Integer>();
    public ArrayList<TNode> children = new ArrayList<TNode>();
    public TNode parent;
    public ClusterEngine clst = null;

    public double quality = 0;
    public int nodeLvl;
    public int nId;

    public double featFrac;
    public boolean[] ftInc;
    public double seperableThresh = 10;

    public ArrayList<Integer> trainMembers; //only needed for useful XML output
    public ArrayList<Integer> testMembers = new ArrayList<Integer>(); //only needed for useful XML output


	public TNode (TNode p, int nodeId, int ndLvl, int D, double ff) {
		parent = p;
		nodeLvl = ndLvl;
		nId = nodeId;
		featFrac = ff;
		ftInc = new boolean[D];
		for (int i = 0; i < D; i++) {
			ftInc[i] = false;
		}
	}


	public boolean RandProject (double[][] data, int D, ArrayList<Integer> pts) {
		int attempt;
		for (attempt = 0; attempt < 1; attempt++) {
		    Project(D, featFrac);
		    //if (IsDataSeperable(data, D, pts))
		        break;
		}
		if (attempt == 5)
		    return false;
		else
		    return true;
	}


	public void RandProject (int D) {
		Project(D, featFrac);
	}


	public void Project (int D, double ff) {
		ArrayList<Integer> idxs = new ArrayList<Integer>(D);
		for (int i = 0; i < D; i++) {
		    idxs.add(i);
		}

		Collections.shuffle(idxs, Globals.RSTREAM);
		int n = Math.max(1, (int)(ff*D));

		for (int j = 0; j < n; j++) {
			if (j < n) {
				ftInc[idxs.get(j)] = true;
			} else {
				ftInc[idxs.get(j)] = false;
			}
		}
	}


//	public boolean IsDataSeperable (float[][] data, int D, ArrayList<Integer> pts) {
//		//compute pairwise distance sum
//
//		double dist = 0;
//		for (int i = 0; i < pts.size(); i++) {
//		    for (int j = i+1; j < pts.size(); j++) {
//		        for (int m = 0; m < D; m++) {
//		            if (ftInc[m])
//		                dist+= Math.abs(data[pts.get(i)][m] - data[pts.get(j)][m]);
//		        }
//		    }
//		}
//
//		if (dist < seperableThresh)
//		    return false;
//		else
//		    return true;
//	}

}