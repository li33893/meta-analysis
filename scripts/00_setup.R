### 00_setup.R — A file to install and to load all the packages in need
### To add a new package: append its name as an element to "required_packages"


# 0. Packages to install or to load
required_packages <- c(
  "dplyr",      # data manipulation: filter(), mutate(), select(), %>%
  "tidyverse",  # core collection that includes ggplot2, tidyr, purrr, etc.
  "readxl",     # read Excel files: read_excel()
  "janitor",    # clean column names: clean_names()
  "metafor",    # meta-analysis: escalc(), rma(), forest()
  "meta",       # meta-analysis: metagen() for pre-calculated effect sizes
  "writexl",    # export Excel files: write_xlsx()
  "readr",      # read and write CSV files: read_csv(), write_csv()
  "tibble"      # modern way of data frame
)


# 1. Function — install a package only if it has not been installed yet
install_if_hasnt <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    # requireNamespace(): checks whether a package is already installed; returns TRUE/FALSE
    # quietly = TRUE: suppresses the warning when the package is not found
    install.packages(pkg)
  }
}


# 2. Install missing packages
invisible(
  # invisible(): suppresses the list of NULLs that lapply() would otherwise print
  lapply(required_packages, install_if_hasnt)
  # lapply(vector, function): applies the function to every element in the vector
)


# 3. Load all packages
invisible(
  lapply(
    required_packages,
    function(pkg) {
      library(pkg, character.only = TRUE)
      # library() only accepts package names as literals (e.g., library(readxl)) by default.
      # Here pkg is a loop variable, not a literal, so character.only = TRUE is required
      # to tell library() to read the string value stored in pkg as the package name.
    }
  )
)


cat("00_setup.R completed successfully.\n")