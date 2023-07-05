\name{ranktreeEnsemble}
\alias{ranktreeEnsemble}
\alias{ranktreeEnsemble}
\docType{package}
\title{
  Ensemble Models of Rank-Based Trees for Single Sample Classification with Interpretable Rules
}
\description{
The package \code{ranktreeEnsemble} implements an ensemble of rank-based trees in boosting with the LogitBoost cost  and random forests on both binary and multi-class problems. It converts continuous gene expression profiles into
ranked gene pairs, for which the variable importance indices are computed and adopted for dimension reduction. Interpretable rules can be extracted from trees.
}
\author{
Ruijie Yin (Maintainer,<ruijieyin428@gmail.com>), Chen Ye and Min Lu
}
\references{
Lu M. Yin R. and Chen X.S. (2023). Ensemble Methods of Rank-Based Trees for Single Sample Classification with Gene Expression Profiles.
}
\examples{
\donttest{
library(ranktreeEnsemble)
data(tnbc)
########### performance of Random Rank Forest
obj <- rforest(subtype~., data = tnbc[,c(1:10,337)])
obj
# variable importance
importance(obj)
########### predict new data from Random Rank Forest
predict(obj, tnbc[101:110,1:10])$label
########### extract decision rules from rank-based trees
objr <- extract.rules(obj)
objr$rule[1:5,]
predict(objr, tnbc[101:110,1:10])$label
########### filter decision rules with higher performance
objrs <- select.rules(objr,tnbc[110:130,c(1:10,337)])
predict(objrs, tnbc[101:110,1:10])$label
}
}
