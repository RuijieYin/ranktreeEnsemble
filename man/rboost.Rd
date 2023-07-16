\name{rboost}
\alias{rboost}
\title{Generalized Boosted Modeling via Rank-Based Trees for Single Sample Classification with Gene Expression Profiles}
\description{
The function fits generalized boosted models via Rank-Based Trees on both binary and multi-class problems. It converts continuous gene expression profiles into
ranked gene pairs, for which the variable importance indices are computed and adopted for dimension reduction.   The boosting implementation was directly imported from the \pkg{gbm}
  package.  For technical details, see the
  vignette: \code{utils::browseVignettes("gbm")}.
}
\usage{
rboost(
  formula,
  data,
  dimreduce = TRUE,
  datrank = TRUE,
  distribution = "multinomial",
  weights,
  ntree = 100,
  nodedepth = 3,
  nodesize = 5,
  shrinkage = 0.05,
  bag.fraction = 0.5,
  train.fraction = 1,
  cv.folds = 5,
  keep.data = TRUE,
  verbose = TRUE,
  class.stratify.cv = TRUE,
  n.cores = NULL
)
}
\arguments{
\item{formula}{Object of class 'formula' describing the model to fit.}

\item{data}{Data frame containing the y-outcome and x-variables.}

\item{dimreduce}{Dimension reduction via variable importance weighted forests. \code{FALSE}
  means no dimension reduction; \code{TRUE} means reducing 75\% variables before binary rank conversion and then fitting a weighted forest; a numeric value x\% between 0 and 1 means reducing x\% variables before binary rank conversion and then fitting a weighted forest.}

\item{datrank}{ If using ranked raw data for fitting the dimension reduction model. }

\item{distribution}{Either a character string specifying the name of the
distribution to use: if the response has only 2 unique values,
\code{bernoulli} is assumed; otherwise, if the response is a factor, \code{multinomial} is
assumed.}

\item{weights}{an optional vector of weights to be used in the fitting
process. It must be positive but does not need to be normalized.}

  \item{ntree}{Integer specifying the total number of trees to fit. This is
    equivalent to the number of iterations and the number of basis functions in
    the additive expansion, which matches \code{n.tree} in the \code{gbm} package.}

  \item{nodedepth}{Integer specifying the maximum depth of each tree. A value of 1
    implies an additive model. This matches \code{interaction.depth} in the \code{gbm} package.}

  \item{nodesize}{Integer specifying the minimum number of observations
    in the terminal nodes of the trees, which matches \code{n.minobsinnode} in the \code{gbm} package.. Note that this is the actual number of
    observations, not the total weight.}

  \item{shrinkage}{a shrinkage parameter applied to each tree in the
    expansion. Also known as the learning rate or step-size reduction; 0.001 to
    0.1 usually work, but a smaller learning rate typically requires more trees.
    Default is 0.05.}

  \item{bag.fraction}{the fraction of the training set observations randomly
    selected to propose the next tree in the expansion. This introduces
    randomnesses into the model fit. If \code{bag.fraction} < 1 then running the
    same model twice will result in similar but different fits. \code{gbm} uses
    the R random number generator so \code{set.seed} can ensure that the model
    can be reconstructed. Preferably, the user can save the returned
    \code{\link{gbm.object}} using \code{\link{save}}. Default is 0.5.}

  \item{train.fraction}{The first \code{train.fraction * nrows(data)}
    observations are used to fit the \code{gbm} and the remaining observations are used for
    computing out-of-sample estimates of the loss function.}

  \item{cv.folds}{Number of cross-validation folds to perform. If
    \code{cv.folds}>1 then \code{gbm}, in addition to the usual fit, will
    perform cross-validation and calculate an estimate of generalization error
    returned in \code{cv.error}.}

  \item{keep.data}{a logical variable indicating whether to keep the data and
    an index of the data stored with the object. Keeping the data and index
    makes subsequent calls to \code{\link{gbm.more}} faster at the cost of
    storing an extra copy of the dataset.}

  \item{verbose}{Logical indicating whether or not to print out progress and
    performance indicators (\code{TRUE}). If this option is left unspecified for
    \code{gbm.more}, then it uses \code{verbose} from \code{object}. Default is
    \code{TRUE}.}

  \item{class.stratify.cv}{Logical indicating whether or not the
    cross-validation should be stratified by class. The purpose of stratifying the
    cross-validation is to help avoid situations in which training sets do
    not contain all classes.}

  \item{n.cores}{The number of CPU cores to use. The cross-validation loop
    will attempt to send different CV folds off to different cores. If
    \code{n.cores} is not specified by the user, it is guessed using the
    \code{detectCores} function in the \code{parallel} package. Note that the
    documentation for \code{detectCores} makes clear that it is not failsafe and
    could return a spurious number of available cores.}
}
\value{
\item{fit}{A vector containing the fitted
values on the scale of regression function (e.g. log-odds scale for
bernoulli).}
\item{train.error}{A vector of length
equal to the number of fitted trees containing the value of the loss
function for each boosting iteration evaluated on the training data.}
\item{valid.error}{A vector of length equal to the number of fitted trees
containing the value of the loss function for each boosting iteration
evaluated on the validation data.}
\item{cv.error}{If \code{cv.folds} < 2 this
component is \code{NULL}. Otherwise, this component is a vector of length equal to
the number of fitted trees containing a cross-validated estimate of the loss
function for each boosting iteration.}
\item{oobag.improve}{A vector of
length equal to the number of fitted trees containing an out-of-bag estimate
of the marginal reduction in the expected value of the loss function. The
out-of-bag estimate uses only the training data and is useful for estimating
the optimal number of boosting iterations. See \code{\link{gbm.perf}}.}
\item{cv.fitted}{If cross-validation was performed, the cross-validation
predicted values on the scale of the linear predictor. That is, the fitted
values from the i-th CV-fold, for the model having been trained on the data
in all other folds.}
}
\references{
Lu M. Yin R. and Chen X.S. (2023). Ensemble Methods of Rank-Based Trees for Single Sample Classification with Gene Expression Profiles.
}
\author{
Ruijie Yin (Maintainer,<ruijieyin428@gmail.com>), Chen Ye and Min Lu
}
\examples{
data(tnbc)
obj <- rboost(subtype~., data = tnbc[,c(1:10,337)])
obj
}

