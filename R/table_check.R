
tableCheck <- function(connectionDetails, oracleTempSchema, vocabularyDatabase, vocaFiles, createTable){

    temp <- c(vocaFiles, 'metadata')
    created<-FALSE
    check_db <- function(tblName,vocabularyDatabase,dbms,drop=createTable){
        sql <- paste0("SELECT TABLE_NAME FROM @schema_name.information_schema.tables WHERE TABLE_NAME IN ('",tblName,"')")
        sql <- SqlRender::render(sql,schema_name = vocabularyDatabase)
        sql <- SqlRender::translate(sql, targetDialect = dbms)
        if(length(which(tolower(DatabaseConnector::querySql(connection, sql)$TABLE_NAME)==tblName))==0||drop == T){
            if(tblName == 'metadata'){
                #metadata table ddl
                ddlSql <- "CREATE TABLE @vocabularyDatabaseSchema.metadata (
                id INT NOT NULL,
                code_name varchar(100),
                latest_update date,
                upload_date date,
                upload_user varchar(50));"
            }else{
                #table ddl
                ddlSql <- SqlRender::loadRenderTranslateSql(sqlFilename = "create_tables.sql",
                                                            vocabularyDatabaseSchema = vocabularyDatabaseSchema,
                                                            packageName = "OmopVocaManager",
                                                            oracleTempSchema = oracleTempSchema,
                                                            dbms = connectionDetails$dbms)
                ddlSql <- SqlRender::splitSql(ddlSql)
                ddlSql <- ddlSql[grep(x = ddlSql, pattern = paste0("CREATE TABLE ",tbl_name,"\\s"),ignore.case = F)]
                ddlSql <- tolower(ddlSql)
            }
            ddlSql <- SqlRender::translate(ddlSql, targetDialect = connectionDetails$dbms)

            tryCatch({
                DatabaseConnector::executeSql(connection, ddlSql)
            },error=function(e){
                DatabaseConnector::disconnect(connection)
                stop("Creating tables is failed. Check ddl file.")
            })
        }
    }
    created <- sapply(temp, function(x){check_db(tblName = x,
                                                 vocabularyDatabase = vocabularyDatabase,
                                                 dbms = connectionDetails$dbms)})
    return(created)
}
