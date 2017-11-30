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
public class ClusterEngine {
	private Method clusterMethod; //1 = kmeans, 2 = GMM
    private ClusterBase basePtr = null;

    public enum Method { DEFAULT, SUPERVISEDKMEANS, UNSUPERVISEDKMEANS, ONLINEKMEANS, GMM }

	public ClusterEngine (int K, int D, boolean[] ftInc, Method clstMethod) {
		clusterMethod = clstMethod;

	    if (clstMethod == Method.DEFAULT) {
	        clstMethod = Method.SUPERVISEDKMEANS;
	    }

	    switch (clusterMethod) {
	        case SUPERVISEDKMEANS:
	        	basePtr = new KMeans(K, D, ftInc, 20, -1);
	        	break;
	        case UNSUPERVISEDKMEANS:
	        	basePtr = new KMeans(K, D, ftInc, 20, -1);
	        	break;
	        case ONLINEKMEANS:
	        	GUI.Error("Unsupported clustering method selected.");
	        	break;
	        case GMM:
	        	GUI.Error("Unsupported clustering method selected.");
	        	break;
	        default:
	        	GUI.Error("Unsupported clustering method selected.");
	    }
	    clusterMethod = clstMethod;
	}


	public ArrayList<ArrayList<Integer>> ClusterData (double[][] data, ArrayList<Integer> pts, int[] labels) {
		switch (clusterMethod) {
	        case SUPERVISEDKMEANS:
	        	((KMeans)basePtr).InitClustersSupervised(data, pts, labels);
	        	break;
	        case UNSUPERVISEDKMEANS:
	        	((KMeans)basePtr).InitClustersRandomly(data, pts);
	        	break;
	        case ONLINEKMEANS:
	        	GUI.Error("Unsupported clustering method selected.");
	        	break;
	        case GMM:
	        	GUI.Error("Unsupported clustering method selected.");
	        	break;
	        default:
	        	GUI.Error("Unsupported clustering method selected.");
	    }
        return basePtr.ClusterData(data, pts);
	}


	public int GetClusterLabel(double[] data) {
	    return basePtr.GetClusterLabel(data);
	}


	public static boolean Contains1Cluster (ArrayList<ArrayList<Integer>> clusters) {
		int numClusters = 0;
		for (ArrayList<Integer> mems : clusters) {
			if (mems.size() > 0) {
				numClusters++;
			}
		}
		return (numClusters < 2);
	}

}
