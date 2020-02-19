#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <sys/time.h>
#define BLOCK_SIZE 8
#define GRID_SIZE 8



//struct timespec start, finish;
//double elapsed;


__global__ void ising_kernel(int *G,int *newG,double *w,int n){

  int x,y; 
  
	__shared__ double shared_w[25];
	__shared__ int shared_G[(BLOCK_SIZE+4)*(BLOCK_SIZE+4)];
	for(int i=0;i<25;i++){
		shared_w[i]=w[i];
	}
	
 
	
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
			
			
			shared_G[(threadIdx.x+2)*(BLOCK_SIZE+4)+threadIdx.y+2]=G[((xIndex+n)%n)*n+(yIndex+n)%n];
			
			if(threadIdx.x==0){
				if (threadIdx.y==0){
					for(int k=0;k<3;k++){
						for(int l=0;l<3;l++){
							if(!(k==0&&l==0)){
						shared_G[(2-k)*(BLOCK_SIZE+4)+(2-l)]=G[((xIndex-k+n)%n)*n+(yIndex-l+n)%n];
							}
						}
						
					}
						
					}else if(threadIdx.y==BLOCK_SIZE-1){
						for(int k=0;k<3;k++){
							for(int l=0;l<3;l++){
								if(!(k==0&&l==0)){
						shared_G[(2-k)*(BLOCK_SIZE+4)+(2+l+threadIdx.y)]=G[((xIndex-k+n)%n)*n+(yIndex+l+n)%n];
								}
							}
					}
						
					}else{ 
						shared_G[(2-1)*(BLOCK_SIZE+4)+(2+threadIdx.y)]=G[((xIndex-1+n)%n)*n+(yIndex+n)%n];
						shared_G[(2-2)*(BLOCK_SIZE+4)+(2+threadIdx.y)]=G[((xIndex-2+n)%n)*n+(yIndex+n)%n];
						
					}
					
					
					
				}else if(threadIdx.x==BLOCK_SIZE-1){
					if (threadIdx.y==0){
					for(int k=0;k<3;k++){
							for(int l=0;l<3;l++){
								if(!(k==0&&l==0)){
						shared_G[(2+k+threadIdx.x)*(BLOCK_SIZE+4)+(2-l)]=G[((xIndex+k+n)%n)*n+(yIndex-l+n)%n];
								}
							}
					}
					}else if(threadIdx.y==BLOCK_SIZE-1){
						
						for(int k=0;k<3;k++){
							for(int l=0;l<3;l++){
								if(!(k==0&&l==0)){
						shared_G[(2+k+threadIdx.x)*(BLOCK_SIZE+4)+(2+l+threadIdx.y)]=G[((xIndex+k+n)%n)*n+(yIndex+l+n)%n];
								}
							}
						}
						
					}else {
						
						shared_G[(2+1+threadIdx.x)*(BLOCK_SIZE+4)+(2+threadIdx.y)]=G[((xIndex+1+n)%n)*n+(yIndex+n)%n];
						shared_G[(2+2+threadIdx.x)*(BLOCK_SIZE+4)+(2+threadIdx.y)]=G[((xIndex+2+n)%n)*n+(yIndex+n)%n];
					}
					
					
				}else{
					if(threadIdx.y==0){ 
						
						shared_G[(2+threadIdx.x)*(BLOCK_SIZE+4)+(2-1)]=G[((xIndex+n)%n)*n+(yIndex-1+n)%n];
						shared_G[(2+threadIdx.x)*(BLOCK_SIZE+4)+(2-2)]=G[((xIndex+n)%n)*n+(yIndex-2+n)%n];
						
					}else if(threadIdx.y==BLOCK_SIZE-1){ 
						shared_G[(2+threadIdx.x)*(BLOCK_SIZE+4)+(2+1+threadIdx.y)]=G[((xIndex+n)%n)*n+(yIndex+1+n)%n];
						shared_G[(2+threadIdx.x)*(BLOCK_SIZE+4)+(2+2+threadIdx.y)]=G[((xIndex+n)%n)*n+(yIndex+2+n)%n];
						
					}
					
					
				}
					__syncthreads();
			
			
		
			
			
			
			
			
  if(xIndex<n&&yIndex<n){
	double weight=0; 
	
	//printf("BLOCK IDX X: %d\n",blockIdx.x);
	//printf("BLOCK IDX Y: %d\n",blockIdx.y);
	

    
    
    
	
    for(int ibor=-2;ibor<3;ibor++){
      for(int jbor=-2;jbor<3;jbor++){

		 weight+=shared_w[(ibor+2)*5+jbor+2]*shared_G[(threadIdx.x+2+ibor)*(BLOCK_SIZE+4) +(threadIdx.y+2+jbor) ];


      }
   }
   
   
  

    
    if(weight<1e-4&&weight>-(1e-4)){
                   // newG[xIndex*n+yIndex]=G[xIndex*n+yIndex];
                    newG[xIndex*n+yIndex]=shared_G[(threadIdx.x+2)*(BLOCK_SIZE+4)+threadIdx.y+2];
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

  int *newG,*swapG,*G2;
  double *w2;

  cudaMallocManaged(&newG,n*n*sizeof(int)); 
  cudaMallocManaged(&G2,n*n*sizeof(int));
  cudaMallocManaged(&w2,25*sizeof(double));
  
  cudaMemcpy( w2, w,  25*sizeof(double),cudaMemcpyHostToDevice);
  cudaMemcpy( G2, G,  n*n*sizeof(int),cudaMemcpyHostToDevice);
  double total_time=0;
  
  
  
  for(int iter=0;iter<k;iter++){
     
     int grid_dimension;
     bool repeat=true;
     
     
  dim3 grid(GRID_SIZE, GRID_SIZE);
  dim3 block(BLOCK_SIZE, BLOCK_SIZE);
// struct timeval startwtime, endwtime;
//       gettimeofday (&startwtime, NULL);
   ising_kernel<<<grid,block>>>(G2,newG,w2,n);
		cudaDeviceSynchronize();
// gettimeofday (&endwtime, NULL);
//   double time = (double)((endwtime.tv_usec - startwtime.tv_usec)/1.0e6   + endwtime.tv_sec - startwtime.tv_sec);
 //           total_time+=time;
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
   // printf("Seconds are %lf ",total_time);
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