voca_manager <- function(dbms, ip=NULL, schema = NULL,id=NULL, pw=NULL, droptable = FALSE){

    cat("Choose voca folder.")

    if(Sys.info()[1] == "Windows"){
        voca_dir <- choose.dir()
    }
    else{
        voca_dir <- readline("Set work directory path : ")
    }

    code <- readline("Input voca code name(ex.SNOMED ) : ")
    update <- readline("Input voca latest update(yyyy-mm-dd) : ")

    voca_dir <- voca_check(voca_dir,code,update)
    voca_upload(dbms, ip, schema, id, pw, droptable, voca_dir)
}
