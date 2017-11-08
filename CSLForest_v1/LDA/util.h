#ifndef _UTIL_H
#define _UTIL_H

#include <math.h>
#include "common.h"

// Vector functions    
template <class Type>
void vec_cpy( Type dest[], Type Src[], const int n )
{
    for (int i = 0; i<n; i++)
        dest[i] = Src[i];
}


template <class Type>
Type vec_dot( Type x[], Type y[], const int n )
{
    Type S = 0;
    // last n%4 elements
    for (int i = 0; i<n; i++)
        S+=x[i]*y[i];

    return S;
}

template <class Type>
void vec_cross( Type a[], Type b[], Type c[], const int n )
{
    if (n != 3)
    {
        printf ("Error: Cross product is defined only for 3d vecs.");
        exit(0);
    }
    c[0] = a[1]*b[2] - a[2]*b[1];
    c[1] = a[2]*b[0] - a[0]*b[2];
    c[2] = a[0]*b[1] - a[1]*b[0];
}


template <class Type>
void vec_sub( Type x[], Type y[], Type z[], const int n )
{
    for (int i = 0; i<n; i++)
        z[i] = x[i] - y[i];
        
}

template <class Type>
void vec_add( Type x[], Type y[], Type z[], const int n )
{
    for (int i = 0; i<n; i++)
        z[i] = x[i] + y[i];
        
}

template <class Type>
Type vec_sum( Type x[], const int n )
{
    Type S = 0;
    for (int i = 0; i < n; i++)
        S+=x[i];
    return S;
}


template <class Type>
Type vec_norm( Type x[], const int n )
{
    return sqrt ( (double)vec_dot(x, x, n ) );
}


template <class Type>
Type vec_dist( Type x[], Type y[], const int n ) 
{
    Type *z = new Type [n];
    vec_sub (x, y, z, n);
    Type RetVal = vec_norm(z, n);
    delete [] z;
    return RetVal;
}





// Matrix operations

template <class Type>
void mat_scalarmult( Type a[], Type b[], Type c[], const int m,  const int n)
{
    for (int i = 0; i < m; i++)
        for (int j = 0; j < n; j++)
            c[i*n + j] = a[i*n + j] * b[i*n + j];
}

template <class Type>
void mat_scalardiv( Type a[], Type b[], Type c[], const int m,  const int n)
{
    for (int i = 0; i < m; i++)
        for (int j = 0; j < n; j++)
            c[i*n + j] = a[i*n + j] / b[i*n + j];
}

template <class Type>
void mat_multscalar( Type a[], Type b, Type c[], const int m,  const int n)
{
    
    for (int i = 0; i < m; i++)
        for (int j = 0; j < n; j++)
            c[i*n + j] = a[i*n + j] * b;
}

template <class Type>
void mat_addscalar( Type a[], Type b, Type c[], const int m,  const int n)
{
    
    for (int i = 0; i < m; i++)
        for (int j = 0; j < n; j++)
            c[i*n + j] = a[i*n + j] + b;
}

template <class Type>
void mat_scalaradd( Type a[], Type b[], Type c[], const int m,  const int n)
{    
    for (int i = 0; i < m; i++)
        for (int j = 0; j < n; j++)
            c[i*n + j] = a[i*n + j] + b[i*n + j];
}



template <class Type>
void mat_log( Type a[], Type b[], const int m,  const int n)
{
    
    for (int i = 0; i < m; i++)
        for (int j = 0; j < n; j++)
            b[i*n + j] = log (a[i*n + j]);
}



template <class Type>
void mat_transpose( Type a[], Type b[], const int ma, const int na)
{
    Type *c = new Type [ma*na];
    for (int i = 0; i < ma; i++)
        for (int j = 0; j < na; j++)
            c[j*ma + i] = a[i*na + j];
    memcpy(b, c, sizeof(double)*ma*na);
    delete [] c;
}


