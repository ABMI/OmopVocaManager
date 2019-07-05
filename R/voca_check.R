# voca check

voca_check <- function(importFolder,vocabulary,updateDate){

    voca_zip <- select.list(list.files(path = importFolder, pattern = ".+{1}zip$"))
    unzip(zipfile = file.path(importFolder,voca_zip), exdir = file.path(importFolder,vocabulary,updateDate),overwrite=T)
    voca_path <- file.path(importFolder,vocabulary,updateDate)
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
