\name{rforest}
\alias{rforest}
\alias{rforest.tree}
\title{
Random Forest via Rank-Based Trees for Single Sample Classification with Gene Expression Profiles
}
\description{
The function implements the ensembled rank-based trees in random forests on both binary and multi-class problems. It converts continuous gene expression profiles into
ranked gene pairs, for which the variable importance indices are computed and adopted for dimension reduction.   The random forest implementation was directly imported from the \pkg{randomForestSRC}
  package.  Use the command \code{package?randomForestSRC} for more information.
}
\usage{
rforest(formula, data,
  dimreduce = TRUE,
  datrank = TRUE,
  ntree = 500, mtry = NULL,
  nodesize = NULL, nodedepth = NULL,
  splitrule = NULL, nsplit = NULL,
  importance = c(FALSE, TRUE, "none", "anti", "permute", "random"),
  bootstrap = c("by.root", "none"),
  membership = FALSE,
  na.action = c("na.omit", "na.impute"), nimpute = 1,
  perf.type = NULL,
  xvar.wt = NULL, yvar.wt = NULL, split.wt = NULL, case.wt  = NULL,
  forest = TRUE,
  var.used = c(FALSE, "all.trees", "by.tree"),
  split.depth = c(FALSE, "all.trees", "by.tree"),
  seed = NULL,
  statistics = FALSE,
  ...)

## convenient interface for growing a rank-based tree
rforest.tree(formula, data, dimreduce = FALSE,
             ntree = 1, mtry = ncol(data),
             bootstrap = "none", ...)
}
%- maybe also 'usage' for other objects documented here.
\arguments{

  \item{formula}{Object of class 'formula' describing the model to fit.
    Interaction terms are not supported. }

  \item{data}{Data frame containing the y-outcome and x-variables.}

  \item{dimreduce}{Dimension reduction via variable importance weighted forests. \code{FALSE}
  means no dimension reduction; \code{TRUE} means reducing 75\% variables before binary rank conversion and then fitting a weighted forest; a numeric value x\% between 0 and 1 means reducing x\% variables before binary rank conversion and then fitting a weighted forest.}

  \item{datrank}{ If using ranked raw data for fitting the dimension reduction model. }

  \item{ntree}{Number of trees.}

  \item{mtry}{Number of variables to possibly split at each node.
    Default is number of variables divided by 3 for regression.  For all
    other families (including unsupervised settings), the square root
    of number of variables.  Values are rounded up.}

  \item{nodesize}{Minumum size of terminal node.  The defaults are:
    survival (15), competing risk (15), regression (5), classification
    (1), mixed outcomes (3), unsupervised (3).  It is recommended to
    experiment with different \code{nodesize} values.}

  \item{nodedepth}{Maximum depth to which a tree should be grown.
    Parameter is ignored by default.}

  \item{splitrule}{Splitting rule (see below).}

  \item{nsplit}{Non-negative integer specifying number of random splits
    for splitting a variable.  When zero, all split values are
    used (deterministic splitting), which can be slower.  By default
    10 is used.}

 \item{importance}{Method for computing variable importance (VIMP); see
    below.  Default action is \code{importance="none"} but VIMP can
    be recovered later using \command{vimp} or \command{predict}.}

   \item{bootstrap}{Bootstrap protocol.  Default is \code{by.root} which
    bootstraps the data by sampling without replacement.
    If \code{none}, the data is not bootstrapped (it is not possible to
    return OOB ensembles or prediction error in this case).}

  \item{membership}{Should terminal node membership and inbag
    information be returned?}

  \item{na.action}{Action taken if the data contains \code{NA}'s.
    Possible values are \code{na.omit} or \code{na.impute}.  The default
    \code{na.omit} removes the entire record if any entry is
    \code{NA}. Selecting \code{na.impute} imputes the data (see below
    for details).  Also see the function \command{impute} for fast
    imputation.}

  \item{nimpute}{Number of iterations of the missing data algorithm.
    Performance measures such as out-of-bag (OOB) error rates are
    optimistic if \code{nimpute} is greater than 1.}

  \item{perf.type}{Optional character value specifying metric used
    for predicted value, variable importance (VIMP), and error rate.
    Reverts to the family default metric if not specified.
    Values allowed for
    univariate/multivariate classification are:
    \code{perf.type="misclass"} (default), \code{perf.type="brier"} and
    \code{perf.type="gmean"}.}

  \item{xvar.wt}{Vector of non-negative weights (does not have to sum
    to 1) representing the probability of selecting a variable for
    splitting.  Default is uniform weights.}


  \item{yvar.wt}{Used for sending in features with custom splitting.
    For expert use only.}

  \item{split.wt}{Vector of non-negative weights used for multiplying
    the split statistic for a variable. A large value encourages the
    node to split on a specific variable. Default is uniform
    weights.}

  \item{case.wt}{Vector of non-negative weights (does not have to sum to
    1) for sampling cases.  Observations with larger weights will be
    selected with higher probability in the bootstrap (or subsampled)
    samples.  It is generally better to use real weights rather than
    integers. See the breast data example below illustrating its use
    for class imbalanced data.}

  \item{forest}{Save key forest values?  Used for prediction on new data
    and required by many of the package functions. Turn this off if you
    are only interested in training a forest.}

  \item{var.used}{Return statistics on number of times a variable split?
    Default is \code{FALSE}.  Possible values are \code{all.trees} which
    returns total number of splits of each variable, and \code{by.tree}
    which returns a matrix of number a splits for each variable for each
    tree.}

  \item{split.depth}{Records the minimal depth for each variable.
    Default is \code{FALSE}.  Possible values are \code{all.trees} which
    returns a matrix of the average minimal depth for a variable
    (columns) for a specific case (rows), and \code{by.tree} which
    returns a three-dimensional array recording minimal depth for a
    specific case (first dimension) for a variable (second dimension)
    for a specific tree (third dimension).}

  \item{seed}{Negative integer specifying seed for the random number
    generator.}

  \item{statistics}{Should split statistics be returned?  Values can be
    parsed using \command{stat.split}.}

  \item{...}{Further arguments passed to or from other methods.}
}
\details{
   \emph{Splitting}
 \enumerate{

      \item Splitting rules are specified by the option \code{splitrule}.

      \item For all families, pure random splitting can be invoked by setting
            \code{splitrule="random"}.

      \item For all families, computational speed can be increased using
            randomized splitting invoked by the option \code{nsplit}.
            See Improving Computational Speed.
    }
 \emph{Available splitting rules}

     \enumerate{

	\item \code{splitrule="gini"} (default splitrule): Gini
        index splitting (Breiman et al. 1984, Chapter 4.3).

        \item \code{splitrule="auc"}: AUC (area under the ROC curve) splitting
	for both two-class and multiclass setttings.  AUC splitting is
	appropriate for imbalanced data.  See \code{imbalanced} for
	more information.

	\item \code{splitrule="entropy"}: entropy splitting (Breiman et
	al. 1984, Chapter 2.5, 4.3).

      }
}
\value{
An object of class \code{(rfsrc, grow)} with the following
  components:
  \item{call}{The original call to \command{rfsrc} for growing the random forest object.}
  \item{family}{The family used in the analysis.}
  \item{n}{Sample size of the data (depends upon \code{NA}'s, see \code{na.action}).}
  \item{ntree}{Number of trees grown.}
  \item{mtry}{Number of variables randomly selected for splitting at each node.}
  \item{nodesize}{Minimum size of terminal nodes.}
  \item{nodedepth}{Maximum depth allowed for a tree.}
  \item{splitrule}{Splitting rule used.}
  \item{nsplit}{Number of randomly selected split points.}
  \item{yvar}{y-outcome values.}
  \item{yvar.names}{A character vector of the y-outcome names.}
  \item{xvar}{Data frame of x-variables.}
  \item{xvar.names}{A character vector of the x-variable names.}
  \item{xvar.wt}{Vector of non-negative weights for dimension reduction
    which specify the probability used to select a variable for splitting a node.}
  \item{split.wt}{Vector of non-negative weights specifying
    multiplier by which the split statistic for a covariate is adjusted.}
  \item{cause.wt}{Vector of weights used for the composite competing
    risk splitting rule.}
  \item{leaf.count}{Number of terminal nodes for each tree in the
    forest. Vector of length \code{ntree}.  A value of zero indicates
    a rejected tree (can occur when imputing missing data).
    Values of one indicate tree stumps.}
  \item{proximity}{Proximity matrix recording the frequency of pairs of data points
    occur within the same terminal node.}
  \item{forest}{If \code{forest=TRUE}, the forest object is returned.
    This object is used for prediction with new test data
	  sets and is required for other R-wrappers.}
  \item{membership}{Matrix recording terminal node membership where
    each column records node mebership for a case for a tree (rows).}
  \item{splitrule}{Splitting rule used.}
  \item{inbag}{Matrix recording inbag membership where each column
    contains the number of times that a case appears in the bootstrap
    sample for a tree (rows).}
  \item{var.used}{Count of the number of times a variable is used in
    growing the forest.}
  \item{imputed.indv}{Vector of indices for cases with missing
    values.}
  \item{imputed.data}{Data frame of the imputed data. The first
	  column(s) are reserved for the y-outcomes, after which the
	  x-variables are listed.}
  \item{split.depth}{Matrix (i,j) or array (i,j,k) recording the
    minimal depth for variable j for case i, either averaged over
    the forest, or by tree k.}
  \item{node.stats}{Split statistics returned when
    \code{statistics=TRUE} which can be parsed using \command{stat.split}.}

  \item{err.rate}{Tree cumulative OOB error rate.}

  \item{importance}{Variable importance (VIMP) for each x-variable.}
  \item{predicted}{In-bag predicted value.}
  \item{predicted.oob}{OOB predicted value.}\cr
  \item{class}{In-bag predicted class labels.}
  \item{class.oob}{OOB predicted class labels.}\cr
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
########### performance of Random Rank Forest
obj <- rforest(subtype~., data = tnbc[,c(1:10,337)])
obj
}
}
