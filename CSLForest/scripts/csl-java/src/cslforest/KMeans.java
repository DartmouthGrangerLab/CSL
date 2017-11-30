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
public class KMeans extends ClusterBase {
	private double[][] means = null;
	private int[] clusterMemberships = null;
    private double minEnergyChange;


    public KMeans (int k, int D, boolean[] ftInc, int MaxIt, double minEC) {
    	super(k, MaxIt, ftInc);
    	minEnergyChange = minEC;
        means = new double[k][D];
    }


    public int GetClusterLabel (double[] data) {
        int c = 0;
        double bestDist = Double.MAX_VALUE;
    	for (int k = 0; k < means.length; k++) {
            double dist = MathUtil.CalculateDistance(data, means[k]);
            if (dist < bestDist) {
                bestDist = dist;
                c = k;
            }
        }
        return c;
    }


    public void InitClustersSupervised (double[][] data, ArrayList<Integer> pts, int[] labels) {
        int N = pts.size();
        int D = data[0].length;
        ArrayList<Integer> lSet = DataUtil.DetermineLabelSet(pts, labels);
    	int numLabels = lSet.size();
        float[] counts = new float[numLabels];
        double[][] classMeans = new double[numLabels][D];
        for (int i = 0; i < numLabels; i++) {
			Arrays.fill(classMeans[i], 0.0);
		}

        for (int i = 0 ; i < N; i++) {
            int l = labels[pts.get(i)];
            int k = MathUtil.vec_find(lSet, l);

            counts[k]++;
            for (int j = 0; j < D; j++) {
                if (ftInc[j])
                    classMeans[k][j] += data[pts.get(i)][j];
            }
        }

        for (int k = 0 ; k < numLabels; k++) {
            for (int j = 0; j < D; j++) {
                if (ftInc[j])
                    classMeans[k][j] /= counts[k];
            }
        }

    	if (K > numLabels) {
    		means = SimpleMeans(data, pts, labels);
        } else if (K == numLabels) {
        	means = classMeans;
        } else { //K < numLabels
        	int[] clustLbls = OldSimpleMeans(classMeans);
            counts = new float[K];

			for (int i = 0; i < pts.size(); i++) {
			    int l = labels[pts.get(i)];
			    int k = MathUtil.vec_find(lSet, l);
			    for (int j = 0; j < D; j++) {
			        if (ftInc[j]) {
			            means[clustLbls[k]][j] += data[pts.get(i)][j];
			        }
			    }
			    counts[clustLbls[k]]++;
			}

			for (int k = 0 ; k < K; k++) {
			    for (int j = 0; j < D; j++) {
			        if (ftInc[j]) {
			            means[k][j] /= counts[k];
			        }
			    }
			}
        }
    	return;

    }


    public void InitClustersRandomly (double[][] data, ArrayList<Integer> pts) {
        int N = pts.size();
        int D = data[0].length;

        List<Integer> randPointIdxs = new ArrayList<Integer>(N);
        for (int i = 0; i < N; i++) {
        	randPointIdxs.add(i);
        }
        //random sample without replacement
        Collections.shuffle(randPointIdxs, Globals.RSTREAM);
        randPointIdxs = randPointIdxs.subList(0, K);
        for (int i = 0; i < K; i++) {
        	for (int j = 0; j < D; j++) {
	        	if (ftInc[j]) {
	        		means[i][j] = data[pts.get(randPointIdxs.get(i))][j];
	        	}
        	}
        }

    	return;
    }


    public double[][] getMeans () {
    	return means;
    }


