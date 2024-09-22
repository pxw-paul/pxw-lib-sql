Include PXW.LIB.SQL.Macros

Class PXW.LIB.SQL.sample.Queries Extends %RegisteredObject
{

/// This method shows how a simple search might be implemented by creating an sql string using ObjectScript.
ClassMethod SimpleFilterString(SearchName As %String = "", MinAge As %Integer = "") As %String
{
    Set sep=""
    Set sql="SELECT ID, Name, Age, SSN FROM %ALLINDEX PXW_LIB_SQL_sample.Person WHERE "
    If SearchName'="" {
        Set sql=sql_"Name %STARTSWITH '"_SearchName_"'",sep=" AND "
    }
    If MinAge'="" Set sql=sql_sep_"Age>="_MinAge
    Quit sql
}

/// This query method shows how a simple search might be implemented using PXW.LIB.SQL.Query.
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

/// This method shows a more complex filter example (a Name that contains * indicates a startswith seach, otherwise an exact name search) and you can specify ordering.
ClassMethod FilterString(Name As %String = "", Age As %Integer = "", Order As %String = "NAME") As %String
{
    Set sep=""
    Set sql="SELECT ID, Name, Age, SSN FROM %ALLINDEX PXW_LIB_SQL_sample.Person WHERE "
    If Name'="" {
        If Name["*" {
            Set sql=sql_"Name %STARTSWITH '"_$piece(Name,"*",1)_"'",sep=" AND "
        } Else {
            Set sql=sql_"Name='"_Name_"'",sep=" AND "
        }
    }
    If Age'="" Set sql=sql_sep_"Age>="_Age
    Set sql=sql_" ORDER BY "
    If Order="NAME" {
        Set sql=sql_"Name"
    } Else {
        Set sql=sql_"Age"
    }
    Set sql=sql_",ID"
    Quit sql
}

/// This query method shows a more complex search with ordering using SQL alone.
/// Note that this query is returning Q1 in column 1 so that I can look for the generated cached query more easiy and distinguish it from queries generated in other ways.
Query FilterSQL(Name As %String = "", Age As %Integer = "", Order As %String = "NAME") As %SQLQuery(CONTAINID = 1, SELECTMODE = "RUNTIME") [ SqlProc ]
{
SELECT Q1,ID, Name, Age, SSN FROM %ALLINDEX PXW_LIB_SQL_sample.Person 
WHERE 
    (:Name IS NULL 
        OR (:Name['*' 
                AND Name %STARTSWITH $piece(:Name,'*',1)
            )
        OR (
            NOT(:Name['*') AND Name=:Name 
        )
    )
AND 
    (:Age IS NULL OR Age >= :Age)

ORDER BY (CASE WHEN :Order='NAME' THEN Name
               ELSE Age
          END
         )
         ,ID
}

/// This query method shows a more complex search with ordering using PXW.LIB.SQL.Query
/// Note that this query is returning Q1 in column 1 so that I can look for the generated cached query more easiy and distinguish it from queries generated in other ways.
Query FilterPXW(Name As %String = "", Age As %Integer = "", Order As %String = "NAME") As PXW.LIB.SQL.Query [ SqlProc ]
{
SELECT Q2,ID, Name, Age, SSN FROM %ALLINDEX PXW_LIB_SQL_sample.Person 
WHERE 1=1
    --IF Name'=""
        --IF Name["*"
            AND Name %STARTSWITH $piece(:Name,'*',1)
        --ELSE
            AND Name=:Name
        --ENDIF
    --ENDIF
    --IF Age'="" 
        AND Age >= :Age
    --ENDIF

    ORDER BY 
        --IF Order="NAME"
            Name, 
        --ELSE 
            Age,
        --ENDIF
        ID
}

Query FilterByOther(Filter As %String) As PXW.LIB.SQL.Query [ SqlProc ]
{
SELECT Q2,ID, Name, Age, SSN FROM %ALLINDEX PXW_LIB_SQL_sample.Person 
WHERE 1=1
    --IF $$$FIELD(Filter)="NAME"
        AND Name=$$$SQLVALUE(:Filter)
    --ELSEIF $$$FIELD(Filter)="SSN"
        AND SSN=$$$SQLVALUE(:Filter)
    --ENDIF
}

}
