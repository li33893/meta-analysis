#### 00_setup.R ####
#### Purpose: prepare packages for the meta-analysis project ####


#### 1. List all packages needed in this project ####

required_packages <- c(
  "dplyr",      # 主要用来管理列表
  "tidyverse",  # data cleaning: filter(), mutate(), select(), %>%
  "readxl",     # read Excel files: read_excel()
  "janitor",    # clean column names: clean_names()
  "metafor",    # meta-analysis: escalc(), rma(), forest()
  "meta",       # additional meta-analysis functions
  "writexl",    # export Excel files if needed
  "readr"       # csv
)


#### 2. Define a helper function: install a package only if it is missing ####

# Install the package if no package with the same name can be found.
install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
}


#### 3. Apply this helper function to every package in required_packages ####

invisible(
  # lapply() returns a list of results, but we do not need to print them.
  # We only want to run the package-checking function for each package.
  lapply(required_packages, install_if_missing)
)


#### 4. Load all required packages ####

invisible(
  lapply(required_packages, function(pkg) {
    # character.only = TRUE means pkg is a string variable,
    # such as "readxl", rather than a directly written package name.
    library(pkg, character.only = TRUE)
  })
)


#### 5. Print a completion message ####

cat("00_setup.R completed successfully.\n")