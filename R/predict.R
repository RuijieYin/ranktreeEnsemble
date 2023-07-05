predict <- function(object, newdata = NULL,
                    newdata.pair = FALSE,
                    ...){
  yhat <- list()
  if (!is.null(newdata)) {
    if (!newdata.pair) {

    if (is(object)[1] == "gbm"){yvar.names <- object$response.name}
    if (is(object)[1] == "rfsrc"){yvar.names <- object$yvar.names}
    if (is(object)[1] == "rules"){yvar.names <- object$data[,ncol(object$data)]}

    if (length(which(colnames(newdata) == yvar.names)) > 0) {
      converted_data <- pair(newdata, yvar.names)
       } else {
      converted_data <- pair(newdata)
       }

    } else {
      converted_data <- newdata}
  } else {
  if (is(object)[1] == "rules"){converted_data <- object$data}
  }
  if (is(object)[1] == "gbm"){
    if (is.null(newdata)) {
      if (object$cv.folds >=2) {
        o <- object$cv.fitted } else {
        o <- object$fit
      }
    } else {
    o <- gbm::predict.gbm(object, converted_data,...) }
    yhat$value <- o
    yhat$label <- colnames(yhat$value)[apply(o,1, which.max)]
    return(yhat)
  } else if (is(object)[1] == "rfsrc"){
    if (is.null(newdata)) {
    yhat$value <- object$predicted.oob
    yhat$label <- object$class.oob
      } else {
    o <- randomForestSRC::predict.rfsrc(object, converted_data, ...)
    yhat$value <- o$predicted
    yhat$label <- colnames(yhat$value)[apply(yhat$value,1, which.max)] }
    return(yhat)
  } else if (is(object)[1] == "rules"){
    o <- predict.rules(object, converted_data)
    yhat$label <- o$lable
    yhat$value <- o$value
    return(yhat)
  } else { return(predict(object, newdata, ...))}
}
