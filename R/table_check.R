table_check <- function(connection, dbms, schema, voca_files,droptable){
    temp <- c(voca_files, 'metadata')
    created<-FALSE
    check_db <- function(tbl_name,schema,dbms,drop=droptable){
        sql <- paste0("SELECT TABLE_NAME FROM @schema_name.information_schema.tables WHERE TABLE_NAME IN ('",tbl_name,"')")
        sql <- SqlRender::render(sql,schema_name = schema)
        sql <- SqlRender::translate(sql, targetDialect = dbms)
        if(length(which(tolower(DatabaseConnector::querySql(connection, sql)$TABLE_NAME)==tbl_name))==0||drop == T){
            if(tbl_name == 'metadata'){
                #metadata table ddl
                ddl_sql <- "CREATE TABLE metadata (
                id INT NOT NULL,
                code_name varchar(100),
                latest_update date,
                upload_date date,
                upload_user varchar(50));"
            }else{
                #table ddl
                ddl_sql <- SqlRender::loadRenderTranslateSql(sqlFilename = "create_tables.sql", packageName = "OmopVocaManager", dbms = dbms)
                ddl_sql <- SqlRender::splitSql(ddl_sql)
                ddl_sql <- ddl_sql[grep(x = ddl_sql, pattern = paste0("CREATE TABLE ",tbl_name,"\\s"),ignore.case = F)]
                ddl_sql <- tolower(ddl_sql)
            }
            ddl_sql <- SqlRender::translate(ddl_sql, targetDialect = dbms)

            tryCatch({
                DatabaseConnector::executeSql(connection, ddl_sql)
            },error=function(e){
                stop("Creating tables is failed. Check ddl file.")
            })

            return(T)
        }else{
            return(F)
        }
    }
    created <- sapply(temp, function(x){check_db(x,schema,dbms)})
    return(created)
}
