#ifndef _COMMON_H
#define _COMMON_H
#include <mex.h>
#include <math.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
//#include <windows.h>
#include <vector>
#include <list>
#include <algorithm>
#include <omp.h>
#include <time.h>

//#include "C:\Program Files\WordNet\2.1\src\include\wn.h" 
#define EPS (1e-20)
#define INF (1e+300)

using namespace std;

struct Pair
{
	int key;
	double value;
    
public:
	Pair(int k, double v)
	{
		key = k;
		value = v;
       
	}
    static bool ComparePairsAscend (Pair first, Pair second)
    {
        if (first.value < second.value)
	        return true;
        else
	        return false;
    }

    static bool ComparePairsDescend(Pair first, Pair second)
    {
        if (first.value > second.value)
	        return true;
        else
	        return false;    
    }
};
#endif
