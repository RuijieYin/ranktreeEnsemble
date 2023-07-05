\name{extract.rules}
\alias{extract.rules}
\title{
Extract Interpretable Decision Rules from a Random Forest Model
}
\description{
Extract rules from a random forest \code{(rfsrc)} object
}
\usage{
extract.rules(object, subtrees = 5,
              treedepth = 2,
              digit = 2,
              pairs = TRUE)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{object}{
A random forest \code{(rfsrc)} object
}
  \item{subtrees}{
Number of trees to extract rules
}
  \item{treedepth}{
Tree depth. The larger the number, the longer the extracted rules are.
}
  \item{digit}{
Digit to be displayed in the extracted rules.
}
  \item{pairs}{
Are varibles in \code{(object)} generated from the \code{pair} function? Set \code{pairs = FALSE} to extract rules from regular random forest \code{(rfsrc)} object with continuous predictors.
}
}
\value{
\item{rule}{Interpretable extracted rules. Note that the performance score displayed is inaccurate based on few samples. }
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
objr$rule[,1:3]

#### extract rules from a regular random forest
library(randomForestSRC)
obj2 <- rfsrc(subtype~., data = tnbc[1:100,c(1:5,337)])
objr2 <- extract.rules(obj2, pairs = FALSE)
objr2$rule[,1:3]
}
}
