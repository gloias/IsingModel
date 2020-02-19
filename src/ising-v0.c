#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <math.h>
#include  <time.h>
#include  <sys/time.h>

//struct timespec start, finish;


void ising(int *G,double *w, int k, int n){
  double total_time=0;
    int *matrix=(int*)malloc(n*n*sizeof(int));
    for(int iter=0;iter<k;iter++){
       bool repeat=true;
    //  struct timeval startwtime, endwtime;
      // gettimeofday (&startwtime, NULL); 
        for(int i=0;i<n;i++){
            for(int j=0;j<n;j++){


                double weight=0;
                for(int ibor=-2;ibor<3;ibor++){
                    for(int jbor=-2;jbor<3;jbor++){


                        weight+=w[(ibor+2)*5+jbor+2]*G[((i-ibor+n)%n)*n +(j-jbor+n)%n ];






                    }
                }

                if(weight<1e-4&&weight>-(1e-4)){
                    matrix[i*n+j]=G[i*n+j];
                }else if(weight>0){
                    matrix[i*n+j]=1;

                }else{
                    matrix[i*n+j]=-1;

                }






            }
        }




 //gettimeofday (&endwtime, NULL);
 //  double time = (double)((endwtime.tv_usec - startwtime.tv_usec)/1.0e6 + endwtime.tv_sec - startwtime.tv_sec);
        //    total_time+=time;


        double temp;
        for(int i=0;i<n;i++){
            for(int j=0;j<n;j++){


                    if(repeat&&G[i*n+j]!=matrix[i*n+j]){
                        repeat=false;
                    }
                    temp=G[i*n+j];

                    G[i*n+j]=matrix[i*n+j];
                    matrix[i*n+j]=temp;

            }
        }
        
        if(repeat){
            break;
        }

    }

free(matrix);
}





int main()
{
  printf("==========================START=============================\n");
   
    double weight[]={0.004,0.016,0.026,0.016,0.004,0.016,0.071,0.117,0.071,0.016,0.026,0.117,0,0.117,0.026,0.016,0.071,0.117,0.071,0.016,0.004,0.016,0.026,0.016,0.004};
    int n=517;
    int X[n*n];
    size_t size;

 
    FILE *fp = fopen("conf-init.bin", "rb");
    size = fread(X, sizeof(int), n * n, fp);
    if(size!=n*n) exit(EXIT_FAILURE);
    fclose(fp);



    

    int k=1;
    

    ising(X,weight,k,n);

    int checkX[n*n];
    printf("k=1:\n");
    FILE *fp2 = fopen("conf-1.bin", "rb");
    size = fread(checkX, sizeof(int), n * n, fp2);
    if(size!=n*n) exit(EXIT_FAILURE);
    fclose(fp2);
    bool flag=true;
    for(int i=0;i<n;i++){
        for(int j=0;j<n;j++){
            if(checkX[i*n+j]!=X[i*n+j]){
                printf("\nWRONG IMPLEMENTATION\n");
                flag=false;
                break;
            }


        }
        if(!flag){
            break;
        }
    }

    if(flag){
        printf("\nCORRECT IMPLEMENTATION\n");
    }
 


  
	printf("k=4:\n");
	k=4	;
	int X2[n*n];

	FILE *fpA = fopen("conf-init.bin", "rb");
    size = fread(X2, sizeof(int), n * n, fpA);
    if(size!=n*n) exit(EXIT_FAILURE);
    fclose(fpA);
	int checkX2[n*n];
	FILE *fp3 = fopen("conf-4.bin", "rb");
    size = fread(checkX2, sizeof(int), n * n, fp3);
    if(size!=n*n) exit(EXIT_FAILURE);
    fclose(fp3);
 
 ising(X2,weight,k,n);
    flag=true;
    for(int i=0;i<n;i++){
        for(int j=0;j<n;j++){
            if(checkX2[i*n+j]!=X2[i*n+j]){
                printf("\nWRONG IMPLEMENTATION\n");
                flag=false;
                break;
            }


        }
        if(!flag){
            break;
        }
    }

    if(flag){
        printf("\nCORRECT IMPLEMENTATION\n");
    }
   
   
   
   
   
   printf("k=11:\n");
	k=11	;
	int X3[n*n];
	FILE *fpB = fopen("conf-init.bin", "rb");
    size = fread(X3, sizeof(int), n * n, fpB);
    if(size!=n*n) exit(EXIT_FAILURE);
    fclose(fpB);
	int checkX3[n*n];
	FILE *fp4 = fopen("conf-11.bin", "rb");
    size = fread(checkX3, sizeof(int), n * n, fp4);
    if(size!=n*n) exit(EXIT_FAILURE);
    fclose(fp4);
    flag=true;
ising(X3,weight,k,n);
    for(int i=0;i<n;i++){
        for(int j=0;j<n;j++){
            if(checkX3[i*n+j]!=X3[i*n+j]){
                printf("\nWRONG IMPLEMENTATION\n");
                flag=false;
                break;
            }


        }
        if(!flag){
            break;
        }
    }
   
  if(flag){
        printf("\nCORRECT IMPLEMENTATION\n");
    }
      
   
   
   printf("\n=========================END==========================");
    return 0;
}