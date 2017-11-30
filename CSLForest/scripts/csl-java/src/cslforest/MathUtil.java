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
public class MathUtil {

	public static <T> ArrayList<Integer> vectorFindAll (ArrayList<T> vec, T val) {
		ArrayList<Integer> idxs = new ArrayList<Integer>();
	    for (int i = 0; i < vec.size(); i++) {
	        if (vec.get(i) == val) {
	            idxs.add(i);
	        }
	    }
	    return idxs;
	}

	public static <T> ArrayList<Integer> vectorFindAll (T[] vec, T val) {
		ArrayList<Integer> idxs = new ArrayList<Integer>();
	    for (int i = 0; i < vec.length; i++) {
	        if (vec[i] == val) {
	            idxs.add(i);
	        }
	    }
	    return idxs;
	}

	public static ArrayList<Integer> vectorFindAll (int[] vec, int val) {
		ArrayList<Integer> idxs = new ArrayList<Integer>();
	    for (int i = 0; i < vec.length; i++) {
	        if (vec[i] == val) {
	            idxs.add(i);
	        }
	    }
	    return idxs;
	}


	public static <T> int vec_find (ArrayList<T> Obj, T elem) {
	    for (int k = 0; k < Obj.size(); k++) {
	        if (Obj.get(k) == elem) {
	            return k;
	        }
	    }

	     return -1;
	}


	public static int Sum (ArrayList<Integer> vals) {
	    int sum = 0;
	    for (int i = 0; i < vals.size(); i++)
	        sum += vals.get(i);
	    return sum;
	}
	public static int Sum (int[] vals) {
	    int sum = 0;
	    for (int i = 0; i < vals.length; i++)
	        sum += vals[i];
	    return sum;
	}


	public static int vec_maxIdx (ArrayList<Double> vals) {
	    int idx = 0;
	    double maxVal = vals.get(0);
	    int N = vals.size();
	    for (int i = 0 ; i < N; i++) {
	        if (vals.get(i) > maxVal) {
	            maxVal = vals.get(i);
	            idx = i;
	        }
	    }
	    return idx;
	}


	public static double CalculateDistance (double[] a, ArrayList<Double> b) {
		double d = 0;
		double t = 0;
		for (int j = 0; j < b.size(); j++) {
			t = b.get(j) - a[j];
			d += t*t;
		}
		return d;
	}

	public static double CalculateDistance (double[] a, double[] b) {
		double d = 0;
		double t = 0;
		for (int j = 0; j < b.length; j++) {
			t = b[j] - a[j];
			d += t*t;
		}
		return d;
	}


}
