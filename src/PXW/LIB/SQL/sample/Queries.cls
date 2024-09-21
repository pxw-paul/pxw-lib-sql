Include PXW.LIB.SQL.Macros

Class PXW.LIB.SQL.sample.Queries Extends %RegisteredObject
{

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
