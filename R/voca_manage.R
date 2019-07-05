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
#'
#' @param connectionDetails    An object of type \code{connectionDetails} as created using the
#'                             \code{\link[DatabaseConnector]{createConnectionDetails}} function in the
#'                             DatabaseConnector package.
#' @param oracleTempSchema     Should be used in Oracle to specify a schema where the user has write
#'                             priviliges for storing temporary tables.
#' @param vocabularyDatabaseSchema Schema name where your vocabulary in OMOP CDM format resides.
#'                             Note that for SQL Server, this should include both the database and
#'                             schema name, for example 'vocabulary_data.dbo'.
#' @param dropTable Logical. If TRUE, drop existed tables and create new tables.
#'
#' @examples
#' \donotrun{
#' connectionDetails <- createConnectionDetails(dbms = "postgresql",
#'                                              user = "joe",
#'                                              password = "secret",
#'                                              server = "myserver")
#'
#' OmopVocaManager(connectionDetails = connectionDetails,
#'                 oracleTempSchema = NULL,
#'                 vocabularyDatabaseSchema = 'CDM_voca',
#'                 dropTable = FALSE)
#' }
#'
#' @export
#'
#' @import SqlRender
#' @import DatabaseConnector
#' @import data.table
OmopVocaManager <- function(connectionDetails,
                            oracleTempSchema = NULL,
                            vocabularyDatabaseSchema,
                            dropTable = FALSE){

    cat("Choose voca folder.")

    if(Sys.info()[1] == "Windows"){
        importFolder <- choose.dir()
    }
    else{
        importFolder <- readline("Set work directory path : ")
    }

    vocabulary <- readline("Input voca vocabulary name(ex.SNOMED ) : ")
    vocaId <- readline("Input voca id number : ")
    updateDate <- readline("Input voca latest update(yyyy-mm-dd) : ")

    importFolder <- voca_check(importFolder,vocabulary,updateDate)

    voca_upload(connectionDetails = connectionDetails,
                oracleTempSchema = oracleTempSchema,
                vocabularyDatabaseSchema = vocabularyDatabaseSchema,
                dropTable = dropTable,
                importFolder=importFolder,
                vocabulary = vocabulary,
                vocaId = vocaId,
                updateDate = updateDate)
}
