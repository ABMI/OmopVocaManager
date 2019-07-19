# voca check

vocaCheck <- function(importFolder){

    workTime <- Sys.Date()
    vocaZip <- select.list(list.files(path = importFolder, pattern = "\\w*.zip$"))
    unzip(zipfile = file.path(importFolder,vocaZip), exdir = file.path(importFolder,workTime),overwrite=T)
    vocaPath <- file.path(importFolder,workTime)
    vocaFiles <- list.files(path = vocaPath, pattern = "\\w*.csv$")

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
    if(length(grep(pattern=TRUE,
                   x= sapply(vocaFiles,
                             function(name)
                                 {grepl(pattern = paste0("^",name,"$"), x=files)})))<9)
    {
        stop("Some files are missing. Check your vocabulary files.\n")
    }else{
        cat("Voca files checked.\n")
        return(vocaPath)
    }
}
