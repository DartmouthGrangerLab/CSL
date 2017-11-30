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
public class DataUtil {
	public static ArrayList<Integer> DetermineMemberCounts (ArrayList<Integer> members, ArrayList<Integer> fullLabelSet, ArrayList<Integer> labelSet) {
		ArrayList<Integer> labelCnts = new ArrayList<Integer>(labelSet.size());
		for (int i = 0; i < labelSet.size(); i++) {
			labelCnts.add(0);
		}
	    for (int i = 0 ; i < members.size(); i++) {
			int idx = MathUtil.vec_find(labelSet, fullLabelSet.get(members.get(i)));
			labelCnts.set(idx, labelCnts.get(idx)+1);
		}
	    return labelCnts;
	}

	public static ArrayList<Integer> DetermineMemberCounts (ArrayList<Integer> members, int[] fullLabelSet, ArrayList<Integer> labelSet) {
		ArrayList<Integer> labelCnts = new ArrayList<Integer>(labelSet.size());
		for (int i = 0; i < labelSet.size(); i++) {
			labelCnts.add(0);
		}
	    for (int i = 0 ; i < members.size(); i++) {
			int idx = MathUtil.vec_find(labelSet, fullLabelSet[members.get(i)]);
			labelCnts.set(idx, labelCnts.get(idx)+1);
		}
	    return labelCnts;
	}


	public static ArrayList<Integer> DetermineLabelSet (ArrayList<Integer> fullLabelSet) {
		ArrayList<Integer> labelSet = new ArrayList<Integer>();
	    for (int i = 0; i < fullLabelSet.size(); i++) {
	        if (MathUtil.vec_find(labelSet, fullLabelSet.get(i)) == -1) {
	        	labelSet.add(fullLabelSet.get(i));
	        }
	    }
	    return labelSet;
	}

	public static ArrayList<Integer> DetermineLabelSet (int[] fullLabelSet) {
		ArrayList<Integer> labelSet = new ArrayList<Integer>();
	    for (int i = 0; i < fullLabelSet.length; i++) {
	        if (MathUtil.vec_find(labelSet, fullLabelSet[i]) == -1) {
	        	labelSet.add(fullLabelSet[i]);
	        }
	    }
	    return labelSet;
	}


	public static ArrayList<Integer> DetermineLabelSet (ArrayList<Integer> Pts, int[] fullLabelSet) {
		ArrayList<Integer> labelSet = new ArrayList<Integer>();
	    for (int i = 0; i < Pts.size(); i++) {
	        if (MathUtil.vec_find(labelSet, fullLabelSet[Pts.get(i)]) == -1) {
	            labelSet.add(fullLabelSet[Pts.get(i)]);
	        }
	    }
	    return labelSet;
	}



	public static <T> ArrayList<Integer> Unique (int[] myArray) {
		HashSet<Integer> temp = new HashSet<Integer>();
		for (int i = 0; i < myArray.length; i++) {
			temp.add(myArray[i]);
		}
		return new ArrayList<Integer>(temp);
	}

	public static <T> ArrayList<T> Unique (T[] myArray) {
		HashSet<T> temp = new HashSet<T>(Arrays.asList(myArray));
		return new ArrayList<T>(temp);
	}

}
