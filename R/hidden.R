rfolds <- function (max.rules.tree, lfc) {

  ntree <- length(lfc)
  max.rules <- max.rules.tree * ntree
  tree <- rep(1:ntree, lfc)
  lfc <- unlist(sapply(lfc, function(lc){1:lc}))
  idx <- sample(1:length(lfc), size = min(max.rules, length(lfc)))
  tree <- sort(tree[idx])
  lfc <- unlist(tapply(tree, tree, function(z) {1:length(z)}))
  cbind(tree, lfc)

}
getTreeRule.short <- function(object, tree.id = NULL){

  tolerance = sqrt(.Machine$double.eps)

  ## pull xvar.names
  xvar.names <- object$xvar.names
  xvar.factor <- object$xvar.factor

  ## pull the arrays
  native.array <- object$native.array
  native.f.array <- object$native.f.array

  ## may add processing needed for factors
  f.ctr <- 0
  factor.flag <- FALSE


  ## define the display tree
  display.tree <- native.array[native.array$treeID == tree.id,, drop = FALSE]

  converted.tree <- display.tree
  vars.id <- data.frame(var = c("<leaf>", xvar.names), parmID = 0:length(xvar.names), stringsAsFactors = FALSE)
  converted.tree$var <- vars.id$var[match(display.tree$parmID, vars.id$parmID)]

  ## special symbol to be used for encoding the counter for variables (see note below)
  special <- "999_999"

  var.count <- 1:nrow(converted.tree)
  lapply(unique(converted.tree$var), function(vv) {
    pt <- converted.tree$var == vv
    var.count[which(pt)] <<- 1:sum(pt)
  })

  converted.tree$var_count <- var.count
  converted.tree$var_conc <- paste0(converted.tree$var, special, converted.tree$var_count)

  ## preliminary
  from_node <- ""
  network <- data.frame()
  num.children <- data.frame(converted.tree, children = 0)
  num.children <- num.children[num.children$var != "<leaf>",, drop = FALSE]
  num.children <- num.children[!duplicated(num.children$var_conc),, drop = FALSE]
  num_children <- as.list(rep(0, nrow(num.children)))
  names(num_children) <- num.children$var_conc


  ## loop (using lapply)
  lapply(1:nrow(converted.tree), function(i) {
    rowi <- converted.tree[i, ]
    xs <- converted.tree$contPT[converted.tree$var_conc == from_node]
    if (i == 1){
      from_node <<- rowi$var_conc
    }
    else{
      ## develop the split encoding
      if (num_children[[from_node]] == 0) {#left split
        side <- "<="
        contPT.pretty <- round(as.numeric(xs, 3))
        split_ineq_pretty <- paste0(side, contPT.pretty)
      }
      else {#right split
        side <- ">"
        split_ineq_pretty <- ""
      }

      if (is.numeric(xs)) {
        xs <- xs + tolerance
      }
      split_ineq <- paste0(side, xs)

      ## update the network
      to_node <- rowi$var_conc
      new_node <- list(from = from_node, to = to_node, split = split_ineq, split.pretty = split_ineq_pretty)
      network <<- data.frame(rbind(network, new_node, stringsAsFactors = FALSE))
      num_children[[from_node]] <<- num_children[[from_node]] + 1
      if(rowi$var != "<leaf>")
        from_node <<- to_node
      else{
        if(i != nrow(converted.tree)){
          while(num_children[[from_node]] == 2){
            from_node <<- network$from[network$to == from_node]
          }
        }
      }
    }
  })

  data.tree.network <- data.tree::FromDataFrameNetwork(network, "split")

  ctr <- 0
  treerule <- varUsed <- varNames <- list()

  lapply(data.tree.network$leaves, function(node) {


    ## pull relevant information
    path_list <- node$path
    var_list <- sapply(path_list, function(x){strsplit(x, special)[[1]][1]})
    var_list[length(var_list)] <- ""
    node_iter <- data.tree.network

    ## make boolean string operator - save the list of variable names
    varnames <- NULL
    call <- lapply(2:(length(path_list)), function(i) {
      node_iter <<- node_iter[[path_list[[i]]]]
      str <- node_iter$split ###XXXXXXXXXXXXXXXXXX change to node_iter$split.pretty for pretty digits. Since we use quantiles (range 0~100), I think keep node_iter$split.pretty as integers may OK
      varnames <<- c(varnames, var_list[i-1])
      ## numeric boolean operator
      if (!any(grepl("\\{", str))) {
        str <- paste0("", paste0(var_list[i-1], str))
      }
      ## complementary pair boolean operator
      else {
        str <- gsub("\\{", "", str)
        str <- gsub("\\}", "", str)
        str <- strsplit(str, ",")[[1]]
        str <- paste("==", str, sep = "")
        str <- paste0("(",paste(paste0("", var_list[i-1], str), collapse = "|"),")")
      }
      str
    })
    names(varnames) <- NULL

    ## update the counter and save the results
    ctr <<- ctr + 1
    treerule[[ctr]] <<- call
    varUsed[[ctr]] <<- sort(unique(varnames))
    varNames[[ctr]] <<- varnames

  })

  list(treeRule = treerule, varUsed = varUsed, varNames = varNames)

}
getTreeRule <- function(object){
  ntree <- object$ntree

  lfc <- object$leaf.count[1:ntree]
  treeRuleSeq <- rfolds(ntree, lfc)


  xvar.names <- object$forest$xvar.names
  xvar.factor <- object$forest$xvar.factor
  p <- length(xvar.names)

  ## extract the data and process it
  ## missing data not allowed
  ## convert the data to numeric mode, apply the na.action protocol
  xvar <- object$forest$xvar
  xvar <- finalizeData(xvar.names, xvar, miss.flag = FALSE)

  arr <- object$forest$nativeArray
  arrf <- object$forest$nativeFactorArray[[1]]
  pt.arr <- is.element(paste0(arr$treeID, ":", arr$nodeID),
                       paste0(treeRuleSeq[, 1], ":", treeRuleSeq[, 2]))

  ptf.arr <- arr$mwcpSZ != 0
  arr <- arr[pt.arr,, drop = FALSE]

  ntreeSeq <- sort(unique(arr$treeID))

  ## now reduce the object to the minimal information
  object <- list(xvar.names = xvar.names,
                 xvar.factor = xvar.factor,
                 native.array = arr)

  treeRuleO <- parallel::mclapply(ntreeSeq, function(b) { getTreeRule.short(object, tree.id = b)
  })

  treeRule <- unlist(lapply(treeRuleO, function(oo) {oo$treeRule}), recursive = FALSE)
  if (!is.null(treeRule)) {## convert list of lists to a list
    treeRule <- lapply(treeRule, function(oo) {unlist(oo)})
  }

  varUsed <- unlist(lapply(treeRuleO, function(oo) {oo$varUsed}), recursive = FALSE)
  varNames <- unlist(lapply(treeRuleO, function(oo) {oo$varNames}), recursive = FALSE)

  tree.id <- unlist(lapply(1:length(treeRuleO), function(j) {rep(j, length(treeRuleO[[j]]$treeRule))}))

  rm(treeRuleO)

  list(treeRule = treeRule,
       varUsed = varUsed,
       varNames = varNames,
       tree.id = tree.id,
       treeSeq = sort(unique(treeRuleSeq[, 1])))

}
parseRule <- function(rule) {

  anyC <- grepl("\\(", rule)

  if (sum(anyC) == 0) {
    paste0("x$", rule, collapse=" & ")
  }
  else {
    unlist(sapply(1:length(rule), function(j) {
      rj <- rule[j]
      if (anyC[j]) {
        rj <- sub("\\(", "", rj)
        rj <- sub("\\)", "", rj)
        rj <- strsplit(rj, "\\|")[[1]]
        unlist(lapply(rj, function(rr) {
          paste0("x$", rr)
        }))
      }
      else {
        paste0("x$", rj)
      }
    }))
  }

}
parseFormula <- function (f, data, ytry = NULL, coerce.factor = NULL)
{
  if (!inherits(f, "formula")) {
    stop("'formula' is not a formula object.")
  }
  if (is.null(data)) {
    stop("'data' is missing.")
  }
  if (!is.data.frame(data)) {
    stop("'data' must be a data frame.")
  }
  fmly <- all.names(f, max.names = 1e+07)[2]
  all.names <- all.vars(f, max.names = 1e+07)
  yvar.names <- all.vars(formula(paste(as.character(f)[2],
                                       "~ .")), max.names = 1e+07)
  yvar.names <- yvar.names[-length(yvar.names)]
  subj.names <- NULL
  coerce.factor.org <- coerce.factor
  coerce.factor <- vector("list", 2)
  names(coerce.factor) <- c("xvar.names", "yvar.names")
  if (!is.null(coerce.factor.org)) {
    coerce.factor$yvar.names <- intersect(yvar.names, coerce.factor.org)
    if (length(coerce.factor$yvar.names) == 0) {
      coerce.factor$yvar.names <- NULL
    }
    coerce.factor$xvar.names <- intersect(setdiff(colnames(data),
                                                  yvar.names), coerce.factor.org)
  }
  if (fmly == "Surv") {
    if ((sum(is.element(yvar.names, names(data))) != 2) &&
        (sum(is.element(yvar.names, names(data))) != 4)) {
      stop("Survival formula incorrectly specified.")
    }
    else {
      if (sum(is.element(yvar.names, names(data))) == 4) {
        subj.names <- yvar.names[1]
        yvar.names <- yvar.names[-1]
      }
    }
    family <- "surv"
    ytry <- 0
  }
  else if ((fmly == "Multivar" || fmly == "cbind") && length(yvar.names) >
           1) {
    if (sum(is.element(yvar.names, names(data))) < length(yvar.names)) {
      stop("Multivariate formula incorrectly specified: y's listed in formula are not in data.")
    }
    Y <- data[, yvar.names, drop = FALSE]
    logical.names <- unlist(lapply(Y, is.logical))
    if (sum(logical.names) > 0) {
      Y[, logical.names] <- 1 * Y[, logical.names, drop = FALSE]
    }
    if ((sum(unlist(lapply(Y, is.factor))) + length(coerce.factor$yvar.names)) ==
        length(yvar.names)) {
      family <- "class+"
    }
    else if ((sum(unlist(lapply(Y, is.factor))) + length(coerce.factor$yvar.names)) ==
             0) {
      family <- "regr+"
    }
    else if (((sum(unlist(lapply(Y, is.factor))) + length(coerce.factor$yvar.names)) >
              0) && ((sum(unlist(lapply(Y, is.factor))) + length(coerce.factor$yvar.names)) <
                     length(yvar.names))) {
      family <- "mix+"
    }
    else {
      stop("y-outcomes must be either real or factors in multivariate forests.")
    }
    if (!is.null(ytry)) {
      if ((ytry < 1) || (ytry > length(yvar.names))) {
        stop("invalid value for ytry:  ", ytry)
      }
    }
    else {
      ytry <- length(yvar.names)
    }
  }
  else if (fmly == "Unsupervised") {
    if (length(yvar.names) != 0) {
      stop("Unsupervised forests require no y-responses")
    }
    family <- "unsupv"
    yvar.names <- NULL
    temp <- gsub(fmly, "", as.character(f)[2])
    temp <- gsub("\\(|\\)", "", temp)
    ytry <- as.integer(temp)
    if (is.na(ytry)) {
      ytry <- 1
    }
    else {
      if (ytry <= 0) {
        stop("Unsupervised forests require positive ytry value")
      }
    }
  }
  else {
    if (sum(is.element(yvar.names, names(data))) != 1) {
      stop("formula is incorrectly specified.")
    }
    Y <- data[, yvar.names]
    if (is.logical(Y)) {
      Y <- as.numeric(Y)
    }
    if (!(is.factor(Y) | is.numeric(Y))) {
      stop("the y-outcome must be either real or a factor.")
    }
    if (is.factor(Y) || length(coerce.factor$yvar.names) ==
        1) {
      family <- "class"
    }
    else {
      family <- "regr"
    }
    ytry <- 1
  }
  return(list(all.names = all.names, family = family, subj.names = subj.names,
              yvar.names = yvar.names, ytry = ytry, coerce.factor = coerce.factor))
}

