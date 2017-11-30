package cslforest;

import java.io.*;
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
class CSLForest {
	private double bagFrac = 0.0;
	private double featFrac = 0.0;
	private CSLTree[] trees;
	private ArrayList<Integer> labelSet;


	CSLForest (int Nt, int M, int maxK, double bf, double ff) {
	    bagFrac = bf;
	    featFrac = ff;

	    trees = new CSLTree[Nt];
		for (int i = 0; i < Nt; i++) {
	        trees[i] = new CSLTree(M, maxK, featFrac);
		}
	}


	public int PredictLabel (double[] x, int imageNum) {

		ArrayList<Double> fullPosterior = new ArrayList<Double>(labelSet.size());
		for (int i = 0; i < labelSet.size(); i++) {
			fullPosterior.add(0.0);
		}
		ArrayList<double[]> treePosteriors = new ArrayList<double[]>(trees.length);

	    //ask each tree for it's opinion
		for (int i = 0; i < trees.length; i++) {
			treePosteriors.add(trees[i].LabelPosterior(x, imageNum));
	    }

		for (int i = 0; i < trees.length; i++) {
			for (int l = 0; l < labelSet.size(); l++) {
				fullPosterior.set(l, fullPosterior.get(l) + treePosteriors.get(i)[l]);
			}
		}

		return labelSet.get(MathUtil.vec_maxIdx(fullPosterior));

	}


	public void BatchTrain (double[][] data, int[] labels, int D, int minSize, int maxNodeLevel, ClusterEngine.Method clusterMethod) {

	    labelSet = DataUtil.DetermineLabelSet(labels);
	    ArrayList<ArrayList<Integer>> indices = new ArrayList<ArrayList<Integer>>(trees.length);
	    for	(int i = 0; i < trees.length; i++) {
			indices.add(getBaggedData(labels));
	    }

		for	(int i = 0; i < trees.length; i++) {
	        trees[i].BatchTrain(data, labels, labelSet, indices.get(i), D, minSize, maxNodeLevel, clusterMethod);
	    }

	}


	public void PrintToXML (PrintWriter fp) {
		for	(int i = 0; i < trees.length; i++) {
			fp.print("<TREE>");
			fp.print("<NUM>" + (i+1) + "</NUM>");
	        trees[i].PrintToXML(fp);
	        fp.print("</TREE>");
	    }
	}


	private ArrayList<Integer> getBaggedData (int[] labels) {
	    ArrayList<Integer> baggedIdxs = new ArrayList<Integer>();
	    for (int lidx = 0; lidx < labelSet.size(); lidx++) {
	    	ArrayList<Integer> idxs = MathUtil.vectorFindAll(labels, (int)labelSet.get(lidx));
	        Collections.shuffle(idxs, Globals.RSTREAM);
	        int n = Math.max(1, (int)(bagFrac*idxs.size()));
	        for (int j = 0; j < n; j++) {
	            baggedIdxs.add(idxs.get(j));
	        }
	    }
	    return baggedIdxs;
	}
}
