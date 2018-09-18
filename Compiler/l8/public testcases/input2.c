int n,m,a;

void main(){
    for (int i = 2; i < n; i *= 2){
        for (int j = m; j >= 1; j /= 2){
            for (int k = 0; k < m; i *= 2)
            {
                printf("n,m,k\n");
                printf("n,m\n");
            }
        } 
    }
    
    for (int i = 1; i < 10000; i *= 2){
        printf("a = a + 1\n");
    }

    for (int i = 2; i < m; i++){
        for (int j = 2; j < n; j++){
            for (int k = 1; k < m; k++){
                for(int l = 1; l < n; l++){
                    printf("i,j,k,l\n");
                }
            }
        }        
    }
}