 [![Gitter](https://img.shields.io/badge/Available%20on-Intersystems%20Open%20Exchange-00b2a9.svg)](https://openexchange.intersystems.com/package/intersystems-iris-dev-template)
 [![Quality Gate Status](https://community.objectscriptquality.com/api/project_badges/measure?project=intersystems_iris_community%2Fintersystems-iris-dev-template&metric=alert_status)](https://community.objectscriptquality.com/dashboard?id=intersystems_iris_community%2Fintersystems-iris-dev-template)
 [![Reliability Rating](https://community.objectscriptquality.com/api/project_badges/measure?project=intersystems_iris_community%2Fintersystems-iris-dev-template&metric=reliability_rating)](https://community.objectscriptquality.com/dashboard?id=intersystems_iris_community%2Fintersystems-iris-dev-template)

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat&logo=AdGuard)](LICENSE)
# pxw-lib-sql
This is a query generator that replaces the %Library.SQLQuery, giving more control over the SQL code that is run.

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
    Set sql="SELECT ID, Name, Age, SSN FROM %ALLINDEX PXW_LIB_SQL_sample.Person WHERE "
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
SELECT ID, Name, Age, SSN FROM %ALLINDEX PXW_LIB_SQL_sample.Person 
WHERE 1=1
    --IF SearchName'=""
        AND Name %STARTSWITH :SearchName
    --ENDIF
    --IF MinAge'="" 
        AND Age >= :MinAge
    --ENDIF
}
```
For me, the SQL stands out more. 

The "logic" parts of the sql to use are just comments, so the editor (Studio and VS Code) will ignore them. This means that the overall SQL must be valid or the editor may get confused. 

The IF,ELSEIF,ELSE,ENDIF commands must be immediately after the start of the comment.
```
--IF will work, -- IF will not work.
/*IF will work, /* IF will not work.
```

The part after the IF is counted as object script code and simply dumped into the compiled code. This means that refering to the parameters here you do not need the colon (MinAge not :MinAge).

The above example is trivial, and actually writing this as a pure SQL query you can create the same effect with the same index usage. If the logic was more complicated this starts to gain an advantage as it will only compile what is needed and is more likely to use the indices correctly.

The repository contains two sample classes to demonstrate the functionality.

You can populate the Person object by running
```
IRISAPP>d ##class(PXW.LIB.SQL.sample.Person).Populate(10000)
```
You can test its working using SQL call or ObjectScript function.
```
IRISAPP>:sql
SQL Command Line Shell
----------------------------------------------------

The command prefix is currently set to: <<nothing>>.
Enter <command>, 'q' to quit, '?' for help.
[SQL]IRISAPP>>call PXW_LIB_SQL_sample.Queries_FilterPXW('Tesla*',110)

6.      call PXW_LIB_SQL_sample.Queries_FilterPXW('Tesla*',110)

Dumping result #1
Q2      ID      Name    Age     SSN
Y4296   4364    Tesla,Elvis O.  117     353-91-8615
S1278   689     Tesla,Fred S.   117     824-10-3588
E8663   8703    Tesla,Natasha E.        112     439-31-8828
L2639   8087    Tesla,Natasha R.        110     630-26-4787
Y2200   2470    Tesla,Patricia G.       119     678-47-4927
C6867   5089    Tesla,Rhonda Z. 115     138-26-5910
N9115   8009    Tesla,Umberto A.        111     988-65-2895

7 Rows(s) Affected
statement prepare time(s)/globals/cmds/disk: 0.0002s/4/101/0ms
          execute time(s)/globals/cmds/disk: 0.0021s/75/6,498/0ms
```
```
IRISAPP>s rs=##class(PXW.LIB.SQL.sample.Queries).FilterPXWFunc("Tesla*",110)

IRISAPP>d rs.%Display()
Q2      ID      Name    Age     SSN
Y4296   4364    Tesla,Elvis O.  117     353-91-8615
S1278   689     Tesla,Fred S.   117     824-10-3588
E8663   8703    Tesla,Natasha E.        112     439-31-8828
L2639   8087    Tesla,Natasha R.        110     630-26-4787
Y2200   2470    Tesla,Patricia G.       119     678-47-4927
C6867   5089    Tesla,Rhonda Z. 115     138-26-5910
N9115   8009    Tesla,Umberto A.        111     988-65-2895

7 Rows(s) Affected
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
This is something that may help when creating queries. The macros in here were and idea I had to make a complex Query - I might decide to drop this.

### PXW.LIB.SQL.sample package
This contains two classes, a small Person object that can be used for testing. A set of Queries showing different ways to create the same thing. Hopefully you will agree that the PXW way looks nicer.

## Known issues
There is no check on the query to make sure the IF/ENDIF counts match. If there is something wrong it will most likely show a compile error on a seemingly random line of the INT code.

The original code for this was developed a few years ago on an older version of Cache, and extended the %Library.SQLQuery class. When upgrading to Iris the %SQLQuery class changed and no longer worked with this extension. To resolve this the old Cache code was copied in to the PXW version. This may not be the best solution and perhaps it should be reworked to extend from the new %SQLQuery.

## Example query timings
I have run a number of tests to see if there is an improvement comparing a pure SQL version of the filtering with the PXW version. I think the SQL version is a fair test. It might be that the optimiser has some features that I am unaware of and that the complex search criteria could be handled better.

Here are the results of the test runs.
```
call PXW_LIB_SQL_sample.Queries_FilterSQL('Tesla*',42)
-- Row count: 39 Performance: 0.0169 seconds  18124 global references 98862 commands executed 0 disk read latency (ms)

call PXW_LIB_SQL_sample.Queries_FilterPXW('Tesla*',42)
-- Row count: 39 Performance: 0.0066 seconds  751 global references 12259 commands executed 0 disk read latency (ms) 


call PXW_LIB_SQL_sample.Queries_FilterSQL('Tesla,Alice G.',NULL)
--Row count: 1 Performance: 0.0034 seconds  324 global references 1559 commands executed 0 disk read latency (ms) 

call PXW_LIB_SQL_sample.Queries_FilterPXW('Tesla,Alice G.',NULL)
--Row count: 1 Performance: 0.0028 seconds  331 global references 4461 commands executed 0 disk read latency (ms) 


call PXW_LIB_SQL_sample.Queries_FilterSQL('Tesla,Alice G.',42)
--Row count: 1 Performance: 0.0100 seconds  18010 global references 93922 commands executed 0 disk read latency (ms)

call PXW_LIB_SQL_sample.Queries_FilterPXW('Tesla,Alice G.',42)
--Row count: 1 Performance: 0.0035 seconds  489 global references 5589 commands executed 0 disk read latency (ms) 


call PXW_LIB_SQL_sample.Queries_FilterSQL('Tesla*',NULL,'AGE')
--Row count: 55 Performance: 0.0079 seconds  544 global references 8917 commands executed 0 disk read latency (ms) 

call PXW_LIB_SQL_sample.Queries_FilterPXW('Tesla*',NULL,'AGE')
--Row count: 55 Performance: 0.0079 seconds  551 global references 13130 commands executed 0 disk read latency (ms)
```
Each test was run several times to elimiate caching and query creation overheads.

In some cases the PXW version is significantly faster. 
