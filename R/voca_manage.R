#' OmopVocaManager
#'
#' @docType package
#' @name OmopVocaManager
#' @title Upload vocabulary files to DBMS
#'
#' @description This is start of OmopVocaManager. It needs DB connection information
#'
#' @details
#' This function for help to upload vocabulary data to DB.
#' FIrst, it try to connect your dbms and check tables.
#'
#' @param dbms DBMS name to connect
#' @param ip IP to connect
#' @param schema schema name in DBMS
#' @param id Login id for dbms
#' @param pw Login password for dbms
#' @param droptable Logical. If TRUE, drop existed tables and create new tables.
#'
#' @examples
#' OmopVocaManager(dbms = 'sql server', ip = "168.192.21.16", schema = 'voca_2019', id = 'user_id', pw = 'user_pw')
#'
#' @export
#'
OmopVocaManager <- function(dbms, ip=NULL, schema = NULL,id=NULL, pw=NULL, droptable = FALSE){

    check.packages("SqlRender")
    check.packages("DatabaseConnector")
    check.packages("data.table")

    cat("Choose voca folder.")

    if(Sys.info()[1] == "Windows"){
        voca_dir <- choose.dir()
    }
    else{
        voca_dir <- readline("Set work directory path : ")
    }

    code <- readline("Input voca code name(ex.SNOMED ) : ")
    voca_id <- readline("Input voca id number : ")
    update <- readline("Input voca latest update(yyyy-mm-dd) : ")

    voca_dir <- voca_check(voca_dir,code,update)
    voca_upload(dbms, ip, schema, id, pw, droptable, voca_dir, code, voca_id, update)
}
