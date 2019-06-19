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
        csv_table$concept$invalid_reason <- NULL
        for(i in 1:length(voca_names)){
            print(paste(voca_name[i],"table insert..."))
            DatabaseConnector::insertTable(connection, voca_names[i], csv_table[[i]], dropTableIfExists = F, progressBar = T, createTable = F)
        }
    }else{
        cat("Duplication check!")
        for(i in 1:length(voca_names)){
            #임시 테이블 파트 문제
            DatabaseConnector::insertTable(connection, paste0("##",voca_names[i]), csv_table[[i]], dropTableIfExists = T, progressBar = T, tempTable = T, createTable = T)
            if(voca_names[i]=="concept"){
                sql <- "SELECT * FROM tempdb..##concept where concept_id not in (SELECT concept_id FROM concept)"
            }else{
                sql <- "SELECT * FROM tempdb..##@tbl_name except (SELECT * from @tbl_name)"
                sql <- SqlRender::render(sql = sql, tbl_name = voca_names[i])
            }
            sql <- SqlRender::translate(sql,targetDialect = dbms)
            query_result <- DatabaseConnector::querySql(connection,sql)
            DatabaseConnector::insertTable(connection, voca_names[i], query_result, dropTableIfExists = F, createTable = F)
        }
    }

    #Create Metadata tuple and insert it after vocabulary files insert in db
    meta_write <- function(dbms,schema,voca_id,code = code,update = update, who = id){
        cat("Insert metadata.")
        sql <- "INSERT INTO @schema_name.metadata values('@voca_id', '@code_name', '@latest_update', '@upload_date', '@uploader');"
        sql <- SqlRender::render(sql, schema_name = schema, voca_id = voca_id, code_name = code, latest_update = update, upload_date, upload = Sys.Date(), uploader = who)
        sql <- SqlRender::translate(sql, targetDialect = dbms)
        DatabaseConnector::executeSql(connection, sql)
    }
    meta_write(dbms,schema,voca_id)
    DatabaseConnector::disconnect(connection)
    stop('Done.')
}
