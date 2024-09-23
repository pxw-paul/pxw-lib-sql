 [![Gitter](https://img.shields.io/badge/Available%20on-Intersystems%20Open%20Exchange-00b2a9.svg)](https://openexchange.intersystems.com/package/intersystems-iris-dev-template)
 [![Quality Gate Status](https://community.objectscriptquality.com/api/project_badges/measure?project=intersystems_iris_community%2Fintersystems-iris-dev-template&metric=alert_status)](https://community.objectscriptquality.com/dashboard?id=intersystems_iris_community%2Fintersystems-iris-dev-template)
 [![Reliability Rating](https://community.objectscriptquality.com/api/project_badges/measure?project=intersystems_iris_community%2Fintersystems-iris-dev-template&metric=reliability_rating)](https://community.objectscriptquality.com/dashboard?id=intersystems_iris_community%2Fintersystems-iris-dev-template)

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat&logo=AdGuard)](LICENSE)
# pxw-lib-sql
This is a query generator that replaces the %Library.SQLQuery, giving more control over SQL code.

To enable, change:

Query filter(Name As %String = "", Age As %Integer = "") As %SQLQuery

to

Query filter(Name As %String = "", Age As %Integer = "") As PXW.LIB.SQL.Query

## Description
This project:
* Runs InterSystems IRIS Community Edition in a docker container
* Creates a new namespace and database IRISAPP
* Loads the ObjectScript code into IRISAPP database using Package Manager

## Prerequisites
Make sure you have [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and [Docker desktop](https://www.docker.com/products/docker-desktop) installed.

## Installation

Clone/git pull the repo into any local directory

```
$ git clone https://github.com/pxw-paul/pxw-lib-sql.git
```

Open the terminal in this directory and call the command to build and run InterSystems IRIS in container:
*Note: Users running containers on a Linux CLI, should use "docker compose" instead of "docker-compose"*
*See [Install the Compose plugin](https://docs.docker.com/compose/install/linux/)*



```
$ docker-compose up -d
```

To open IRIS Terminal do:

```
$ docker-compose exec iris iris session iris -U IRISAPP
IRISAPP>
```

## What does it do?
It is often necessary to build an SQL string that is different based on the parameters passed in. 

For example, we might have a search string built that is based on Name OR Age OR Both.

```
ClassMethod SimpleFilterString(SearchName As %String = "", MinAge As %Integer = "") as %String
{
    Set sep=""
    Set sql="SELECT ID, Name, Age, SSN FROM %ALLINDEX PXW_sample.Person WHERE "
    If SearchName'="" {
        Set sql=sql_"Name %STARTSWITH '"_SearchName_"'",sep=" AND "
    }
    If MinAge'="" Set sql=sql_sep_"Age>="_MinAge
    Quit sql
}
```
Here the focus is on the ObjectScript and the SQL that's generated is hard to see.

Using this query generator, the above code could be written as a query where the focus is on the SQL and the extra logic becomes embedded as comments.
```
Query SimpleFilterPXW(SearchName As %String = "", MinAge As %Integer = "") As PXW.LIB.SQL.Query [ SqlProc ]
{
SELECT ID, Name, Age, SSN FROM %ALLINDEX PXW_sample.Person 
WHERE 1=1
    --IF SearchName'=""
        AND Name %STARTSWITH :SearchName
    --ENDIF
    --IF MinAge'="" 
        AND Age >= :MinAge
    --ENDIF
}
```
The SQL becomes the focus. 

The "logic" parts of the sql to use are comments, so the editor (Studio and VS Code) will ignore them. The overall SQL must be valid or the editor may get confused. 

The IF,ELSEIF,ELSE,ENDIF commands must be immediately after the start of the comment.
```
--IF will work, -- IF will not work.
/*IF will work, /* IF will not work.
```

The part after the IF is counted as object script code and simply dumped into the compiled code. This means that refering to the parameters here you do not need the colon (MinAge not :MinAge).

The above example is trivial, and actually writing this as a pure SQL query you can create the same effect with the same index usage. If the logic was more complicated this starts to gain an advantage as it will only compile what is needed and is more likely to use the indices correctly - although query optimisation that happens in Iris is very good and produces some really neat plans.

The repository contains two sample classes to demonstrate the functionality, these are text files so are not loaded automatically. You can load them if you want to try the tests.

You can populate the Person object by running
```
IRISAPP>d ##class(PXW.sample.Person).Populate(10000)
```
You can test its working using SQL call or ObjectScript function.
```
IRISAPP>:sql
SQL Command Line Shell
----------------------------------------------------

The command prefix is currently set to: <<nothing>>.
Enter <command>, 'q' to quit, '?' for help.
[SQL]IRISAPP>>call PXW_sample.PersonQueries_FilterPXW('Tesla*',95)
10.     call PXW_sample.PersonQueries_FilterPXW('Tesla*',95)

Dumping result #1
Q2      ID      Name    Age     SSN
G2310   687     Tesla,Elvis A.  96      762-84-8864
Y9218   214     Tesla,Emily C.  99      674-43-9686
R6725   7356    Tesla,Jose S.   95      356-42-2497
B7247   7000    Tesla,Norbert A.        99      420-73-2273
A5668   9747    Tesla,Norbert A.        96      440-75-2962
L1050   6520    Tesla,Patricia S.       98      141-80-1777

6 Rows(s) Affected
---------------------------------------------------------------------------
```
```
IRISAPP>s rs=##class(PXW.sample.PersonQueries).FilterPXWFunc("Tesla*",95)

IRISAPP>d rs.%Display()
Q2      ID      Name    Age     SSN
G2310   687     Tesla,Elvis A.  96      762-84-8864
Y9218   214     Tesla,Emily C.  99      674-43-9686
R6725   7356    Tesla,Jose S.   95      356-42-2497
B7247   7000    Tesla,Norbert A.        99      420-73-2273
A5668   9747    Tesla,Norbert A.        96      440-75-2962
L1050   6520    Tesla,Patricia S.       98      141-80-1777

6 Rows(s) Affected
```

## Running unit tests

There are no unit tests yet.


## What else is inside the repository

This is based on the standard template, so contains all the github, vscode and docker settings to get going.

The classes needed to use the new query template are:
### PXW.LIB.SQL.Query
This is that class that replaces %Library.SQLQuery on Queries.

### PXW.LIB.SQL.Generator
This class is used by PXW.LIB.SQL.Query when generating the code

### PXW.LIB.SQL.Macros.INC
This is something that may help when creating queries. The macros in here were an idea I had to make a complex query.

### PXW.sample package
The directory PXW/sample contains two cls files with the code for example classes. 

The two classes are: a small Person object that can be used for testing. A set of Queries showing different ways to create the same results. 

I hope you will agree that the PXW way looks nicer.

## Known issues
There is no check on the query to make sure the IF/ENDIF counts match. If there is something wrong it will most likely show a compile error on a seemingly random line of the INT code.

The original code for this was developed a few years ago on an older version of Cache, and extended the %Library.SQLQuery class. When upgrading to Iris the %SQLQuery class changed and no longer worked with this extension. To resolve this the old Cache code was copied in to the PXW version. This may not be the best solution and perhaps it should be reworked to extend from the new %SQLQuery.

