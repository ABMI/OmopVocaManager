# OmopVocaManager


# Introduction

Omop Vocabulary Manager (OmopVocaManger) is tool for uploading athena vocabulary data. It can not upload data in UTF-16 encoding yet.

# Features

- Unzip vocabulary zip file in folder that named code name and update time.
- If no tables in dbms, it create tables using ddl file.

# How to use

In R, to install package, typing this code
```
install.packages("devtools")
library(devtools)
install_github("ABMI/OmopVocaManager")
```

After install, you can use OmopVocaManager.
```
library(OmopVocaManager)
OmopVocaManager(<dbms>, <ip>, <schema>, <id>, <pw>)
```

If you want to create new voca tables, using dropTable parameter.
```
OmopVocaManager(<dbms>, <ip>, <schema>, <id>, <pw>, dropTable = T)
```

