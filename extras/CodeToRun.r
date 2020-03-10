library(OmopVocaManager)
connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "sql server",
                                                                server = Sys.getenv("server_ip_16"),
                                                                user = Sys.getenv("USER_ID"),
                                                                password = Sys.getenv("PASSWORD_16")
)

OmopVocaManager(connectionDetails = connectionDetails,
                vocabularyDatabaseSchema = Sys.getenv("test_db"),
                dropIfExists = T)
