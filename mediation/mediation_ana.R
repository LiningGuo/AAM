rm(list=ls())
library(mediation)
library(openxlsx)
setwd('')
data1 <- read.xlsx('R_imp_gmv.xlsx',sheet = 1)
data <- as.data.frame(scale(data1))
a <- lm(AAM ~ U+covs, data=data) 
b <- lm(brain ~ U+AAM+U:AAM+covs, data=data)
set.seed(1234)
contcont <- mediate(a, b, sims=1000, treat="U", mediator="AAM") #treat为起始变量
summary(contcont)

ACME_b <- contcont$d.avg
ACME_ci <- contcont$d.avg.ci
ACME_p <- contcont$d.avg.p
ADE_b <- contcont$z.avg
ADE_ci <- contcont$z.avg.ci
ADE_p <- contcont$z.avg.p
Tot_b <- contcont$tau.coef
Tot_ci <- contcont$tau.ci
Tot_p <- contcont$tau.p
Prop_b <- contcont$n.avg
Prop_ci <- contcont$n.avg.ci
Prop_p <- contcont$n.avg.p

aa <- summary(a)
a_b <- aa$coefficients[2,1]
a_p <- aa$coefficients[2,4]
bb <- summary(b)
b_b <- bb$coefficients[3,1]
b_p <- bb$coefficients[3,4]
result <- cbind(c(ACME_b,ACME_ci,ACME_p),c(ADE_b,ADE_ci,ADE_p),c(Tot_b,Tot_ci,Tot_p),
                c(Prop_b,Prop_ci,Prop_p),c(a_b,a_p,b_b,b_p))
colnames(result) <- c('ACME','ADE','Tot','Prop','a_b_beta_pval')
write.xlsx(as.data.frame(result),'result.xlsx')
plot(contcont)
