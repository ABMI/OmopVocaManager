voca_upload <- function(dbms, ip, schema, id, pw, droptable, voca_path,code, voca_id, update){
    voca_names <- tolower(gsub(x =list.files(path = voca_path, pattern = "\\w*.csv$"), pattern = ".csv$", replacement = ""))
    connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms, server = ip, schema=schema, user = id, password = pw)
    connection <- DatabaseConnector::connect(connectionDetails)
    new_table <- table_check(connection, dbms, schema, voca_names)
    #Create table


    if(dbms == "sql server" && !grepl(x = schema, pattern = "\\w*.dbo$")){
        schema <- paste0(schema,".dbo")
    }

    #Upload csv files
    #To do

    csv_table <- sapply(voca_names, function(csv_file){fread(file = paste0(voca_path,"\\",csv_file,".csv"), sep = "\t", quote="")})

    if(new_table){
        csv_table$concept$invalid_reason <- ""
        for (i in 1:length(voca_names)) {
            DatabaseConnector::insertTable(connection, voca_names[i],
                                           csv_table[[i]], dropTableIfExists = F, progressBar = T,
                                           createTable = F)
        }
    }else{
        for(i in 1:length(voca_names)){
            DatabaseConnector::insertTable(connection, paste0("##",
                                                              voca_names[i]), csv_table[[i]], dropTableIfExists = T,
                                           progressBar = T, tempTable = T, createTable = T)
            tryCatch({
                if (voca_names[i] == "concept") {
                    sql <- "SELECT * FROM ##concept where concept_id not in(SELECT concept_id FROM concept)"
                    new_data <- data.table(DatabaseConnector::querySql(connection, sql))
                    sql <- "DELETE FROM concept where concept_id in
                    (SELECT A.concept_id FROM concept as A inner join ##concept as B on A.concept_id = B.concept_id where
                    (A.concept_name != B.concept_name or A.domain_id != B.domain_id or A.vocabulary_id != B.vocabulary_id
                    or A.concept_class_id != B.concept_class_id or A.concept_code!=B.concept_code));"
                    DatabaseConnector::executeSql(connection, sql)
                    ##Encoding Issue
                    DatabaseConnector::insertTable(connection,
                                                   voca_names[i], new_data, dropTableIfExists = F,
                                                   createTable = F)
                }
                else {
                    sql <- "SELECT * FROM ##@tbl_name except (SELECT * from @tbl_name)"
                    sql <- SqlRender::render(sql = sql, tbl_name = voca_names[i])
                }
                sql <- SqlRender::translate(sql, targetDialect = dbms)
                query_result <- DatabaseConnector::querySql(connection,
                                                            sql)
                cat(paste("Export", voca_names[i], "data..."))
                DatabaseConnector::insertTable(connection, voca_names[i],
                                               query_result, dropTableIfExists = F, createTable = F,
                                               progressBar = T)
            }, error = function(e) {
                cat(paste("\n",voca_names[i], "table is failed!\n"))
            })
        }
    }


    #Create Metadata tuple and insert it after vocabulary files insert in db
    cat("Insert metadata...")
    sql <- "INSERT INTO @schema_name.metadata values('@voca_id', '@code_name', '@latest_update', '@upload_date', '@uploader');"
    sql <- SqlRender::render(sql, schema_name = schema, voca_id = voca_id,
                             code_name = code, latest_update = update, upload_date = Sys.Date(),
                             uploader = id)
    sql <- SqlRender::translate(sql, targetDialect = dbms)
    DatabaseConnector::executeSql(connection, sql)
    DatabaseConnector::disconnect(connection)
    cat("Done.")
}

