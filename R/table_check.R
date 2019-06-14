table_check <- function(conneciton, dbms, schema, voca_files){
    temp <- c(gsub(x = voca_files,pattern = ".csv$", replacement = ""), 'metadata')
    check_db <- function(tbl_name,schema,dbms){
        sql <- paste0("SELECT TABLE_NAME FROM @schema_name.information_schema.tables WHERE TABLE_NAME IN ('",tbl_name,"')")
        sql <- SqlRender::render(sql,schema_name = schema)
        sql <- SqlRender::translate(sql, targetDialect = dbms)

        if(length(which(DatabaseConnector::querySql(connection, sql)$TABLE_NAME == tbl_name))==0){
            if(dbms == "sql server" && !grepl(x = schema, pattern = "\\w*.dbo$")){
                schema.dbo <- paste0(schema,".dbo")
            }else{
                schema.dbo <- schema
            }
            if(tbl_name == 'metadata'){
                #metadata table ddl
                ddl_sql <- "CREATE TABLE @schema_name.metadata (
                id INT NOT NULL,
                code_name varchar(100),
                latest_update date,
                upload_date date,
                upload_user varchar(50));"
            }else{
                #table ddl
                ddl_sql <- SqlRender::readSql("./inst/sql/create_tables.sql")
                ddl_sql <- SqlRender::splitSql(ddl_sql)
                ddl_sql <- ddl_sql[grep(x = ddl_sql, pattern = paste0("\\[",tbl_name,"\\]"))]
            }

            ddl_sql <- SqlRender::render(ddl_sql,schema_name = schema.dbo)
            ddl_sql <- SqlRender::translate(ddl_sql, targetDialect = dbms)
            ddl_sql <- gsub("\r|\t|\n"," ", ddl_sql)

            DatabaseConnector::executeSql(connection, ddl_sql)
        }else{
            return('Exist')
        }
    }
    sapply(temp, function(x){check_db(x,schema,dbms)})
}
