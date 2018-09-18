int n,m;
int a;
void main(){
    for (int i = 0; i < n; i++){
        for (int j = m; j >= 1; j /= 2){
            printf("n,m");
        } 
    }
    
    for (int i = 1; i < 10000; i *= 2){
        for (int j = 2; j < n; j++){
            for (int k = 1; k < n; k++){
                for (int l = m; l >= 0; l--){
                    printf("Hello World\n");
                }
            }
        }
    }
}