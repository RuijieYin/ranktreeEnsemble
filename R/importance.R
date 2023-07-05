importance <- function(object, ...){
  if (class(object)[1] == "gbm"){
    beta <- gbm::relative.influence(object, ...)
    return(beta)
  } else if (class(object)[1] == "rfsrc"){
    beta <- randomForestSRC::vimp(object, ...)
    return(beta$importance)
  } else { stop("Object class unrecognized")}
}
