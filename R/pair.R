pair <- function(data,
                 yvar.name = NULL){
  if (is.null(yvar.name)) {
    colnames(data)[-ncol(data)] <-  gsub("[[:punct:]]", "_", colnames(data)[-ncol(data)])
    data[,(ncol(data)+1)] <- NA
    converted_data <- .Call(`_ranktreeEnsemble_convert_genepairs`, data)$data.converted
    newname <- tonewname(colnames(data))
    colnames(converted_data) <- newname
    converted_data <- converted_data[,-ncol(converted_data)]
  } else {
  data <- data[ , c(colnames(data)[colnames(data) != yvar.name], yvar.name)]
  colnames(data)[-ncol(data)] <-  gsub("[[:punct:]]", "_", colnames(data)[-ncol(data)])
  converted_data <- .Call(`_ranktreeEnsemble_convert_genepairs`, data)$data.converted
  newname <- tonewname(colnames(data))
  colnames(converted_data) <- c(newname)
  }
  converted_data
}
tonewname <- function(xname){
  newname <- c()
  n_col = length(xname) - 1
  k <- 1
  for (i in 1:(n_col - 1)) {
    for (j in (i + 1):n_col) {
      newname[k] <- paste(xname[c(i,j)],collapse = "_less_than_")
      k <- k+1
    }
  }
  c(newname,xname[length(xname)])
}
qdat <- function(dat){
  n <- ncol(dat)
  for (i in 1:n){
    if (is.numeric(dat[,i])) {
      dat[,i] <- rank(dat[,i])/n
    }
  }
  dat
}
