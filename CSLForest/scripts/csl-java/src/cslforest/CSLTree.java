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
class CSLTree {
	private ArrayList<TNode> nodes = new ArrayList<TNode>();
    private TNode root;
	private int maxK;


	CSLTree (int M, int K, double ff) {
		nodes.add(new TNode(null, 0, 0, M, ff));
		maxK = K;
	}


	public double[] LabelPosterior (double[] x, int imageNum) {

		TNode T = nodes.get(0);

		while (T.children.size() > 0) {
	        if (imageNum != -1) {
				T.testMembers.add(imageNum); //store test memberships for visualizations later
			}
			int br = T.clst.GetClusterLabel(x);
			T = T.children.get(br);
	    }
	    if (imageNum != -1) {
			T.testMembers.add(imageNum); //store test memberships for visualizations later
		}

	    double[] result = new double[T.memCnt.size()];
	    double denom = (double)MathUtil.Sum(T.memCnt);
	    for (int i = 0; i < result.length; i++) {
	        result[i] = T.memCnt.get(i) / denom;
	    }

		return result;
	}


	public void BatchTrain (double[][] data, int[] allLabels, ArrayList<Integer> lSet, ArrayList<Integer> pts, int D, int minSize, int maxNodeLevel, ClusterEngine.Method clusterMethod) {

		LinkedList<QNode> Q = new LinkedList<QNode>(); //actually a FIFO queue
	    int maxHt = 0;
	    ArrayList<Integer> ls = null;

	    QNode first = new QNode();
	    first.members = pts;
	    root = nodes.get(0);
	    root.memCnt = DataUtil.DetermineMemberCounts(first.members, allLabels, lSet);
	    first.tN = root;


	    Q.add(first);
	    int totNodeCnt = 1;

	    while (Q.size() > 0) {
	        QNode qNd = Q.get(0);
	        Q.remove();
	        TNode tN = qNd.tN;

	        tN.RandProject(D);
//	        if (!tN.RandProject(data, D, qNd.members)) {
//	            //failed to project into random subspace in a linearly separable manner
//	            //make tN a leaf node
//	            continue;
//	        }

	        if (totNodeCnt == 1) { //this is the root
	            tN.trainMembers = qNd.members; //TEMP - only needed for useful XML output
	        }

	        ls = DataUtil.DetermineLabelSet(qNd.members, allLabels);

	        tN.clst = new ClusterEngine(maxK, D, tN.ftInc, clusterMethod);

	        //the call below returns indices in the original labelsFullset array
	        ArrayList<ArrayList<Integer>> clusters = tN.clst.ClusterData(data, qNd.members, allLabels);
	        if (ClusterEngine.Contains1Cluster(clusters)) {
	        	//failed to project into random subspace in a linearly separable manner - make tN a leaf node
	        	continue;
	        }

	        for (int k = 0; k < clusters.size(); k++) {
				if (clusters.size() == 0)
					continue;
	            TNode child = new TNode(tN, totNodeCnt, tN.nodeLvl+1, D, root.featFrac);
				child.memCnt = DataUtil.DetermineMemberCounts(clusters.get(k), allLabels, lSet);
	        	if (child.nodeLvl > maxHt)
					maxHt = child.nodeLvl;
				totNodeCnt++;

				nodes.add(child);
				tN.children.add(child);

				ls = DataUtil.DetermineLabelSet(clusters.get(k), allLabels);

	            child.trainMembers = clusters.get(k); //TEMP - only needed for useful XML output

				if (ls.size() > 1 && clusters.get(k).size() > minSize && tN.nodeLvl < maxNodeLevel) {
					QNode newQNd = new QNode();
					newQNd.members = clusters.get(k);
					newQNd.tN = child;
					Q.add(newQNd);
				}
			}
	    }
	}


	public void PrintToXML (PrintWriter fp) {
	    PrintNodeToXML(root, fp);
	}


	private void PrintNodeToXML (TNode node, PrintWriter fp) {
		fp.print("<NODE>");
		fp.print("<NUM>" + node.nId + "</NUM>");
		fp.print("<LEVEL>" + (node.nodeLvl + 1) + "</LEVEL>");
		fp.print("<NUMCLUSTERS>" + node.children.size() + "</NUMCLUSTERS>");
		fp.print("<FEATFRAC>" + node.featFrac + "</FEATFRAC>");
		fp.print("<SEPERABLETHRESH>" + node.seperableThresh + "</SEPERABLETHRESH>");
		fp.print("<QUALITY>" + node.quality + "</QUALITY>");
	    for (int j = 0; j < node.memCnt.size(); j++) {
	    	fp.print("<MEMCNT>" + node.memCnt.get(j) + "</MEMCNT>");
	    }
	    for (int j = 0; j < node.trainMembers.size(); j++) {
	    	fp.print("<TRAINMEMBER>" + node.trainMembers.get(j) + "</TRAINMEMBER>");
	    }
	    for (int j = 0; j < node.testMembers.size(); j++) {
	    	fp.print("<TESTMEMBER>" + node.testMembers.get(j) + "</TESTMEMBER>");
	    }

	    for (int i = 0; i < node.children.size(); i++) {
	        PrintNodeToXML(node.children.get(i), fp); //recursion!
	    }

	    fp.print("</NODE>");
	}
}
