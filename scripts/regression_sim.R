x=seq(1,100)
data<-5*x+10+rnorm(100,0,20)
plot(data~x)
model<-lm(data~x)
model
abline(model$coefficients)
summary(model)



lm_likelihood<-function(par)
{
  y_fit<-par[1]*x+par[2]
  -sum(dnorm(y_fit-data, log=T))
}
model_optim<-optim(c(2,8), lm_likelihood)
model_optim


polynomial_rmse<-function(par)
{
  y_fit<-par[1]*x+par[2]*x^2+par[3]
  rmse<-sqrt(mean((y_fit-data)^2))
}
model_optim2<-optim(c(2,0,8), polynomial_rmse)
model_optim2
