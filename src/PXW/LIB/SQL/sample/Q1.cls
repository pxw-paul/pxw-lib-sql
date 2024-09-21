Class PXW.LIB.SQL.sample.Q1 Extends %RegisteredObject
{

Query FilterBy(Name As %String = "", Age As %Integer = "", Order As %String = "NAME") As %SQLQuery(CONTAINID = 1, SELECTMODE = "RUNTIME") [ SqlProc ]
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

}
