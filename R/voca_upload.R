voca_upload <- function(dbms, ip, schema, id, pw, droptable, voca_files, voca_path){
    check.packages("SqlRender")

    voca_files <- list.files(path = voca_path, pattern = "\\w*.csv$")
    connection <- connect_db(dbms,ip,schema, id,pw)
    #Create table
    table_check(conneciton, dbms, schema, voca_files)

    if(dbms == "sql server" && !grepl(x = schema, pattern = "\\w*.dbo$")){
        schema <- paste0(schema,".dbo")
    }

    #Upload csv files
    #To do

    # library(data.table)
    # values <- gsub(x = paste0("('",paste0(test_table,collapse = "' ,'"),"')"), pattern = "''", replacement = "NULL")
    # sql <- paste0("INSERT INTO @schema_name.@tbl_name VALUES ", test_table[1])
    #
    # sql <- paste0("INSERT INTO @schema_name.@tbl_name VALUES ", test_table[1])
    #
    # test_table <- fread(file = paste0(voca_path,"\\CONCEPT.csv"), sep = "\t", quote="")
    # con <- odbcDriverConnect("driver=SQL Server; server=128.1.99.58; UID=imblock; PWD=mirKJH09!@; database=JH_TEST")
    # ?write.table(file = con, x = test_table, sep = "\t")
    # test_sql <- SqlRender::render(test_sql, schema_name = schema, tbl_name = "DOMAIN")
    # test_sql <- SqlRender::translate(test_sql, targetDialect = dbms)
    # DatabaseConnector::executeSql(connection, test_sql)

    #Create Metadata tuple and insert it after vocabulary files insert in db
    meta_write <- function(dbms,schema,voca_id,code,update,upload,who = id){
        sql <- "INSERT INTO @schema_name.metadata values('@voca_id', '@code_name', '@latest_update', '@upload_date', '@uploader');"
        sql <- SqlRender::render(sql, schema_name = schema, voca_id = voca_id, code_name = code, latest_update = update, upload_date = Sys.Date(), uploader = who)
        sql <- SqlRender::translate(sql, targetDialect = dbms)
        DatabaseConnector::executeSql(connection, sql)
        cat("")
    }
    meta_write(dbms,schema,voca_id,code,update,upload)
}
