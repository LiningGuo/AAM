rm(list=ls())
workingDir = "";
setwd(workingDir)

product_method_Delta <- function(EM_beta, EM_se, MO_beta, MO_se, verbose=F){
  EO_beta <- EM_beta * MO_beta
  
  if (verbose) {
    print(paste("Indirect effect = ", round(EM_beta, 2)," x ", round(MO_beta,2), " = ", round(EO_beta, 3)))
  }
  
  # Calculate indirect effect SE using Delta method (aka Sobel test) 
  EO_se = sqrt( (MO_beta^2 * EM_se^2) + (EM_beta^2 * MO_se^2) )
  
  # put data into a tidy df
  df <-data.frame(b = EO_beta,
                  se = EO_se,
                  lo_ci = EO_beta - 1.96 * EO_se,
                  up_ci= EO_beta + 1.96 * EO_se)
  
  if (verbose) {
    print(paste("SE of indirect effect = ", round(df$se, 2)))
  }
  
  #df<-round(df,3)
  return(df)
}

beta_se <- read.table('em_mo_beta_se_bd.txt',header = T)
Product_delta1 <- product_method_Delta(beta_se$EM_beta, beta_se$EM_se, beta_se$MO_beta1, beta_se$MO_se1, verbose=F)
Product_delta1$pval <- 2 * pnorm(abs(Product_delta1$b/Product_delta1$se), lower.tail=FALSE)
