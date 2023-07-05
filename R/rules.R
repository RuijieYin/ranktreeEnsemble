extract.rules <- function(object,
                          subtrees = 5,
                          treedepth = 2,
                          digit = 2,
                          pairs = TRUE) {
  object$xvar[,object$yvar.names] <- object$yvar
  tree.collection <- rfsrc(formula(paste(object$yvar.names,"~.")),
                           data = object$xvar,
                           ntree = subtrees,
                           mtry = length(object$xvar.names)/2,
                           nodedepth = treedepth,
                           bootstrap = "by.root", samptype = 'swr',
                           membership = T,
                           seed = 1,
                           # grow class balanced trees
                           # case.wt = randomForestSRC:::make.wt(data$subtype),
                           sampsize = make.size(object$yvar))
  # summary(tree.collection)
  data <- object$xvar
  rm(object)
  gc()

  total_num_rules <- length(getTreeRule(tree.collection)$tree.id)


  # initialize a data frame to store (rules[[j]], class, else_class, as.numeric(perform.score))
  final_result <- data.frame("rule" = character(),
                             "if.class" = character(),
                             "else.class" = character(),
                             "perf" = numeric(),
                             "perf.if.class" = numeric(),
                             "perf.else.class" = numeric())

  # extract tree rules from each tree:
  rules <- vector("list", total_num_rules)

  #k <- 1
  for (j in 1:total_num_rules) {
    cat("\r","----",j,"/",total_num_rules,100*(j/total_num_rules),"%----")

    # extract rule j from tree i:
    rules[[j]] <- parseRule(getTreeRule(tree.collection)$treeRule[[j]])
    # the ith tree where rule j comes from:
    tree.i <- getTreeRule(tree.collection)$tree.id[j]

    # index of inbag sample to grow tree i:
    index.inbag <- which(tree.collection$inbag[,tree.i] != 0)
    # find inbag samples suffice the jth rule:
    x <- data # should tell what x is
    all.sample.fit.rule <- which(eval(parse(text = rules[[j]])))
   # if (length(all.sample.fit.rule)>0) {
      inbag.sample.fit.rule <- Reduce(intersect, list(index.inbag, all.sample.fit.rule))

      # determine the class label for this rule
      # should consider the tied class:
      class_label_train <- table(data[inbag.sample.fit.rule, dim(data)[2]])
      class <- names(class_label_train[class_label_train == max(class_label_train)[1]])

      # see if this rule has an "else": the majority class that does not suffice jth rule in the inbag sample,
      # use majority vote to determine "else":
      inbag.sample.not.fit.rule <- index.inbag[-inbag.sample.fit.rule]
      # find the class labels of samples that does not suffice jth rule;
      # first find and remove the majority class in 'class'label' section:
      majority_class_index <- which(as.character(data[inbag.sample.not.fit.rule, dim(data)[2]],class) %in% class)
      else_label_train <- table(as.character(data[inbag.sample.not.fit.rule, dim(data)[2]])[-majority_class_index])
      else_class_temp <- names(else_label_train[else_label_train == max(else_label_train)[1]])
      # should consider tied votes:
      if (length(else_class_temp) != 1) {
        else_class <- NA
      } else {
        else_class <- else_class_temp
      }

      # calculate the performance score for rule j in tree i using oob data from tree i:
      # get class balanced OOB sample:
      out.of.bag <- which(tree.collection$inbag[,tree.i] == 0)
      oob.sample <- data[out.of.bag,]
      oob.sample.balanced <- oob.sample[complete.cases(oob.sample), ]
      #oob.sample.balanced <- downSample(x = data[,-dim(data)[2]],
      # y = factor(data[,dim(data)[2]]))
      colnames(oob.sample.balanced)[dim(oob.sample.balanced)[2]] <- "subtype"

      # 2 scenarios: the rule has or does not have an 'else'

      # 1st scenario: the rule j does not have an 'else':
      if (is.na(else_class) == T) {
        # store results in the iteration:
        class_label <- matrix(NA, nrow = dim(oob.sample.balanced)[1],
                              ncol = 2)
        # 1st element: see if sample suffice the above criteria, 1/0
        # 2nd element: see if sample is indeed the predicted class, 1/0

        for (k in 1:dim(oob.sample.balanced)[1]) {
          if (is.na(eval(parse(text = rules[[j]]))[out.of.bag[k]]) == F &&
              eval(parse(text = rules[[j]]))[out.of.bag[k]] == T &&
              oob.sample.balanced[k,]$subtype == class[1]) {
            class_label[k,] <- c(1,1)
          } else if (is.na(eval(parse(text = rules[[j]]))[out.of.bag[k]]) == F &&
                     eval(parse(text = rules[[j]]))[out.of.bag[k]] == T &&
                     oob.sample.balanced[k,]$subtype != class[1]) {
            class_label[k,] <- c(1,0)
          } else {
            class_label[k,] <- c(0,0)
          }
        }

        # see notes for details on how to calculate performance score
        perform.score.1 <- (sum(class_label[,1])/dim(class_label)[1])*
          (sum(class_label[class_label[,1]==1,2])/sum(class_label[,1]))

        perform.score.2 <- 0

        perform.score <- perform.score.1 + perform.score.2
        # 2nd scenario: the rule j has an 'else':
      } else if (is.na(else_class) == F) {

        # part 1:
        # store results in the iteration:
        class_label <- matrix(NA, nrow = dim(oob.sample.balanced)[1],
                              ncol = 2)
        # 1st element: see if sample suffice the above criteria, 1/0
        # 2nd element: see if sample is indeed the predicted class, 1/0

        for (k in 1:dim(oob.sample.balanced)[1]) {
          if (is.na(eval(parse(text = rules[[j]]))[out.of.bag[k]]) == F &&
              eval(parse(text = rules[[j]]))[out.of.bag[k]] == T &&
              (oob.sample.balanced[k,]$subtype == class)[1]) {
            class_label[k,] <- c(1,1)
          } else if (is.na(eval(parse(text = rules[[j]]))[out.of.bag[k]]) == F &&
                     eval(parse(text = rules[[j]]))[out.of.bag[k]] == T &&
                     oob.sample.balanced[k,]$subtype != class[1]) {
            class_label[k,] <- c(1,0)
          } else {
            class_label[k,] <- c(0,0)
          }
        }

        # see notes for details on how to calculate performance score
        perform.score.1 <- (sum(class_label[,1])/dim(class_label)[1])*
          (sum(class_label[class_label[,1]==1,2])/sum(class_label[,1]))

        # part 2:
        # store results in the iteration:
        class_label <- matrix(NA, nrow = dim(oob.sample.balanced)[1],
                              ncol = 2)
        # 1st element: see if sample suffice the above criteria, 1/0
        # 2nd element: see if sample is indeed the predicted class, 1/0

        for (k in 1:dim(oob.sample.balanced)[1]) {
          if (is.na(eval(parse(text = rules[[j]]))[out.of.bag[k]]) == F &&
              eval(parse(text = rules[[j]]))[out.of.bag[k]] == F &&
              oob.sample.balanced[k,]$subtype == else_class) {
            class_label[k,] <- c(1,1)
          } else if (is.na(eval(parse(text = rules[[j]]))[out.of.bag[k]]) == F &&
                     eval(parse(text = rules[[j]]))[out.of.bag[k]] == F &&
                     oob.sample.balanced[k,]$subtype != else_class) {
            class_label[k,] <- c(1,0)
          } else {
            class_label[k,] <- c(0,0)
          }
        }

        # see notes for details on how to calculate performance score
        perform.score.2 <- (sum(class_label[,1])/dim(class_label)[1])*
          (sum(class_label[class_label[,1]==1,2])/sum(class_label[,1]))

        perform.score <- perform.score.1 + perform.score.2
      }
   #   k <- k + 1
   # }
    final_result[j,] <- list("rule" = rules[[j]],
                             "if.class" = class[1],
                             "else.class" = else_class,
                             "perf" = perform.score,
                             "perf.if.class" = perform.score.1,
                             "perf.else.class" = perform.score.2)

  }
  # remove rules with NaN performance scores
  final_result <- final_result[!is.na(final_result[,4]),]

  # remove rules with performance scores = 0
  final_result <- final_result[final_result[,4] != 0,]

  # remove duplicated rules
  final_result_all <- final_result[which(!duplicated(final_result[,1])), ]

  x <- final_result_all[,1]
  x <- gsub('x$', '', x, fixed = TRUE)
  for (i in 1:length(x)){
    tmp <- unlist(strsplit(x[i], "\\&") )
    for (j in 1:length(tmp)){
      temp <- unlist(strsplit(tmp[j], "\\.") )

      if (pairs) {
        if (grepl( "<=",temp[1],  fixed = TRUE)) {
          temp[1] <- unlist(strsplit(temp[1], "<=") )[1]
          tmp[j] <- gsub('_less_than_', ' < ', temp[1], fixed = TRUE)
        } else {
          temp[1] <- unlist(strsplit(temp[1], ">") )[1]
          tmp[j] <- gsub('_less_than_', ' > ', temp[1], fixed = TRUE)
        }
      } else {
        xx <- ""
        if (grepl( "e-",temp[2],  fixed = TRUE)) {
          xx <-  paste("e-", unlist(strsplit(temp[2], "e-") )[2], sep = "")
          temp[2] <- unlist(strsplit(temp[2], "e-") )[1]
        }
        if (grepl( "e+",temp[2],  fixed = TRUE)) {
          xx <-  paste("e+", unlist(strsplit(temp[2], "e+") )[2], sep = "")
          temp[2] <- unlist(strsplit(temp[2], "e+") )[1]
        }
        temp[2] <- round(as.numeric(paste(".",temp[2],sep ="")),
                         digits = digit)

        tmp[j] <- gsub("0.",".",paste(c(temp,xx), collapse=""), fixed = TRUE) }
    }
    x[i] <- paste(tmp,collapse=" &")
  }
  rule.raw <- final_result_all[,1]
  final_result_all[,1] <- x

  o <- list(rule = final_result_all,
            rule.raw = rule.raw,
            data = data)
  class(o) <- "rules"
  o
}

