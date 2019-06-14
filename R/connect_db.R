#connecting db server

connect_db <- function(dbms, ip, schema, id, pw){
    check.packages("DatabaseConnector")
    connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms, server = ip, schema=schema, user = id, password = pw)
    connection <- DatabaseConnector::connect(connectionDetails)
    return(connection)
}
