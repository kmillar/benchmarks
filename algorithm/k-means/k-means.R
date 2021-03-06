# k-means - R internal k-means based implementation
# 
# Author: Haichuan Wang
#
# k-means using R built-in k-means implementation
###############################################################################
app.name <- "k-means"
source('setup_k-means.R')

run <- function(dataset) {
    ncluster <- dataset$ncluster
    niter <- dataset$niter
    Points <- dataset$Points
    vPoints <- t(simplify2array(Points))
    
    res<-kmeans(vPoints, ncluster, iter.max=niter);
    cat("Centers:\n")
    print(res$centers);
    cat("Sizes:\n")
    print(res$size);
}

if (!exists('harness_argc')) {
    data <- setup(commandArgs(TRUE))
    run(data)
}
