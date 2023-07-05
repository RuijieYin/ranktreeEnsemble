rforest <- function(formula, data, dimreduce = TRUE,
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
                    ...){
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
    model <- randomForestSRC::rfsrc(formula, data = data, importance = TRUE)
    sel <- model$xvar.names[which(model$importance[,1]>quantile(model$importance[,1], delt))]
    data <- data[,c(sel, yvar.names)]
  }


  converted_data <- pair(data, yvar.names)
  converted_data[,yvar.names] = factor(converted_data[,yvar.names])
  if (dimreduce !=FALSE) {
    vimp <- TRUE
  } else {
    vimp <-"none"
  }
  if (is.null(seed)) seed <- 1
  model <- randomForestSRC::rfsrc(formula, data = converted_data, importance = vimp,
                ntree = ntree, mtry = mtry,
                nodesize = nodesize, nodedepth = nodedepth,
                splitrule = splitrule, nsplit = nsplit,
                membership = membership,
                na.action = c("na.omit", "na.impute"), nimpute = nimpute,
                perf.type = perf.type,
                xvar.wt = NULL, yvar.wt = yvar.wt,
                split.wt = split.wt, case.wt  = case.wt,
                forest = forest,
                var.used = var.used,
                split.depth = split.depth,
                seed = seed,
                statistics = statistics
  )
  if (dimreduce == FALSE) {
    return(model)
  } else {
  wt <- model$importance[,1]
  wt[which(model$importance[,1] < 0)] <- 0
  rm(model)
  gc()

  model2 <- randomForestSRC::rfsrc(formula,
                 data = converted_data,
                 xvar.wt = wt,
                 ntree = ntree, mtry = mtry,
                 nodesize = nodesize, nodedepth = nodedepth,
                 splitrule = splitrule, nsplit = nsplit,
                 membership = membership,
                 na.action = c("na.omit", "na.impute"), nimpute = nimpute,
                 perf.type = perf.type, yvar.wt = yvar.wt,
                 split.wt = split.wt, case.wt  = case.wt,
                 forest = forest,
                 var.used = var.used,
                 split.depth = split.depth,
                 seed = seed,
                 statistics = statistics
  )
  return(model2) }
}
