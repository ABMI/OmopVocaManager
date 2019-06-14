# voca check

voca_check <- function(voca_dir,code,update){
    voca_zip <- select.list(list.files(path = voca_dir, pattern = "^vocabulary_download_.+{1}zip$"))
    unzip(zipfile = paste0(voca_dir,"\\",voca_zip), exdir = paste0(voca_dir,"\\",code,"_",update),overwrite =FALSE)
    voca_path <- paste0(voca_dir,"\\",code,"_",update)
    voca_files <- list.files(path = voca_path, pattern = "\\w*.csv$")

    files <- c(
        "RELATIONSHIP.csv",
        "CONCEPT_ANCESTOR.csv",
        "CONCEPT_CLASS.csv",
        "CONCEPT_RELATIONSHIP.csv",
        "CONCEPT_SYNONYM.csv",
        "DOMAIN.csv",
        "DRUG_STRENGTH.csv",
        "CONCEPT.csv",
        "VOCABULARY.csv"
    )
    if(length(grep(pattern=TRUE, x= sapply(voca_files, function(name){grepl(pattern = paste0("^",name,"$"), x=files)})))<9)
    {
        stop("Some files are missing. Check your vocabulary files.\n")
    }else{
        cat("Voca files checked.\n")
        return(voca_path)
    }
}