    public ArrayList<ArrayList<Integer>> ClusterData (double[][] data, ArrayList<Integer> pts) {
    	int D = data[0].length;
    	clusterMemberships = new int[pts.size()];
    	Arrays.fill(clusterMemberships, -1);

        for (int i = 1; i < maxIt; i++) {
            boolean change = ComputeClustMemberships(data, pts);
            ComputeCentroids(data, D, pts);
            if (!change)
                break;
        }

        //check and fix degenerate clusters
        //handleDegenerateClusters();

    	int N = pts.size();

        ArrayList<ArrayList<Integer>> clusters = new ArrayList<ArrayList<Integer>>(K);
        for (int i = 0; i < K; i++) {
        	clusters.add(new ArrayList<Integer>());
        }
        for (int i = 0; i < N; i++) {
        	clusters.get(clusterMemberships[i]).add(pts.get(i));
        }
        return clusters;

    }


//    private void handleDegenerateClusters () {
//
//    }


    private double[][] SimpleMeans (double[][] data, ArrayList<Integer> pts, int[] labels) {
    	int N = pts.size(); //number of data points
    	int D = data[0].length;
    	ArrayList<Integer> uniqueLabels = DataUtil.Unique(labels);
        int c = uniqueLabels.size(); //number of categories
    	double[][] centroids = new double[K][D];
    	int numCentroids = 0;

        if (K >= N) {
        	for (int i = 0; i < pts.size(); i++) {
        		for (int j = 0; j < D; j++) {
    	        	if (ftInc[j]) {
    	        		centroids[i][j] = data[pts.get(i)][j];
    	        	}
        		}
        		numCentroids++;
        	}
        } else {
            int[] meansPerClass = new int[c];
            Arrays.fill(meansPerClass, K/c); //integer math results in taking the floor, which we WANT

            //handles odd branching factors
            if (MathUtil.Sum(meansPerClass) < K) {
        	//if (IntStream.of(meansPerClass).sum() < K) { //java 8
                //get correct number of centroids overall
                int numNeeded = K - MathUtil.Sum(meansPerClass);
                //int numNeeded = K - IntStream.of(meansPerClass).sum(); //java 8

                List<Integer> bonusClusters = new ArrayList<Integer>(c);
                for (int i = 0; i < c; i++) {
                	bonusClusters.add(i);
                }
                //random sample without replacement
                Collections.shuffle(bonusClusters, Globals.RSTREAM);
                bonusClusters = bonusClusters.subList(0, numNeeded);
                for (int i = 1; i < bonusClusters.size(); i++) {
                    meansPerClass[bonusClusters.get(i)] = meansPerClass[bonusClusters.get(i)] + 1;
                }
        	}

            for (int idx = 0; idx < c; idx++) {
            	double[][] ctrs = null;
            	ArrayList<double[]> classDataList = new ArrayList<double[]>();
            	ArrayList<Integer> classDataPts = new ArrayList<Integer>();
            	for (int i = 0; i < pts.size(); i++) {
            		if (labels[pts.get(i)] == idx+1) {
            			classDataList.add(data[pts.get(i)]);
            			classDataPts.add(classDataList.size()-1);
            		}
            	}
            	double[][] classData = new double[classDataList.size()][D];
            	for (int i = 0; i < classDataList.size(); i++) {
            		classData[i] = classDataList.get(i);
            	}
                if (classData.length > meansPerClass[idx]) { //don't try to make centroids without min amount of data
                	if (meansPerClass[idx] == 0) {
                		ctrs = new double[0][0];
                	} else if (meansPerClass[idx] == 1) {
                		ctrs = new double[1][D];
                		ctrs[0] = classDataList.get(Math.abs(Globals.RSTREAM.nextInt()) % classDataList.size());
                	} else {
	                    KMeans kmeans = new KMeans(meansPerClass[idx], D, ftInc, 20, -1);
	                    kmeans.InitClustersRandomly(classData, classDataPts);
	                    kmeans.ClusterData(classData, classDataPts);
	                    ctrs = kmeans.getMeans();
                    }
            	} else {
                    ctrs = classData;
                }
                for (int i = 0; i < ctrs.length; i++) {
                	centroids[numCentroids] = ctrs[i];
                	numCentroids++;
                }
            }

            //if we don't have enough centroids by contribution from each class
            if (numCentroids < K) {
            	int rem_k = K - numCentroids;

            	List<Integer> tempPts = new ArrayList<Integer>(N);
                for (int i = 0; i < N; i++) {
                	tempPts.add(i);
                }
                //random sample without replacement
                Collections.shuffle(tempPts, Globals.RSTREAM);
                tempPts = tempPts.subList(0, rem_k);

                for (int i = 0; i < tempPts.size(); i++) {
                	for (int j = 0; j < D; j++) {
        	        	if (ftInc[j]) {
        	        		centroids[numCentroids][j] = data[pts.get(tempPts.get(i))][j];
        	        	}
                	}
                	numCentroids++;
                }
            }
        }
        return centroids;
    }


