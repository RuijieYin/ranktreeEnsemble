#include <Rcpp.h>
using namespace Rcpp;

// Function to convert gene pairs
// [[Rcpp::export]]
List convert_genepairs(DataFrame input_data)
{
  // Get gene pair data
  DataFrame X(input_data);

  // Number of rows
  int n = X.nrows();
  // Number of columns
  int d = X.size() - 1;
  // Create a new data frame
  NumericMatrix newX(n, d * (d - 1) / 2);
  Rcpp::StringVector colnames_newX((d * (d - 1) / 2));
  int k = 0;
  for (int i = 0; i < (d - 1); i++)
  {
    for (int j = i + 1; j < d; j++)
    {
      // Rcout << "The value of j : " << j << "\n";
      NumericVector col1 = X[i];
      NumericVector col2 = X[j];
      for (int row = 0; row < n; row++)
      {
        // Rcout << "The value of row : " << row << "\n";
        double val1 = col1[row];
        double val2 = col2[row];
        newX(row, k) = (val1 < val2) ? 1 : 0;
      }

      // CharacterVector names = X.names();
      //
      k++;
    }
  }
  // Create a new data frame with class labels
  for (int index = 0; index < (d * (d - 1) / 2); index++)
  {
    colnames_newX(index) = std::to_string(index + 1);
  }

  colnames_newX.push_back("yvar_names");
  DataFrame data_boosting = DataFrame::create(newX, Named("yvar_names") = X[d]);
  // colnames(data_boosting) = colnames_newX;
  data_boosting.attr("names")=colnames_newX;
  List dataConverted;
  dataConverted["data.converted"] = data_boosting;

  return dataConverted;
}
