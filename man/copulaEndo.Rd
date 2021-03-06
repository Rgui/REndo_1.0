% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/copulaEndo.R
\name{copulaEndo}
\alias{copulaEndo}
\title{Fitting Linear Models Endogeneous Regressors using Gaussian Copula}
\usage{
copulaEndo(y, X, P, param = NULL, type = NULL, method = NULL,
  intercept = NULL)
}
\arguments{
\item{y}{the vector or matrix containing the dependent variable.}

\item{X}{the data frame or matrix containing the regressors of the model, both \emph{exogeneous and endogeneous}. The \emph{last column/s should contain the endogenous variable/s}.}

\item{P}{the matrix.vector containing the endogenous variables.}

\item{param}{the vector of initial values for the parameters of the model to be supplied to the optimization algorithm. The parameters to be estimated are \code{theta = \{b,a,rho,sigma\}}, where
\code{b} are the parameters of the exogenous variables, \code{a} is the parameter of the endogenous variable, \code{rho} is the parameter for the correlation between the error and the endogenous regressor, while 
\code{sigma} is the standard deviation of the structural error.}

\item{type}{the type of the endogenous regressor/s. It can take two values, "continuous" or "discrete".}

\item{method}{the method used for estimating the model. It can take two values, \code{1} or \code{2}, where \code{1} is the maximum likelihood approach described in Park and Gupta (2012),
while \code{2} is the equivalent OLS approach described in the same paper. Method one can be applied only when there is just a single, continous endogenous variable. When there are more than one
continuous endogenous regressors, or they are discrete, the second method is being applied by default.}

\item{intercept}{optional parameter. The model is estimated by default with 
intercept. If no intercept is desired or the regressors matrix \code{X} contains already
a column of ones, intercept should be given the value "no".}
}
\value{
Depending on the method and the type of the variables, it returns the optimal values of the parameters and their standard errors in the case of the second method. 
With one endogenous variable, if the maximum likelihood approach is chosen, the standard errors can be computed by bootsptrapping using the \code{\link{boots}} function from the same package.
}
\description{
Fits linear models with continuous or discrete endogeneous regressors using Gaussian copulas, method presented in Park and Gupta (2012).
This is a statistical technique to address the endogeneity problem, where no external instrumental variables are needed. The important assumption of the model is 
that the endogeneous variables should NOT be normally distributed.
}
\details{
Park and Gupta (2012) proposed a method that allows for the joint estimation of the endogenous regressor and the error term in the structural equation
using copulas. As LIV, the model parameters are estimated using maximum likelihood. The underlying idea is that, using information contained in the observed
data, one selects marginal distributions for the endogenous regressor and the structural error. Then, the copula model enables the construction of a 
flexible multivariate joint distribution allowing a wide range of correlations between the two marginals. For the error, \eqn{\epsilon_{t}}{epsilon_t},
the marginal distribution is assumed to be normal, while the marginal distribution of the endogenous regressor, \eqn{P_{t}}{P_t} is obtained using the 
Epanechnikov kernel density estimator with the bandwidth equal to \deqn{b = 0.9\cdot T^{-1/5}\cdot min(s,IQR/1.34)}{b = 0.9 * T^(-1/5) *  min(s,IQR/1.34)}, where \eqn{IQR}
is the inter-quartile range while \eqn{s} is the data sample standard deviation.
Following Sklar's theorem (Sklar, 1959), where \eqn{H(P),G(\epsilon)}{H(P), G(epsilon)} are the marginal distributions of the endogenous regressors and of the structural error, respectively,
there exists a copula function \eqn{C}{C} such that for all \eqn{p}{p} and \eqn{\epsilon}{epsilon}, the joint distribution function is: 
\deqn{
F(p,\epsilon) = C(H(p),G(\epsilon)) = C(U_{p},U_{\epsilon})
}{F(p, epsilon) = C(H(p).G(epsilon)) = C(U_p, U_epsilon) }
where \eqn{U_{p} = H(p), U_{\epsilon} = G(\epsilon)}{U_p = H(p), U_epsilon = G(epsilon)} are uniform \eqn{(0,1)}{(0,1)} random variables.
Then the joint density function is given by: 
\deqn{
f(p,\epsilon) = c(U_{p},U_{\epsilon})h(p)g(\epsilon)
}{f(p, epsilon) = c(U_p, U_epsion)h(p)g(epsilon)}
where \deqn{c(U_{p},U_{\epsilon}) =\partial^{2}C/\partial{p}\partial\epsilon}{c(U_p, U_epsilon) = d^2(C)/d(p)d(epsilon)}.
Using the Gaussian copula, the joint density function of \eqn{P_{t}}\eqn{P_t} and \eqn{\epsilon_{t}}{epsilon_t} is:

\deqn{f(p_{t},\epsilon_{t}) =\frac{1}{(1-\rho^{2})^{1/2}}exp\left[\frac{-\rho^{2}(\Phi^{-1}(U_{p,t})^{2}+\Phi^{-1}(U_{\epsilon,t})^{2})}{2(1-\rho^{2})}+\frac{\rho\Phi^{-1}(U_{p,t})\Phi^{-1}(U_{\epsilon,t})}{(1-\rho^{2})}\right]\\
 \cdot h(p)\cdot g(\epsilon_{t})}
{f(p_t,epsilon_t) = 1/sqrt(1- rho^2)exp[(-rho^2)*(Phi^(-1)((U_p)^2) + Phi^(-1)(U_epsilon^2))/(2*(1-rho^2)) + rho * Phi^(-1)(U_p) * Phi^(-1)(U_epsilon)/(1-rho^2)]}
Having the joint density function, the model's parameters \eqn{\Theta=\{\alpha,\beta,\sigma_{\epsilon},\rho \}} are obtained by maximising the log-likelihood function. 
The maximum likelihood estimation is performed by the "BFGS" algorithm. When there are two endogenous regressors, there is no need for initial parameters since the method applied is by default the augmented OLS, which
can be specified by using method two - "method=2.
}
\examples{
#load dataset dataCopC1, where P is endogenous, continuous and not normally distributed
data(dataCopC1)
y <- dataCopC1[,1]
X <- dataCopC1[,2:5]
P <- dataCopC1[,5]
c1 <- copulaEndo(y, X, P, type = "continuous", method = 1, intercept="no")
c1
# to obtain the standard errors use the boots() function
# se.c1 <- boots(10, y, X, P, param = c(1,1,-2,-0.5,0.2,1), intercept= "no")

# an alternative model can be obtained using "method = 2".
c12 <- copulaEndo(y, X, P, type = "continuous", method = 2)
c1

# load datset with 2 continuous, non-normally distributed endogeneous regressors.
# with 2 endogenous regressors the default method is the augmented OLS.
#data(dataCopC2)
#y <- dataCopC2[,1]
#X <- dataCopC2[,2:6]
#P <- dataCopC2[,5:6]
#c2 <- copulaEndo(y, X, P, type = "continuous")
#summary(c2)

# load dataset with 1 discrete endogeneous variable. 
# having more than 1 discrete endogenous regressor is also possible
data(dataCopDis)
y <- dataCopDis[,1]
X <- dataCopDis[,2:5]
P <- dataCopDis[,5]
c3 <- copulaEndo(y, X, P, type = "discrete", intercept=FALSE)
c3
}
\author{
The implementation of the model by Raluca Gui based on the paper of Park and Gupta (2012).
}
\references{
Park, S. and Gupta, S., (2012), 'Handling Endogeneous Regressors by Joint Estimation Using Copulas', Marketing Science, 31(4), 567-86.
}

