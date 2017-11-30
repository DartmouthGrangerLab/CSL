package cslforest;

import java.io.*;
import java.text.*;
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
public class BatchTrain {

	public int TestMe() {
		GUI.Error("testing");
		return 5;
	}

	//to be called from matlab
	public double[] TrainAndTest (double[][] data, int[] trainLabels, int numTrees, int maxk, double BF, double FF, int minSize, int maxNodeLevel, String xmlFileName, double[][] testData) {
		CSLForest forest = null;
		int N, D;

	    N = data.length;
	    D = data[0].length;

	    File xmlFile = new File(xmlFileName);
	    PrintWriter fp = null;
	    try {
	    	fp = new PrintWriter(new FileWriter(xmlFile, true));
	    } catch (IOException e) {
	    	e.printStackTrace();
	    }

	    fp.print("<BATCHTRAIN>");
	    fp.print("<NUMTREES>" + numTrees + "</NUMTREES>");
	    fp.print("<MAXK>" + maxk + "</MAXK>");
	    fp.print("<BF>" + BF + "</BF>");
	    fp.print("<FF>" + FF + "</FF>");
	    fp.print("<MINSIZE>" + minSize + "</MINSIZE>");
	    fp.print("<MAXNODELEVEL>" + maxNodeLevel + "</MAXNODELEVEL>");
	    SimpleDateFormat startSDFDate = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
	    Date startNow = new Date();
	    String startDate = startSDFDate.format(startNow);
	    fp.print("<STARTTIME>" + startDate + "</STARTTIME>");

	    forest = new CSLForest(numTrees, D, maxk, BF, FF);
	    forest.BatchTrain(data, trainLabels, D, minSize, maxNodeLevel, ClusterEngine.Method.SUPERVISEDKMEANS);

	    /* The 10th argument is the document histogram map*/
	    N = testData.length;
	    D = testData[0].length;

	    double[] retPtr = new double[N];

	    for (int i = 0; i < N; i++) {
	        retPtr[i] = (double)forest.PredictLabel(testData[i], i);
	    }
	    forest.PrintToXML(fp);

	    SimpleDateFormat endSDFDate = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
	    Date endNow = new Date();
	    String endDate = endSDFDate.format(endNow);
	    fp.print("<ENDTIME>" + endDate + "</ENDTIME>");
	    fp.print("</BATCHTRAIN>");
	    if (fp != null) {
	    	fp.close();
        }

	    return retPtr;

	}
}