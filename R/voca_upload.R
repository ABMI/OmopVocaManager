voca_upload <- function(dbms, ip, schema, id, pw, droptable, voca_path,code, voca_id, update){

    voca_names <- tolower(gsub(x =list.files(path = voca_path, pattern = "\\w*.csv$"), pattern = ".csv$", replacement = ""))

    connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms, server = ip, schema=schema,
                                                                    user = id, password = pw)
    connection <- DatabaseConnector::connect(connectionDetails)


    new_table <- table_check(connection, dbms, schema, voca_names,droptable)

    if(dbms == "sql server" && !grepl(x = schema, pattern = "\\w*.dbo$")){
        schema <- paste0(schema,".dbo")
    }

    #Upload csv files
    csv_table <- sapply(voca_names, function(csv_file){fread(file = paste0(voca_path,"\\",csv_file,".csv"),
                                                             sep = "\t", quote="",encoding = 'UTF-8')})

    for(i in 1:length(voca_names)){
        cat(paste("\n",voca_names[i],"table uploading...\n"))

        if(new_table[voca_names[i]]){
            DatabaseConnector::insertTable(connection, voca_names[i],
                                           csv_table[[i]], dropTableIfExists = F, progressBar = T,
                                           createTable = F)
        }else{
            ddl_sql <- SqlRender::loadRenderTranslateSql(sqlFilename = "create_tables.sql", packageName = "OmopVocaManager",
                                                         dbms = dbms)
            ddl_sql <- SqlRender::splitSql(ddl_sql)
                # Catch 'date' data type issue

            if(voca_names[i]=='concept' || voca_names[i]=='concept_relationship' || voca_names[i]=='drug_strength'){
                if(nrow(csv_table[[i]])!= 0){
                    csv_table[[i]]$valid_start_date <-
                        paste0(substring(csv_table[[i]]$valid_start_date,1,4),'-',
                               substring(csv_table[[i]]$valid_start_date,5,6),'-',
                               substring(csv_table[[i]]$valid_start_date,7,8))

                    csv_table[[i]]$valid_end_date <-
                        paste0(substring(csv_table[[i]]$valid_end_date,1,4),'-',
                               substring(csv_table[[i]]$valid_end_date,5,6),'-',
                               substring(csv_table[[i]]$valid_end_date,7,8))
                    }
                }
                if (voca_names[i] == "concept") {
                    #String 'NA' in csv convert to NA in R.
                    csv_table[[i]][[2]][is.na(csv_table[[i]]$concept_name)] <- 'NA'
                    #invalid reason to NULL
                    csv_table[[i]][[10]] <- NA

                    DatabaseConnector::insertTable(connection, paste0("##",voca_names[i]), csv_table[[i]],
                                                   dropTableIfExists = T, progressBar = T, createTable = T)

                    #!exists encoding Issue
                    #temp table ddl
                    ddl_conv <- function(sql, tbl_name,temp_name){
                        sql <- gsub(x = sql, pattern= paste("CREATE TABLE",tbl_name),
                                    replacement = paste("CREATE TABLE",temp_name))
                        sql <- tolower(sql)
                        sql <- SqlRender::translate(sql, targetDialect = dbms)
                        DatabaseConnector::executeSql(connection, sql,progressBar = F,reportOverallTime = F)
                    }
                    tryCatch({
                        t_ins_name <- "##insert"
                        t_del_name <- "##delete"
                        concept_ddl <- ddl_sql[grep(x = ddl_sql, pattern = paste0("CREATE TABLE ",voca_names[i]," "),ignore.case = T)]
                        ddl_conv(concept_ddl, voca_names[i], t_ins_name)
                        ddl_conv(concept_ddl, voca_names[i], t_del_name)

                        temp_sql <-
                        "INSERT INTO @del SELECT * FROM concept except SELECT * FROM ##concept;
                        INSERT INTO @ins SELECT * FROM ##concept except SELECT * FROM concept;
                        delete from concept where concept_id in (select concept_id from @del);"
                        temp_sql <- SqlRender::render(temp_sql,del = t_del_name, ins = t_ins_name)
                        DatabaseConnector::executeSql(connection, temp_sql, progressBar = F, reportOverallTime = F)

                        insert_sql <- "INSERT INTO concept SELECT * FROM @ins"
                        insert_sql <- SqlRender::render(temp_sql, ins = t_ins_name)
                        DatabaseConnector::executeSql(connection, insert_sql)

                        clean_sql <-
                        "DROP TABLE IF EXISTS @ins;
                        DROP TABLE IF EXISTS @del;"
                        clean_sql <- SqlRender::render(temp_sql,del = t_del_name, ins = t_ins_name)
                        DatabaseConnector::executeSql(connection, clean_sql, progressBar = F, reportOverallTime = F)
                    },error = function(e){
                        clean_sql <-
                        "DROP TABLE IF EXISTS @ins;
                        DROP TABLE IF EXISTS @del;"
                        clean_sql <- SqlRender::render(temp_sql,del = t_del_name, ins = t_ins_name)
                        DatabaseConnector::executeSql(connection, clean_sql, progressBar = F, reportOverallTime = F)
                        cat(paste(voca_names[i], "table is failed.\n"))
                        print(e)
                    })
                }
                else {
                    tryCatch({
                        DatabaseConnector::insertTable(connection, paste0("##", voca_names[i]), csv_table[[i]],
                                                       dropTableIfExists = T, progressBar = T, createTable = T)

                        temp_ddl <- ddl_sql[grep(x = ddl_sql, pattern = paste("CREATE TABLE",voca_names[i]),ignore.case = T)]
                        temp_ddl <- gsub(x = temp_ddl, pattern= paste("CREATE TABLE",voca_names[i]),
                                         replacement = "CREATE TABLE ##TEMP")
                        temp_ddl <- tolower(temp_ddl)
                        temp_ddl <- SqlRender::translate(temp_ddl, targetDialect = dbms)
                        DatabaseConnector::executeSql(connection, temp_ddl, progressBar = F, reportOverallTime = F)

                        sql <- "INSERT INTO ##TEMP SELECT * FROM ##@tbl_name except (SELECT * from @tbl_name);"
                        sql <- SqlRender::render(sql = sql, tbl_name = voca_names[i])
                        sql <- SqlRender::translate(sql, targetDialect = dbms)
                        DatabaseConnector::executeSql(connection, sql, progressBar = F, reportOverallTime = F)

                        sql <- "INSERT INTO @tbl_name SELECT * FROM ##TEMP;"
                        sql <- SqlRender::render(sql = sql, tbl_name = voca_names[i])
                        sql <- SqlRender::translate(sql, targetDialect = dbms)
                        DatabaseConnector::executeSql(connection, sql)

                        DatabaseConnector::executeSql(connection, "DROP TABLE ##TEMP", progressBar = F, reportOverallTime = F)
                    },error = function(e){
                        DatabaseConnector::executeSql(connection, "DROP TABLE IF EXISTS ##TEMP", progressBar = F, reportOverallTime = F)
                        cat(paste("\n",voca_names[i], "table is failed.\n"))
                        print(e)
                    })
            }
            }
        }

    #Create Metadata tuple and insert it after vocabulary files insert in db
    sql <- "INSERT INTO metadata values('@voca_id', '@code_name', '@latest_update', '@upload_date', '@uploader');"
    sql <- SqlRender::render(sql, voca_id = voca_id, code_name = code, latest_update = update,
                             upload_date = Sys.Date(), uploader = id)
    sql <- SqlRender::translate(sql, targetDialect = dbms)
    DatabaseConnector::executeSql(connection, sql)
    DatabaseConnector::disconnect(connection)
    cat("Done.")
}
