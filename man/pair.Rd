\name{pair}
\alias{pair}
\title{
Transform Continuous Variables into Ranked Binary Pairs
}
\description{
The function transforms a dataset with \eqn{p} continuous predictors into \eqn{\frac{p*(p-1)}{2}} binary predictors of ranked pairs
}
\usage{
pair(data, yvar.name = NULL)
}
\arguments{
\item{data}{
A dataset with \eqn{p} continuous variables or with \eqn{p+1} variables including a dependent variable.
}
\item{yvar.name}{
The column name of the independent variable in \code{data}. By default, there is no dependent variable.
}
}
\value{
A data frame with the transformed data. The dependent variable is moved to the last column of the data.
}
\note{
The function is efficiently coded in C++.
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
datp <- pair(tnbc[101:105,c(1:5,337)],"subtype")
datp
datp <- pair(tnbc[105:110,1:5])
datp
}
}
