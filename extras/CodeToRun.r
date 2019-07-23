connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "sql server",
                                                                server = Sys.getenv("server_ip_17"),
                                                                user = Sys.getenv("user_id"),
                                                                password = Sys.getenv("user_pw")
)
OmopVocaManager(connectionDetails = connectionDetails,
                vocabularyDatabaseSchema = Sys.getenv("test_db"),
                dropIfExists = T)
