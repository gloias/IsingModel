



#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define BLOCK_SIZE 8
#define GRID_SIZE 8


__global__ void ising_kernel(int *G,int *newG,double *w,int n){

  
  
  int id=blockIdx.x*blockDim.x+threadIdx.x;
	
	unsigned int xBlock = blockDim.x * blockIdx.x;
	unsigned int yBlock = blockDim.y * blockIdx.y;
  
	unsigned int xIndex = xBlock + threadIdx.x;
	unsigned int yIndex = yBlock + threadIdx.y;
	
	
	unsigned int tempX = xBlock + threadIdx.x;
	unsigned int tempY = yBlock + threadIdx.y;
	
	int iterations;
	if (n%(BLOCK_SIZE*GRID_SIZE)==0){
		
		iterations=n/(BLOCK_SIZE*GRID_SIZE);
		
		
	}else{
		
		iterations=n/(BLOCK_SIZE*GRID_SIZE)+1;
		
		
	}
	
	
	
	
	
	for(int i=0;i<iterations;i++){
		xIndex=tempX+GRID_SIZE*BLOCK_SIZE*(i);
		for(int j=0;j<iterations;j++){
			yIndex=tempY+GRID_SIZE*BLOCK_SIZE*(j);
  if(xIndex<n&&yIndex<n){
	double weight=0; 
	
	

    for(int ibor=-2;ibor<3;ibor++){
      for(int jbor=-2;jbor<3;jbor++){

         weight+=w[(ibor+2)*5+jbor+2]*G[((xIndex-ibor+n)%n)*n +(yIndex-jbor+n)%n ];



      }
   }
                
                
                

    if(weight<1e-4&&weight>-(1e-4)){
                    newG[xIndex*n+yIndex]=G[xIndex*n+yIndex];
                }else if(weight>0){
                    newG[xIndex*n+yIndex]=1;
                }else{
                    newG[xIndex*n+yIndex]=-1;

                }
				
				
				

  }
  
  
  
		}
	}
}






void ising( int *G, double *w, int k, int n){

  int *newG,*G2;
  double *w2;

  cudaMallocManaged(&newG,n*n*sizeof(int)); 
  cudaMallocManaged(&G2,n*n*sizeof(int));
  cudaMallocManaged(&w2,25*sizeof(double));
  
  cudaMemcpy( w2, w,  25*sizeof(double),cudaMemcpyHostToDevice);
  cudaMemcpy( G2, G,  n*n*sizeof(int),cudaMemcpyHostToDevice);
 // double total_time=0;
  
  
  
  for(int iter=0;iter<k;iter++){
     bool repeat=true;

     
     
  dim3 grid(GRID_SIZE, GRID_SIZE);
  dim3 block(BLOCK_SIZE, BLOCK_SIZE);
 
//  struct timeval startwtime, endwtime;
//      gettimeofday (&startwtime, NULL);
   ising_kernel<<<grid,block>>>(G2,newG,w2,n);
		cudaDeviceSynchronize();
 //gettimeofday (&endwtime, NULL);
   //double time = (double)((endwtime.tv_usec - startwtime.tv_usec)/1.0e6+ endwtime.tv_sec - startwtime.tv_sec);
    //        total_time+=time;
    

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
 //   printf("Seconds are %lf",total_time);
}






int main()
{
  printf("=================START=========================\n");
   
    double weight[]={0.004,0.016,0.026,0.016,0.004,0.016,0.071,0.117,0.071,0.016,0.026,0.117,0,0.117,0.026,0.016,0.071,0.117,0.071,0.016,0.004,0.016,0.026,0.016,0.004};
    int n=517;
    int X[n*n];
    size_t size;

 
    FILE *fp = fopen("conf-init.bin", "rb");
    size = fread(X, sizeof(int), n * n, fp);
    if(size!=n*n) exit(EXIT_FAILURE);
    fclose(fp);



    

    int k=11;
    

    ising(X,weight,k,n);

    int checkX[n*n];
    FILE *fp2 = fopen("conf-11.bin", "rb");
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

    printf("\n================END==============\n");
    return 0;
}