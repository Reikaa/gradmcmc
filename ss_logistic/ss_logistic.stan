data {
  int<lower=0> N; // number of years
  real catches[N];
  real logcpue[N];
}
parameters {
  real<lower=2000, upper=10000> K;
  real<lower=.01, upper=.5> r;
  real<lower=.1, upper=10> q;
  real<lower=0.01, upper=1> sd_obs;
  real<lower=.01, upper=2> sd_process;
  real u[N];
}

model {
 real ypred[N];
 real B[N];
 real temp;
 r~normal(.1, .025);
 K~normal(5000, 10);
 q~normal(1, .025);
 sd_process~normal(.2, 1);
 sd_obs~normal(.1, .1);
 u~normal(0, sd_process);
 B[1] <- K*exp(u[1]);
 ypred[1] <- log(B[1])+log(q);
 for(i in 2:N){
   temp <- (B[i-1]+r*B[i-1]*(1-B[i-1]/K)-catches[i-1])*exp(u[i]);
   if(temp<.001){
  //increment_log_prob(-1*(temp-1)^2);
   B[i] <- 1/(2-temp/.001);
   } else {
      B[i] <- temp;
   }
   ypred[i] <- log(B[i]) +log(q);
 }
 logcpue~normal(ypred, sd_obs);
}