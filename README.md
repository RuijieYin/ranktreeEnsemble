# ranktreeEnsemble: an R package for implementing ensemble methods of rank-based trees as single-sample predictors for gene expression classification 
<!-- badges: start -->
[![CRAN status](https://badges.cranchecks.info/worst/metavcov.svg)](https://cran.r-project.org/web/checks/check_results_ranktreeEnsemble.html)
[![CRAN version](https://www.r-pkg.org/badges/version/ranktreeEnsemble)](https://cran.r-project.org/web/packages/ranktreeEnsemble/index.html)
[![CRAN release date](https://www.r-pkg.org/badges/last-release/ranktreeEnsemble)](https://cran.r-project.org/web/packages/ranktreeEnsemble/index.html)
[![CRAN downloads](https://cranlogs.r-pkg.org/badges/ranktreeEnsemble)](https://cran.r-project.org/web/packages/ranktreeEnsemble/index.html)
<!-- badges: end -->
* The package is also available at R CRAN: https://CRAN.R-project.org/package=ranktreeEnsemble
* A python version can be found at: https://github.com/RuijieYin/Ensemble_Methods_of_Rank_Based_Trees_py

## Authors
Ruijie Yin (ruijieyin428@gmail.com), Chen Ye (cxy364@miami.edu) and Min Lu (m.lu6@umiami.edu)

## Reference
Min Lu, Ruijie Yin and Steven X. Chen. Ensemble Methods of Rank-Based Trees for Single Sample Classification with Gene Expression Profiles. To appear: Journal of Translational Medicine

#### Description
Fast computing an ensemble of rank-based trees via boosting or random forest on binary and multi-class problems. It converts continuous gene expression profiles into ranked gene pairs, for which the variable importance indices are computed and adopted for dimension reduction. Decision rules can be extracted from trees. 

### Installation
```
install.packages("ranktreeEnsemble")
library(ranktreeEnsemble)
```
### Examples

* Build a Random Rank Forest with Variable Importance:
```
data(tnbc)
obj <- rforest(subtype~., data = tnbc[1:100,c(1:5,337)])
importance(obj)
predict(obj)$label
predict(obj, tnbc[101:110,1:5])$label

### pair() to convert continuous variables to binary ranked pairs
tnbc[101:110,1:5]
datp <- pair(tnbc[101:110,1:5])
datp
predict(obj, datp, newdata.pair = TRUE)$label
```

* Extract Interpretable Decision Rules:
```
objr <- extract.rules(obj)
objr$rule[1:5,]
predict(objr)$label[1:5]

objrs <- select.rules(objr,tnbc[110:130,c(1:5,337)])
predict(objrs, tnbc[111:120,1:5])$label
objrs$rule[1:5,]
```

* Build a Boosting model with LogitBoost Cost with Variable Importance:
```
objb <- rboost(subtype~., data = tnbc[1:100,c(1:5,337)])
importance(objb)
predict(objb)$label
predict(objb, tnbc[101:110,1:5])$label
```
  