predict.rules <- function(object, newdata) {

  if (is(object)!="rules") {
    stop("Please generate object from extract.rules() or select.rules()")
  }

  decision.rules <- object$rule
  decision.rules[,"Rules"] <- object$rule.raw

  rulenum <- nrow(decision.rules)
  n <- nrow(newdata)
  # for (i in 1:rulenum) {

  pred_class <- matrix(NA, n, 1)
  tmp <- levels(object$data[,ncol(object$data)])
  labeltable <- matrix(0,n,length(tmp))
  colnames(labeltable) <- tmp

  for (k in 1:n) {
    cat("\r","----",k,"/",n,100*(k/n),"%----")
    # define x
    x <- newdata[k,]
    inter.table <- data.frame("label" = as.character(),
                              "Performance Score" = as.numeric(),
                              "Indicator" = as.numeric())

    for (w in 1:rulenum)  {

      if ((eval(parse(text = decision.rules[w,]$Rules)) == T)[1]) {
        inter.table[w,] <- list("label" = decision.rules[w,][,2],
                                "Performance Score" = decision.rules[w,][,4],
                                "Indicator" = 1)
        # indicator = 1: the sample's label is determined by 'class label'
      } else if ((eval(parse(text = decision.rules[w,]$Rules)) == F)[1]) {
        inter.table[w,] <- list("label" = decision.rules[w,][,3],
                                "Performance Score" = decision.rules[w,][,4],
                                "Indicator" = 0)
        # indicator = 0: the sample's label is determined by 'else class'
      }
    }

    # determine the class label of the kth sample in validation data:
    label <- table(as.character(inter.table[,1]))
    temp <- match(names(label),tmp)
    labeltable[k,temp] <- label/sum(label)

    if (length(label) != 1) {
      pred_class[k,1] <- as.character(inter.table[,1][which.max(inter.table[,3])[1]])
    } else{
      pred_class[k,1] <- names(label[label == max(label)[1]])
    }
  }
  # lable = factor(pred_class,
  #    levels = levels(object$data[,ncol(object$data)]))
  list(lable = pred_class,
       value = labeltable
  )
}
select.rules <- function(object, data, data.pair = FALSE) {
  if (is(object)!="rules") {
    stop("Please generate object from extract.rules() or select.rules()")
  }

  if (!data.pair) {
    data <- pair(data,colnames(object$data)[ncol(object$data)])
  }

  rule.table <- object$rule
  rule.table[,"Rules"] <- object$rule.raw

  # remove rules with performance score = 0
  rule.table <- rule.table[rule.table$perf != 0,]

  # the probability of predicting correctly by random guessing is 0.5*0.5+0.5*0.5 = 0.5
  rules.order.temp <- rule.table[rule.table$perf > 0.1,]

  # order the rules by their performance scores:
  rules.order <- rules.order.temp[order(rules.order.temp$perf, decreasing = T),]

  # initialize a data frame to store # of rules v.s. accuracy
  accuracy.table <- data.frame("Num.of.Rules" = as.numeric(),
                               "Accuracy" = as.numeric())

  # initialize accuracy
  accuracy <- 0

  # initialize rules will be retained:
  rules.retained.new <- data.frame("Rules" = character(),
                                   "Class Label" = character(),
                                   "Else Class" = character(),
                                   "Performance Score" = numeric(),
                                   "Performance Score (Class)" = numeric(),
                                   "Performance Score (Else Class)" = numeric())

  # initialize rules retained in the previous selection step:
  rules.retained.previous <- data.frame("Rules" = character(),
                                        "Class Label" = character(),
                                        "Else Class" = character(),
                                        "Performance Score" = numeric(),
                                        "Performance Score (Class)" = numeric(),
                                        "Performance Score (Else Class)" = numeric())

  total_num_rules <- nrow(rules.order)
  n <- dim(data)[1]
  for (i in 1:total_num_rules) {
    cat("\r","----",i,"/",total_num_rules,100*(i/total_num_rules),"%----")

    rules.add <- rules.order[i,]
    rules.retained.new <- rbind(rules.retained.previous, rules.add)

    pred_class <- matrix(NA, nrow = n, ncol = 1)

    for (k in 1:n) {
      # define x
      x <- data[k,]
      inter.table <- data.frame("label" = as.character(),
                                "Performance Score" = as.numeric(),
                                "Indicator" = as.numeric())

      for (w in 1:nrow(rules.retained.new))  {
        if (eval(parse(text = rules.retained.new[w,]$Rules)) == T) {
          inter.table[w,] <- list("label" = rules.retained.new[w,][,2],
                                  "Performance Score" = rules.retained.new[w,][,4],
                                  "Indicator" = 1)
          # indicator = 1: the sample's label is determined by 'class label'
        } else if (eval(parse(text = rules.retained.new[w,]$Rules)) == F) {
          inter.table[w,] <- list("label" = rules.retained.new[w,][,3],
                                  "Performance Score" = rules.retained.new[w,][,4],
                                  "Indicator" = 0)
          # indicator = 0: the sample's label is determined by 'else class'
        }
      }

      # determine the class label of the kth sample in validation data:
      label <- table(as.character(inter.table[,1]))
      if (length(label) != 1) {
        pred_class[k,1] <- as.character(inter.table[,1][which.max(inter.table[,3])[1]])
      } else{
        pred_class[k,1] <- names(label[label == max(label)[1]])
      }
    }


    comp_table <- cbind(pred_class, as.matrix(data[,ncol(data)], ncol = 1))

    accuracy.temp <- sum(comp_table[,1] == comp_table[,2])/nrow(comp_table)

    if (accuracy.temp <= accuracy) {
      accuracy <- accuracy
      rules.retained.previous <- rules.retained.previous
      accuracy.table[i,] <- list("Num.of.Rules" = i,
                                 "Accuracy" = accuracy)
    } else if (accuracy.temp > accuracy) {
      accuracy <- accuracy.temp
      accuracy.table[i,] <- list("Num.of.Rules" = i,
                                 "Accuracy" = accuracy)
      rules.retained.previous <- rules.retained.new
    }


  }
  # # output the final selected rules:

  o <- list(rule = rules.retained.previous[,colnames(rules.retained.previous)!="Rules"],
       rule.raw = rules.retained.previous$Rules,
       data = data)
  class(o) <- "rules"
  o

}