finalizeData <- function (fnames, data, na.action, miss.flag = TRUE)
{
  data <- data[, is.element(names(data), fnames), drop = FALSE]
  factor.names <- unlist(lapply(data, is.factor))
  if (sum(factor.names) > 0) {
    data[, factor.names] <- data.matrix(data[, factor.names,
                                             drop = FALSE])
  }
  if (miss.flag == TRUE && na.action == "na.omit") {
    if (any(is.na(data))) {
      data <- na.omit(data)
    }
  }
  if (miss.flag == TRUE && na.action != "na.omit") {
    nan.names <- sapply(data, function(x) {
      any(is.nan(x))
    })
    if (sum(nan.names) > 0) {
      data[, nan.names] <- data.frame(lapply(which(nan.names),
                                             function(j) {
                                               x <- data[, j]
                                               x[is.nan(x)] <- NA
                                               x
                                             }))
    }
  }
  if (nrow(data) == 0) {
    stop("no records in the NA-processed data: consider using 'na.action=na.impute'")
  }
  logical.names <- unlist(lapply(data, is.logical))
  if (sum(logical.names) > 0) {
    data[, logical.names] <- 1 * data[, logical.names, drop = FALSE]
  }
  character.names <- unlist(lapply(data, is.character))
  if (sum(character.names) > 0) {
    stop("data types cannot be character: please convert all characters to factors")
  }
  return(data)
}
make.size <- function (y)
{
  frq <- table(y)
  min(length(y), min(frq, na.rm = TRUE) * length(frq))
}