template <class Type>
void mat_diagvec( Type a[], Type b[], const int n)
{
    memset (b, 0, sizeof(Type)*n*n);
    for (int i = 0; i < n; i++)
        b[i*n + i] = a[i];
}


template <class Type>
void mat_sum( Type a[], Type b[], const int d1, const int d2, const int d3, const int dim)
{
    if (dim == 1 || dim == 2)
    {
        if (d3 != 1)
        {
            printf ("Error: Invalid input.\n");
            exit(0);
        }        
    }
    else if (dim != 3)
    {
        printf ("Error: Invalid dim.\n");
        exit(0);
    }
        
    if (dim == 1)
    {
        Type* vec = new Type [d1];
            
        for (int j = 0; j < d2; j++)
        {
            for (int i = 0; i < d1; i++)
                vec[i] = a[i*d2 + j];
            b[j] = vec_sum(vec, d1);
        }
        delete [] vec;
    }
    else if (dim == 2)
    {
        for (int i = 0; i < d1; i++)
            b[i] = vec_sum(&(a[i*d2]), d2);
        
    }
    else
    {
        memset (b, 0, d1*d2*(sizeof(double)));
        for (int i = 0; i < d1; i++)
            for (int j = 0; j < d2; j++)
                for (int k = 0; k < d3; k++)
                    b[i*d2 + j] += a[k*d1*d2 + i*d2 + j];
    }
    
}

template <class Type>
void mat_mul( Type a[], Type b[], Type c[], const int m1,  const int n1, const int m2, const int n2)
{
    Type sum  = 0;
    if (n1 != m2)
    {
        printf ("Error: invalid matrix dimensions for multiplication.");
        exit(0);
    }
    
    for (int i = 0; i < m1; i++)
        for (int j = 0; j < n2; j++)
        {
            sum = 0;
            for (int k = 0; k < n1; k++)
                sum += a[i*n1 + k] * b[k*n2 + j];
            c[i*n2 + j] = sum;
        }
}




template <class Type>
int vec_find(vector<Type>& Obj, Type elem )
{
    for (int k = 0; k < Obj.size(); k++)
        if (Obj[k] == elem)
            return k;
        
     return -1;
}






template <class Type>
Type Vector_Sum(vector<Type> Vals)
{
    Type Sum = 0;
    for (int i = 0 ; i < Vals.size();i++)
        Sum += Vals[i];
    return Sum;
}

template <class Type>
Type VecMat_Sum(vector<vector<Type> > Vals)
{
    Type Sum = 0;
    unsigned int K = Vals.size();
    for (int k = 0 ; k < K; k++)
        Sum += Vector_Sum(Vals[k]);
    return Sum;
}

template <class Type>
vector <Type> vec_create( Type Src[], const int n )
{
    vector <Type> dest;
    for (int i = 0; i < n; i++)
        dest.push_back(Src[i]);
}

template <class Type>
double CalculateDistance(vector<Type>& Vec1, vector<Type>& Vec2)
{
	if (Vec1.size() != Vec2.size())
		exit(0);
	int D = Vec1.size();
	int NDims = 0;
	
	double Distance = 0.0;

	for (unsigned int i = 0; i < D; i++)
		Distance += pow(Vec1[i] - Vec2[i], 2.0);
	return pow(Distance, 0.5) ;//+ (double)rand()/(double)RAND_MAX;
}


template <class T>
vector<T> GetNormVec(vector<T> Vals)
{
    T Sum = Vector_Sum(Vals);
	vector<T> res(Vals.size(), 0);
	for (int i = 0; i < Vals.size(); i++)
		res[i] = Vals[i] / Sum;
	return res;
}

template <class T>
vector<T> GetNormVec(T* Vals, int M)
{
    T Sum = vec_sum(Vals, M);
	vector<T> res(M, 0);
	for (int i = 0; i < M; i++)
		res[i] = Vals[i] / Sum;
	return res;
}



#endif

