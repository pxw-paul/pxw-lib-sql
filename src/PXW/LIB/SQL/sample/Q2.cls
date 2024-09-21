Class PXW.LIB.SQL.sample.Q2 Extends %RegisteredObject
{

Query FilterBy(Name As %String = "", Age As %Integer = "", Order As %String = "NAME") As PXW.LIB.SQL.Query [ SqlProc ]
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

}
