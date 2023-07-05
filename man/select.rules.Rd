\name{select.rules}
\alias{select.rules}
\title{
Select Decision Rules to Achieve Higher Prediction Accuracy
}
\description{
Select rules from a extrat.rules \code{(rules)} object
}
\usage{
select.rules(object, data, data.pair = FALSE)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{object}{
An extracted rule \code{(rules)} object generated from the \code{extract.rules} function.
}
  \item{data}{
A validation dataset for selecting rules.
}
  \item{data.pair}{
Is data already converted into binary ranked pairs from the \code{pair} function?
}
}
\value{
\item{rule}{Interpretable selected rules. Note that the performance score displayed is inaccurate based on few samples from the original argument \code{object}. }
\item{rule.raw}{Rules directly extracted from trees for prediction purpose}
\item{data}{Data used to grow trees from the argument \code{(object)}. }
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
obj <- rforest(subtype~., data = tnbc[1:100,c(1:5,337)])
objr <- extract.rules(obj)
predict(objr, tnbc[101:110,1:5])$label
objrs <- select.rules(objr,tnbc[110:130,c(1:5,337)])
predict(objrs, tnbc[101:110,1:5])$label
}
}
