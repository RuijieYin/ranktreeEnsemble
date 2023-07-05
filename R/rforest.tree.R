rforest.tree <- function(formula, data, dimreduce = FALSE, ntree = 1, mtry = ncol(data), bootstrap = "none", ...)
{
  rforest(formula, data, ntree = ntree, mtry = mtry, bootstrap = bootstrap, dimreduce = dimreduce, ...)
}
