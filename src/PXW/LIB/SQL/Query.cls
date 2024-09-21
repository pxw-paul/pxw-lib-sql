Class PXW.LIB.SQL.Query Extends %Library.SQLQuery [ DependsOn = PXW.LIB.SQL.Generator ]
{

/// Func is a method that is used to invoke the query as a function, returning an instance of %SQL.StatementResult.
ClassMethod Func() As %SQL.StatementResult [ CodeMode = generator, ProcedureBlock = 1, ServerOnly = 1 ]
{
	;
	Set %code=0
		// don't generate any code if it not for a query
	If %mode="method" Quit $$$OK 
		// %mode is "propertymethod" for a valid query. We don't have any way currently to detect a misuse of a query class
	If '$$$comMemberDefined(%class,$$$cCLASSquery,%property) Quit $$$OK
		// Reset the formal list to the query declaration:
	$$$comSubMemberKeyGetLvar(formal,%class,$$$cCLASSquery,%property,$$$cQUERYmethod,%method,$$$cMETHformalspecparsed)
	$$$comMemberKeyGetLvar(qformal,%class,$$$cCLASSquery,%property,$$$cQUERYformalspecparsed)
	$$$comSubMemberKeySet(%class,$$$cCLASSquery,%property,$$$cQUERYmethod,%method,$$$cMETHformalspecparsed,formal_qformal)
	Set sc=$$SetOneQueryMeth^%occQuery(%class,%property,%method) Quit:$$$ISERR(sc) sc

	$$$comMemberKeyGetLvar(origin,%class,$$$cCLASSquery,%property,$$$cXXXXorigin)
	$$$comMemberKeyGetLvar(query,%class,$$$cCLASSquery,%property,$$$cQUERYsqlquery)

	// preparse the query to construct the actual argument list
	Set query = $ZSTRIP(query,"<W")
	Set tLines = 0 For tPtr = 1:1:$LENGTH(query,$$$NL) { Set tLine = $PIECE(query,$$$NL,tPtr) If tLine '= "" { Set tLines = tLines + 1, tLines(tLines) = tLine } }
	Set sc=$$ExpandMacros^%SYS.DynamicQuery(%class,.tLines) Quit:$$$ISERR(sc) sc

	Do ##class(PXW.LIB.SQL.Generator).GenerateArgsSave(qformal)
	Do ##class(PXW.LIB.SQL.Generator).GenerateTLines(.tLines)
	Do ##class(PXW.LIB.SQL.Generator).GenerateEventStart(%class_"||"_%property)

	$$$GENERATE($CHAR(9)_"set SQLCODE = $$dynamic^%qaqpreparser(.tLines,.tStatementPreparsed,.tStatementArgs)")
	Do ##class(PXW.LIB.SQL.Generator).GenerateArgsReplace()	

	Set tSelectMode = $CASE($$$ucase(%parameter("SELECTMODE")), "RUNTIME": "", "ODBC": 1, "DISPLAY": 2, "LOGICAL": 0, : "")
	$$$GENERATE($CHAR(9)_"try {")
	$$$GENERATE($CHAR(9,9)_"set tSchemaPath = ##class(%SQL.Statement).%ClassPath($classname())")
	$$$GENERATE($CHAR(9,9,9)_"set tStatement = ##class(%SQL.Statement).%New(" _ tSelectMode _ ",tSchemaPath)")
	$$$GENERATE($CHAR(9,9,9)_"do tStatement.prepare(tStatementPreparsed)")
	$$$GENERATE($CHAR(9,9)_"set tResult = tStatement.%Execute(tExecuteArr...)")
	$$$GENERATE($CHAR(9)_"}")
	$$$GENERATE($CHAR(9)_"catch tException { if '$Isobject($Get(tResult)) { set tResult = ##class(%SQL.StatementResult).%New() } set tResult.%SQLCODE=tException.AsSQLCODE(),tResult.%Message=tException.AsSQLMessage() }")
	$$$GENERATE($CHAR(9)_"Quit tResult")
	Quit $$$OK
}

/// 	Execute is passed parameters for Query
/// 	Returns handle for subsequent operations
ClassMethod Execute(ByRef %qHandle As %Binary) As %Status [ CodeMode = generator, ProcedureBlock = 1, ServerOnly = 1 ]
{
	Set %code=0
		// don't generate any code if it not for a query
	If %mode="method" Quit $$$OK
		// %mode is "propertymethod" for a valid query. We don't have any way currently to detect a misuse of a query class
	If '$$$comMemberDefined(%class,$$$cCLASSquery,%property) Quit $$$OK
		// Reset the formal list to the query declaration:
	$$$comSubMemberKeyGetLvar(formal,%class,$$$cCLASSquery,%property,$$$cQUERYmethod,%method,$$$cMETHformalspecparsed)
	$$$comMemberKeyGetLvar(qformal,%class,$$$cCLASSquery,%property,$$$cQUERYformalspecparsed)
	$$$comSubMemberKeySet(%class,$$$cCLASSquery,%property,$$$cQUERYmethod,%method,$$$cMETHformalspecparsed,formal_qformal)
	Set sc=$$SetOneQueryMeth^%occQuery(%class,%property,%method) Quit:$$$ISERR(sc) sc
	
	$$$comMemberKeyGetLvar(origin,%class,$$$cCLASSquery,%property,$$$cXXXXorigin)
	$$$comMemberKeyGetLvar(query,%class,$$$cCLASSquery,%property,$$$cQUERYsqlquery)
	// preparse the query to construct the actual argument list
	Set query = $ZSTRIP(query,"<W")
	Set tLines = 0 For tPtr = 1:1:$LENGTH(query,$$$NL) { Set tLine = $PIECE(query,$$$NL,tPtr) If tLine '= "" { Set tLines = tLines + 1, tLines(tLines) = tLine } }
	
	Set sc=$$ExpandMacros^%SYS.DynamicQuery(%class,.tLines) Quit:$$$ISERR(sc) sc
	$$$GENERATE($CHAR(9)_"n %running")

	Do ##class(PXW.LIB.SQL.Generator).GenerateArgsSave(qformal)

	Do ##class(PXW.LIB.SQL.Generator).GenerateTLines(.tLines)
	Do ##class(PXW.LIB.SQL.Generator).GenerateEventStart(%class_"||"_%property)
	$$$GENERATE($CHAR(9)_"set SQLCODE = $$dynamic^%qaqpreparser(.tLines,.tStatementPreparsed,.tStatementArgs)")
	Do ##class(PXW.LIB.SQL.Generator).GenerateArgsReplace()	

	Set tSelectMode = $CASE($$$ucase(%parameter("SELECTMODE")), "RUNTIME": "", "ODBC": 1, "DISPLAY": 2, "LOGICAL": 0, : "")
	$$$GENERATE($CHAR(9)_"try {")
	$$$GENERATE($CHAR(9,9)_"set tSchemaPath = ##class(%SQL.Statement).%ClassPath($classname())")
	$$$GENERATE($CHAR(9,9)_"if ($Isobject($Get(%qHandle(1)))) && (%qHandle(1).%IsA(""%SQL.Statement"")) { set tStatement = %qHandle(1) }")
	$$$GENERATE($CHAR(9,9)_"else {")
	$$$GENERATE($CHAR(9,9,9)_"set tStatement = ##class(%SQL.Statement).%New(" _ tSelectMode _ ",tSchemaPath)")
	$$$GENERATE($CHAR(9,9,9)_"do tStatement.prepare(tStatementPreparsed)")
	$$$GENERATE($CHAR(9,9,9)_"set %qHandle(1) = tStatement")
	
	$$$GENERATE($CHAR(9,9)_"}")
	$$$GENERATE($CHAR(9,9)_"set %qHandle = tStatement.%Execute(tExecuteArr...)") ;" _ $Extract(tExecuteArgs,2,*) _ ")")
	$$$GENERATE($CHAR(9,9)_"If %qHandle.%SQLCODE < 0 { If $isobject($get(%sqlcontext)) { Set %sqlcontext.%SQLCODE = %qHandle.%SQLCODE,%sqlcontext.%Message=%qHandle.%Message set sc = $$$ERROR($$$SQLCode,%qHandle.%SQLCODE,%qHandle.%Message) } } else { set sc = $$$OK }")
	$$$GENERATE($CHAR(9)_"}")
	$$$GENERATE($CHAR(9)_"catch tException { If $isobject($g(%qHandle)),%qHandle.%SQLCODE < 0 { If $isobject($get(%sqlcontext)) { Set %sqlcontext.%SQLCODE = tException.AsSQLCODE(),%sqlcontext.%Message=tException.AsSQLMessage() set sc = $$$ERROR($$$SQLCode,%qHandle.%SQLCODE,%qHandle.%Message) } } else { s sc=tException.AsSQLMessage()} }")
	$$$GENERATE($CHAR(9)_"Quit sc")
	
	Quit $$$OK
}

/// 	Close the query associated with the handle
ClassMethod Close(%qHandle As %Binary) As %Status [ CodeMode = generator, PlaceAfter = Execute, ProcedureBlock = 1, ServerOnly = 1 ]
{
	Set %code=0
	 	#; don't generate any code if it not for a query
	If %mode="method" Quit $$$OK
	 	#; Close cursor

	Do ##class(PXW.LIB.SQL.Generator).GenerateEventFinish()
	$$$GENERATE($CHAR(9)_"set %qHandle = """"")
	$$$GENERATE($CHAR(9)_"quit $$$OK")
	Quit $$$OK
}

/* direct from SQLQuery */
/// Fetch the next row of data from the query.
/// <p><var>qHandle</var> is query-defined data and is typically updated by <b>Fetch</b>.
/// <p>The <b>Fetch</b> method should set <var>Row</var> to be a $List of 
/// values corresponding to the columns of the query.  If we are past the end of the data
/// and no row is returned, <var>Row</var> should be set to null string ("").
/// If the non-empty row being returned is the last one, <var>AtEnd</var> could be
/// optionally set to 1, indicating that an additional call to <b>Fetch</b> may be avoided.
/// <p>
/// <var>Row</var> may also be subscripted. If any of the columns in the row are stream orefs
/// then the oref type information is lost in the <var>Row</var> $list encoded value. To retain
/// the oref type, place the oref into <var>Row(columnNumber)</var>. %Library.ResultSet recognizes
/// this form and will extract the column value as the subscripted value. 
ClassMethod Fetch(ByRef %qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ CodeMode = generator, PlaceAfter = Execute, ProcedureBlock = 1, ServerOnly = 1 ]
{
	Set %code=0
		#; don't generate any code if it not for a query
	If %mode="method" Quit $$$OK

	$$$GENERATE($CHAR(9)_"if %qHandle.%Next(.sc) { Set Row="""" For colPtr=1:1:%qHandle.%ResultColumnCount { Set Row=Row_$listbuild(%qHandle.%GetData(colPtr)) } } Else { Set Row="""",AtEnd=1 If $isobject($get(%sqlcontext)) { Set %sqlcontext.%SQLCODE = %qHandle.%SQLCODE, %sqlcontext.%Message = %qHandle.%Message i $$$ISOK(sc) { s %sqlcontext.%ROWCOUNT = %qHandle.%ROWCOUNT } else { s %sqlcontext.%Message=%qHandle.%Message } } }")
	$$$GENERATE($CHAR(9)_"QUIT sc")
	Set fcode=0
	Set fcode=fcode+1,fcode(fcode)="	Set RowSet="""",ReturnCount=0,AtEnd=0,columnCount=%qHandle.%ResultColumnCount,tStatus = $$$OK"
	Set fcode=fcode+1,fcode(fcode)="	Do {"
	Set fcode=fcode+1,fcode(fcode)="		Set next = %qHandle.%Next(.tStatus)"
	Set fcode=fcode+1,fcode(fcode)="		If next { Set ReturnCount = ReturnCount+1 For colPtr=1:1:columnCount { Set RowSet=RowSet_$listbuild(%qHandle.%GetData(colPtr)) } } Else { Set AtEnd=1 If $isobject($g(%sqlcontext)) { Set %sqlcontext.%SQLCODE = %qHandle.%SQLCODE, %sqlcontext.%Message = %qHandle.%Message If $$$ISOK(tStatus) { Set %sqlcontext.RowCount=%qHandle.%ROWCOUNT } Else { Set %sqlcontext.%Message=%qHandle.%Message } } }"
	Set fcode=fcode+1,fcode(fcode)="	} While (next) && (ReturnCount'=FetchCount) && (($length(RowSet)+($length(RowSet)\ReturnCount))'>24000)"
	Set fcode=fcode+1,fcode(fcode)="	Quit tStatus"

	Merge $$$tEXTcode(%property_"FetchRows")=fcode
	;zw %method
 	Quit $$$OK
}

/// 	FetchRows returns the next FetchCount rows in the query
/// 	Updates handle for subsequent operations
/// 	Returns $list for row or  "" if no more rows
ClassMethod FetchRows(ByRef %qHandle As %Binary, FetchCount As %Integer = 0, ByRef RowSet As %List, ByRef ReturnCount As %Integer, ByRef AtEnd As %Integer) As %Status [ CodeMode = generator, GenerateAfter = Fetch, PlaceAfter = Execute, ProcedureBlock = 1, ServerOnly = 1 ]
{
 Set %code=0
 Merge %code=$$$tEXTcode(%property_"FetchRows")
 Quit $$$OK
}

/*
 GetInfo()
	Reimplementation of %Query.GetInfo for SQL queries. A different call to ^%SYS.DynamicQuery is used to allow for
	an information only compile of the query to construct query information.
*/
/// Returns information about the query. It is used by the various <b>ResultSet</b> objects.
ClassMethod GetInfo(ByRef colinfo As %List, ByRef parminfo As %List, ByRef idinfo As %List, ByRef %qHandle As %Binary, extoption As %Integer = 0, extinfo As %List) As %Status [ CodeMode = generator, ProcedureBlock = 1, ServerOnly = 1 ]
{
	If %mode="method" Quit $$$OK
	$$$GENERATE("	$$$SQLQuerySQLInfoItem("_$$$QuoteName(%class)_","_$$$QuoteName(%property)_",1,""colinfo"")")
	$$$GENERATE("	$$$SQLQuerySQLInfoItem("_$$$QuoteName(%class)_","_$$$QuoteName(%property)_",2,""parminfo"")")
	$$$GENERATE("	$$$SQLQuerySQLInfoItem("_$$$QuoteName(%class)_","_$$$QuoteName(%property)_",3,""idinfo"")")
	$$$GENERATE("	If extoption {")
	$$$GENERATE("		$$$SQLQuerySQLInfoItem("_$$$QuoteName(%class)_","_$$$QuoteName(%property)_",4,""extinfo"")")
	$$$GENERATE("	}")
	$$$GENERATE("	Quit $$$OK")
	Quit $$$OK
}

/// Fetch and send a series of rows for the ODBC/JDBC server. For internal use only.
ClassMethod SendODBC(ByRef %qHandle As %Binary, ByRef array As %String, qacn As %Integer, ByRef %qrc As %Integer, ByRef piece As %Boolean, ColumnCount As %Integer) [ CodeMode = generator, GenerateAfter = (FetchODBC, Fetch), PlaceAfter = Execute, ProcedureBlock = 1, ServerOnly = 1 ]
{
	Set %code=0
	If %mode="method" Quit $$$OK
	$$$GENERATE($CHAR(9)_"kill array(qacn) set piece = 0, %qrc = %qHandle.%SendODBC()") 
	Quit $$$OK
}

ClassMethod GetODBCInfo(ByRef colinfo As %List, ByRef parminfo As %List, ByRef qHandle As %Binary) [ CodeMode = generator, ServerOnly = 1 ]
{
	Set %code=0
		#; don't generate any code if it's not for a query
	If %mode="method" Quit $$$OK
	$$$comClassKeyGetLvar(schema,%class,$$$cCLASSsqlschemaname)
	$$$comMemberKeyGetLvar(proc,%class,$$$cCLASSquery,%property,$$$cQUERYsqlname)
	Set SCHEMAQ = $$quoter^%occClass($$$ucase(schema))
	Set PROCQ = $$quoter^%occClass($$$ucase(proc))
		#; Generate code to check to see if the GetInfo data has already been compiled...
		#; Metadata versions are currently as follows:
		#;   DPV2695 (07/11/2006) - %protocol cleanup - remove all %protocol < 39 code
		#; 		Version 1: %protocol < 15; NO LONGER SUPPORTED!! Old colinfo (in colinfo1) and Old parminfo (parminfo2) (metadata1)
		#; 		Version 2: %protocol < 31, >14; New colinfo (in colinfo) and Old parminfo (parminfo2) (metadata2)
		#; 		Version 3: %protocol < 41, >30; New colinfo (in colinfo) and new parminfo (parminfo) (metadata3)
		#; 		Version 4: %protocol > 40; (current version) New colinfo (in colinfo)+bstr and new parminfo (parminfo) (metadata4)
	$$$GENERATE("	set version = $Select($Get(%protocol,41)>40:4,1:3)")
	$$$GENERATE("	$$$SQLQueryOdbcItem("_SCHEMAQ_","_PROCQ_",4,""metadata"")")
	$$$GENERATE("	Set colcount=$li(metadata,2),cmdlen=colcount*10,parmcount=$li(metadata,3+cmdlen),pmdlen=parmcount*6,parminfo=$li(metadata,cmdlen+3,cmdlen+pmdlen+3)")
	$$$GENERATE("	If version=4 {")
	$$$GENERATE("		Set colinfo=$li(metadata,2,2+cmdlen)")
	$$$GENERATE("	} Else {")
	$$$GENERATE("		Set colinfo=$li(metadata,2,2)")
	$$$GENERATE("		For i=0:1:colcount-1 Set colinfo=colinfo_$list(metadata,3+(i*10),11+(i*10))")
	$$$GENERATE("	}")
	$$$GENERATE("	Quit $$$OK")
	Quit $$$OK
}

/// Prepare the query for execution. For static queries, this method probably just
/// returns $$$OK. For dynamic queries this method will set up the information
/// returned by <b>GetInfo</b>. It is used by the various <b>ResultSet</b> objects.
ClassMethod Prepare(ByRef qHandle As %Binary, statement As %String, containid As %Integer = 0, optional As %String) As %Status [ CodeMode = expression, ServerOnly = 1 ]
{
$$$OK
}

}
