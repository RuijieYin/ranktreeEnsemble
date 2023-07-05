\name{importance}
\alias{importance}
\title{
Variable Importance Index for Each Predictor
}
\description{
The function computes variable importance for each predictor from a rank-based random forests model or boosting model. A higher value indicates a more important predictor. The random forest implementation was performed via the function \code{vimp} directly imported from the \pkg{randomForestSRC}
  package.  Use the command \code{package?randomForestSRC} for more information. The boosting implementation was performed via the function \code{relative.influence} directly imported from the \pkg{gbm}
  package. For technical details, see the
  vignette: \code{utils::browseVignettes("gbm")}.
}
\usage{
importance(object, ...)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{object}{
An object of class \code{rfsrc} generated from the function \code{rforest} or
    \code{gbm} generated from the function \code{rboost}.
}
  \item{...}{Further arguments passed to or from other methods.}
}
\value{
For the boosting model, a vector of variable importance values is given. For the random forest model, a matrix of variable importance values is given for the variable importance index for \code{all} the class labels, followed by the index for each class label.
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
obj <- rforest(subtype~., data = tnbc[,c(1:10,337)])
importance(obj)
######################################################
# Boosting
######################################################
obj <- rboost(subtype~., data = tnbc[,c(1:10,337)])
importance(obj)
}
}
