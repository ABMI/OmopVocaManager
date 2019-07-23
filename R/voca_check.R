# Copyright 2019 Observational Health Data Sciences and Informatics
#
# This file is part of OmopVocaManager
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

vocaCheck <- function(importFolder){

    workTime <- Sys.Date()
    #vocaZip <- select.list(list.files(path = importFolder, pattern = "\\w*.zip$"))
    #unzip(zipfile = file.path(importFolder,vocaZip), exdir = file.path(importFolder,workTime),overwrite=T)
    vocaFiles <- list.files(path = importFolder, pattern = "\\w*.csv$")

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
    }
}
