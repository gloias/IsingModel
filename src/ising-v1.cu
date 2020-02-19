#include <stdio.h>
#include <stdlib.h>
#include <string.h>






__global__ void ising_kernel(int *G,int *newG,double *w,int n){

  int x,y;
  double weight=0; 

  
  int id=blockIdx.x*blockDim.x+threadIdx.x;

  if(id<n*n){

    //set indexes
    int i,j;
    i=id/n; 
    j=id%n; 

    //influence of neighbors
    for(int ibor=-2;ibor<3;ibor++){
      for(int jbor=-2;jbor<3;jbor++){

         weight+=w[(ibor+2)*5+jbor+2]*G[((i-ibor+n)%n)*n +(j-jbor+n)%n ];



      }
   }
                
                
                
                
    

   
    if(weight<1e-4&&weight>-(1e-4)){
                    newG[i*n+j]=G[i*n+j];
                }else if(weight>0){
                    newG[i*n+j]=1;
                }else{
                    newG[i*n+j]=-1;

                }
  }
}






void ising( int *G, double *w, int k, int n){

  int *newG,*swapG,*G2;
  double *w2;

  cudaMallocManaged(&newG,n*n*sizeof(int)); //save previous G before changing it
  cudaMallocManaged(&G2,n*n*sizeof(int));
  cudaMallocManaged(&w2,25*sizeof(double));
  
  cudaMemcpy( w2, w,  25*sizeof(double),cudaMemcpyHostToDevice);
  cudaMemcpy( G2, G,  n*n*sizeof(int),cudaMemcpyHostToDevice);
  
  for(int iter=0;iter<k;iter++){
	bool repeat=true;

   ising_kernel<<<n,n>>>(G2,newG,w2,n);

    
		cudaDeviceSynchronize();
    

  for(int i=0;i<n;i++){
            for(int j=0;j<n;j++){
			if(repeat&&newG[i*n+j]!=G2[i*n+j]){
                      repeat=false;
            }
                 int   temp=newG[i*n+j];

                    newG[i*n+j]=G2[i*n+j];

                    G2[i*n+j]=temp;
            }
        }
  
   if(repeat){
      break;
  }
  

  }


    cudaMemcpy(G, G2, n*n*sizeof(int),cudaMemcpyDeviceToHost);
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
	printf("k=4:\n")
	k=4	
	
	*fp = fopen("conf-init.bin", "rb");
    size = fread(X, sizeof(int), n * n, fp);
    if(size!=n*n) exit(EXIT_FAILURE);
    fclose(fp);
	
	*fp2 = fopen("conf-4.bin", "rb");
    size = fread(checkX, sizeof(int), n * n, fp2);
    if(size!=n*n) exit(EXIT_FAILURE);
    fclose(fp2);
    flag=true;
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
   
   
   
   
   
   printf("k=11:\n")
	k=11	
	
	*fp = fopen("conf-init.bin", "rb");
    size = fread(X, sizeof(int), n * n, fp);
    if(size!=n*n) exit(EXIT_FAILURE);
    fclose(fp);
	
	*fp2 = fopen("conf-11.bin", "rb");
    size = fread(checkX, sizeof(int), n * n, fp2);
    if(size!=n*n) exit(EXIT_FAILURE);
    fclose(fp2);
    flag=true;
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
   
   
   
   
   printf("\n=========================END==========================");
    return 0;
}
