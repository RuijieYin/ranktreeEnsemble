\name{predict}
\alias{predict}
\title{
Prediction or Extract Predicted Values for Random Forest, Random Forest Rule or Boosting Models
}
\description{
Obtain predicted values using a random forest \code{(rfsrc)}, random forest extracted rule \code{(rules)} or boosting \code{(gbm)} object. If no new data is provided, it extracts the out-of-bag predicted values of the outcome for the training data.
}
\usage{
predict(object,
        newdata = NULL,
        newdata.pair = FALSE, ...)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
\item{object}{
An object of class \code{rfsrc} generated from the function \code{rforest} or
    \code{gbm} generated from the function \code{rboost}.
}
\item{newdata}{
Test data. If missing, the original training data is used for extracting the out-of-bag predicted values without running the model again.
}
\item{newdata.pair}{
Is \code{newdata} already converted into binary ranked pairs from the \code{pair} function?
}
  \item{...}{Further arguments passed to or from other methods.}
}
\details{
For the boosting \code{(gbm)} object, the cross-validation predicted values are provided if \code{cv.folds>=2}.
}
\value{
\item{value}{Predicted value of the outcome. For the random forest \code{(rfsrc)} object, it is the predicted probability. For the boosting \code{(gbm)} object, it is the fitted
values on the scale of regression function (e.g. log-odds scale). For the random forest extracted rule \code{(rules)} object, it is empty. }
\item{label}{Predicted label of the outcome. }
}
\references{
Lu M. Yin R. and Chen X.S. (2023). Ensemble Methods of Rank-Based Trees for Single Sample Classification with Gene Expression Profiles.
}
\author{
Ruijie Yin (Maintainer,<ruijieyin428@gmail.com>), Chen Ye and Min Lu
}
\examples{
\donttest{
data(tnbc)
######################################################
# Random Forest
######################################################
obj <- rforest(subtype~., data = tnbc[1:100,c(1:5,337)])
predict(obj)$label
predict(obj, tnbc[101:110,1:5])$label

datp <- pair(tnbc[101:110,1:5])
predict(obj, datp, newdata.pair = TRUE)$label
######################################################
# Random Forest Extracted Rule
######################################################
 objr <- extract.rules(obj)
 predict(objr)$label[1:5]
 predict(obj, tnbc[101:110,1:5])$label
######################################################
# Boosting
######################################################
obj <- rboost(subtype~., data = tnbc[1:100,c(1:5,337)])
predict(obj)$label
predict(obj, tnbc[101:110,1:5])$label

}
}