    /**
     * In the original C code, this was clusterBase.SimpleMeans()
     *
     * @param 	classMeans
     * @return	a set of cluster labels
     */
    private int[] OldSimpleMeans (double[][] classMeans) {
        int N = classMeans.length;

        double EPS = 0.0000000001;

        int[] means = new int[K];
        for (int i = 0; i < K; i++) {
        	means[i] = -1;
        }

        double[] bestDist = new double[N];
        for (int i = 0; i < N; i++) {
        	bestDist[i] = Double.MAX_VALUE;
        }

        int[] labels = new int[N];
        means[0] = 0;

        for (int currCluster = 1; currCluster < K; currCluster++) {
            int bestCentroidCand = -1;
            double curBestDistOverall = 0;

            for (int i = 0; i < N; i++) {
                double dist = MathUtil.CalculateDistance(classMeans[i], classMeans[means[currCluster-1]]);
                if (dist < bestDist[i] + EPS) {
                    bestDist[i] = dist;
                }

                if (bestDist[i] > curBestDistOverall) {
                    curBestDistOverall = bestDist[i];
                    bestCentroidCand = i;
                }
            }

            if (bestCentroidCand >= 0)
                means[currCluster] = bestCentroidCand;
        }

        for (int i  = 0 ; i < N; i++) {
            double bestDist2 = Double.MAX_VALUE;
            for (int currCluster = 0; currCluster < K; currCluster++) {
                double dist = MathUtil.CalculateDistance(classMeans[i], classMeans[means[currCluster]]);
                if (dist < bestDist2) {
                    bestDist2 = dist;
                    labels[i] = currCluster;
                }
            }
        }
        return labels;
    }


    private boolean ComputeClustMemberships (double[][] data, ArrayList<Integer> pts) {
        int N = pts.size();
        boolean changed = false;
        for (int i = 0; i < N; i++) {
            double bestDist = Double.MAX_VALUE;
    		int oldLabel = clusterMemberships[i];
            for (int k = 0; k < K; k++) {
                double dist = MathUtil.CalculateDistance(data[pts.get(i)], means[k]);
    			if (dist < bestDist) {
    				bestDist = dist;
    				clusterMemberships[i] = k;
    			}
            }
    		if (oldLabel != clusterMemberships[i]) {
    			changed = true;
    		}
        }
    	return changed;
    }


    private void ComputeCentroids (double[][] data, int D, ArrayList<Integer> pts) {
        int N = pts.size();
        means = new double[K][D];
		for (int i = 0; i < K; i++) {
			Arrays.fill(means[i], 0.0);
		}
    	int[] counts = new int[K];
    	Arrays.fill(counts, 0);
        for (int i = 0; i < N; i++) {
    		int k = clusterMemberships[i];
    		counts[k]++;
            for (int j = 0; j < D; j++) {
                if (ftInc[j])
                	means[k][j] += data[pts.get(i)][j];
            }
    	}

        for (int k = 0; k < K; k++) {
            if (counts[k] > 0) {
    			for (int j = 0; j < D; j++) {
    				means[k][j] /= counts[k];
    			}
            }
        }

    }

}
