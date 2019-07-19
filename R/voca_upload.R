vocaUpload <- function(connectionDetails,
                       oracleTempSchema = NULL,
                       vocabularyDatabaseSchema,
                       dropIfExists = F,
                       importFolder){
  vocaNames <- tolower(gsub(x =list.files(path = importFolder, pattern = "\\w*.csv$"), pattern = ".csv$", replacement = ""))
  connection <- DatabaseConnector::connect(connectionDetails)

  #Load csv files
  csvTables <- sapply(X = toupper(vocaNames),
                      FUN = function(csvFile){data.table::fread(file = file.path(importFolder,paste0(csvFile,".csv")),
                                                                sep = "\t", quote="", na.strings = "")})

  #create table
  metaDdl <- "{@dropIfExists}?{IF OBJECT_ID('@vocabularyDatabaseSchema.metadata', 'U') IS NOT NULL
    	        DROP TABLE @vocabularyDatabaseSchema.metadata;}
    	        CREATE TABLE @vocabularyDatabaseSchema.metadata (
                id INT NOT NULL,
                code_name varchar(100),
                latest_update date,
                upload_date date,
                upload_user varchar(50));
                "
  metaDdl<-SqlRender::render(metaDdl,
                             dropIfExists = dropIfExists,
                             vocabularyDatabaseSchema=vocabularyDatabaseSchema)

  metaDdl<-SqlRender::translate(metaDdl,
                                oracleTempSchema = oracleTempSchema,
                                targetDialect = connectionDetails$dbms)
  DatabaseConnector::executeSql(connection = connection,
                                sql = metaDdl)

  ddlSql <- SqlRender::loadRenderTranslateSql(sqlFilename = "create_tables.sql",
                                              packageName = "OmopVocaManager",
                                              vocabularyDatabaseSchema = vocabularyDatabaseSchema,
                                              oracleTempSchema = oracleTempSchema,
                                              dropIfExists = dropIfExists,
                                              dbms = connectionDetails$dbms)


  DatabaseConnector::executeSql(connection = connection, sql = ddlSql)

  #upload the file to the table
  for(i in seq(length(csvTables))){
    csvTable <- csvTables[[i]]
    if(names(csvTables)[i]=='CONCEPT' || names(csvTables)[i]=='CONCEPT_RELATIONSHIP' || names(csvTables)[i]=='DRUG_STRENGTH'){
      if(nrow(csvTable)!= 0){
        csvTable$valid_start_date <-
          paste0(substring(csvTable$valid_start_date,1,4),'-',
                 substring(csvTable$valid_start_date,5,6),'-',
                 substring(csvTable$valid_start_date,7,8))

        csvTable$valid_end_date <-
          paste0(substring(csvTable$valid_end_date,1,4),'-',
                 substring(csvTable$valid_end_date,5,6),'-',
                 substring(csvTable$valid_end_date,7,8))
      }
    }
    if(names(csvTables)[i]=="concept_cpt4") next #pass the concept_cpt4 table
    sql <- "@vocabularyDatabaseSchema"
    sql <- SqlRender::render(sql=sql, vocabularyDatabaseSchema = vocabularyDatabaseSchema)
    sql <- SqlRender::translate(sql=sql, targetDialect = connectionDetails$dbms)
    print(paste0(sql,".",names(csvTables)[i]))
    tryCatch(DatabaseConnector::insertTable(connection = connection,
                                            tableName = paste0(sql,".",names(csvTables)[i]),
                                            data = csvTable, #data.frame(csvTable)
                                            dropTableIfExists = F,
                                            createTable = F,
                                            progressBar = T,
                                            oracleTempSchema = oracleTempSchema),
             error=function(e){
               print(paste(names(csvTables)[i]),"is failed.")
             }
    )

  }

  ##This should be updated!!!!

  #Create Metadata tuple and insert it after vocabulary files insert in db
  # sql <- "INSERT INTO @vocabularySchemaDatabase.metadata values('@vocaId', '@vocabulary_name', '@latest_updateDate', '@upload_date', '@uploader');"
  # sql <- SqlRender::render(sql = sql, vocabularySchemaDatabase = vocabularySchemaDatabase,
  #                          upload_date = Sys.Date(),
  #                          uploader = connectionDetails$user)
  # sql <- SqlRender::translate(sql = sql, targetDialect = connectionDetails$dbms, oracleTempSchema = oracleTempSchema)
  # DatabaseConnector::executeSql(connection = connection, sql = sql)
  # DatabaseConnector::disconnect(connection)
  DatabaseConnector::disconnect(connection)
  cat("Done.")
}
