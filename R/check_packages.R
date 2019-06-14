#' Check package installed
#'
#' This function check package successfully installed. If not, package install.
#' @keywords package
#' @param pkg package name
#' @export
#' @examples check.packages("dplyr")

check.packages <- function(pkg){
    if (!(pkg %in% installed.packages()[, "Package"])){
        install.packages(pkg)
        library(pkg, character.only = T)
    }
    else{
        library(pkg, character.only = T)
    }
}
