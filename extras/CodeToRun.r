connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "sql server",
                                                                server = Sys.getenv("server_ip_17"),
                                                                user = Sys.getenv("user_id"),
                                                                password = Sys.getenv("user_pw")
                                                                )
#debug(OmopVocaManager)
OmopVocaManager(connectionDetails = connectionDetails,
                vocabularyDatabaseSchema = "JH_TEST.dbo",
                dropIfExists = T)

