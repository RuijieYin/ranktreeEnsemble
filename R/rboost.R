rboost <- function(
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
){
  formulaPrelim <- parseFormula(formula, data, ytry = NULL)
  yvar.names <- formulaPrelim$yvar.names

  delt <- 0.75
  if (is.numeric(dimreduce)) {
    if ((dimreduce<1) & (dimreduce > 0) ) {
      delt <- dimreduce
    }
  }
  delt <- min(delt, 1-5/ncol(data))[1]
  if (dimreduce !=FALSE) {
    if (datrank) {
      data[,-which(colnames(data) ==yvar.names)] <- qdat(data[,-which(colnames(data) ==yvar.names)])
    }
    model <- gbm::gbm(formula, data = data,
                      distribution = distribution,
                      n.trees = ntree,
                      interaction.depth = nodedepth,
                      n.minobsinnode = nodesize,
                      shrinkage = shrinkage,
                      bag.fraction = bag.fraction,
                      train.fraction = train.fraction,
                      cv.folds = 1,
                      keep.data = FALSE
    )
    wt <- gbm::relative.influence(model)
    sel <- names(wt)[which(wt>quantile(wt, delt))]
    data <- data[,c(sel, yvar.names)]
  }

  converted_data <- pair(data, yvar.names)
  converted_data[,yvar.names] = factor(converted_data[,yvar.names])

model <- gbm::gbm(formula, data = converted_data,
                  distribution = distribution,
                  n.trees = ntree,
                  interaction.depth = nodedepth,
                  n.minobsinnode = nodesize,
                  shrinkage = shrinkage,
                  bag.fraction = bag.fraction,
                  train.fraction = train.fraction,
                  cv.folds = 1,
                  keep.data = TRUE
)
#if (dimreduce == FALSE) {
  return(model)
#} else {

#  wt <- relative.influence(model)

#  model2 <- gbm::gbm(formula, data = converted_data[,c(which(wt>0),
#                                                       ncol(converted_data))],
#                    distribution = distribution,
#                    n.trees = ntree,
#                    interaction.depth = nodedepth,
#                    n.minobsinnode = nodesize,
#                    shrinkage = shrinkage,
#                    bag.fraction = bag.fraction,
#                    train.fraction = train.fraction,
#                    cv.folds = 1,
#                    keep.data = TRUE  )
# return(model2) }
}
