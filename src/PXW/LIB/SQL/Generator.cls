Class PXW.LIB.SQL.Generator
{

ClassMethod GenerateArgsSave(FormalSpec As %List) As %Status
{
	$$$GENERATE($CHAR(9)_"n %args,%PXWCache")
	For i=1:1:$LISTLENGTH(FormalSpec) {
		Set arg=$LISTGET(FormalSpec,i),argname=$LISTGET(arg,1)
		$$$GENERATE($CHAR(9)_"s %args("""_argname_""")=$g("_argname_")")
	}
	Quit $$$OK
}

ClassMethod GenerateEventStart(QueryId As %String) As %Status
{
	;$$$GENERATE($CHAR(9)_"s log=##class(PXW.LIB.SQLQuery.Log).%New("""_QueryId_""",.%args,.tLines)")
	;$$$GENERATE($CHAR(9)_"s sc=log.%Save() Throw:$$$ISERR(sc) ##class(%Exception.StatusException).ThrowIfInterrupt(sc)")
}

ClassMethod GenerateEventFinish() As %Status
{
	Quit $$$OK
}

ClassMethod GenerateArgsReplace() As %Status
{
	$$$GENERATE($CHAR(9)_"set tExecuteArgs = """"")
	$$$GENERATE($CHAR(9)_"for tPtr=1:2:$ListLength(tStatementArgs) {")
	$$$GENERATE($CHAR(9)_"	set tArg = $Case($List(tStatementArgs,tPtr),")
	$$$GENERATE($CHAR(9)_"       ""?"":""$g(%parm(""_$Increment(qcount)_""))"",")
	$$$GENERATE($CHAR(9)_"       ""c"":($List(tStatementArgs,tPtr+1)),")
	$$$GENERATE($CHAR(9)_"       ""v"":%args($List(tStatementArgs,tPtr+1)),:"""") ")
	$$$GENERATE($CHAR(9)_"  Set tExecuteArr($i(tExecuteArr))=tArg ")
	$$$GENERATE($CHAR(9)_"}")
	Quit $$$OK
}

/// Generate the code that generates SQL.
/// 
/// If the code contains certain comments then these will generate different code
/// --IF condition
/// --ELSEIF condition
/// --ELSE
/// --ENDIF
/// 
/// /*IF condition */
/// /*ELSEIF condition*/
/// /*ELSE*/
/// /*ENDIF*/
/// 
/// If these are found then the SQL between the if/endif is only included if the condition is true.
/// 
/// EXAMPLE: 
/// SELECT * FROM TABLE1
/// WHERE 1=1 
/// --IF param'="" 
///    AND PROPERTY=:param
/// --ENDIF
/// 
/// This will only include the check on PROPERTY if the parameter is set to something other than null.
/// 
/// Don't forget the sql or condition can contain macros:
/// You could create an include file like this
/// #define FIELD(%f) $PIECE(%f,"=",1)
/// #define VALUE(%f) $PIECE(%f,"=",2)
/// #define SQLFIELD(%f) $PIECE(%f,'=',1)
/// #define SQLVALUE(%f) $PIECE(%f,'=',2)
/// 
/// 
/// EXAMPLE: 
/// SELECT * FROM TABLE1
/// WHERE 1=1 
/// --IF $$$FIELD(param)="FIRSTNAME"
///    AND FIRSTNAME=$$$SQLVALUE(:param)
/// --ENDIF
/// --IF $$$FIELD(param)="SURNAME"
///    AND SURNAME=$$$SQLVALUE(:param)
/// --ENDIF
/// 
/// This would allow two different searches on one parameter: 
/// 	param="FIRSTNAME=JOHN"
/// 	param="SURNAME=SMITH"
/// Making sure that the best index is used each time without loads of parameters to the query
/// 
/// YOU could do some really clever search enabling BOTH searches, param="SURNAME=SMITH,FIRSTNAME=JOHN"
/// BUT not using these built in macros yet.
/// 
/// Possible JSON support needed as a built in thing: param={SURNAME:SMITH,FIRSTNAME:JOHN}
ClassMethod GenerateTLines(ByRef tLines As %String) As %Status
{
	Set commentstart="/"_"*",commentend="*"_"/",commentline="-"_"-"
	Set tKey=""
	Set tab=$CHAR(9)
	Set indent=tab
		
	$$$GENERATE(indent_"s tLines=""""")
	
	For  {
		Set tKey=$ORDER(tLines(tKey),1,sqlcode)
		Quit:tKey=""
		While sqlcode'="" {
			Set usqlcode=$ZSTRIP($ZCONVERT(sqlcode,"U"),"<W")
			If $EXTRACT(usqlcode,1,2)=commentstart,usqlcode[commentend {
				; in start and end comment
				If $EXTRACT(usqlcode,3,4)="IF" {					;/*IF
					Set ifcode=$PIECE($PIECE(sqlcode,commentstart,2),commentend,1)
					;s ifcode=..ChangeMacros(ifcode,"cos")
					$$$GENERATE(indent_ifcode_" {")
					Set sqlcode=$PIECE(sqlcode,commentend,2,*)
					Set indent=indent_tab
				} ElseIf $EXTRACT(usqlcode,3,8)="ELSEIF" {		;/*ELSEIF
					Set ifcode=$PIECE($PIECE(sqlcode,commentstart,2),commentend,1)
					Set indent=$EXTRACT(indent,1,*-1)
					$$$GENERATE(indent_ifcode_" {")
					Set sqlcode=$PIECE(sqlcode,commentend,2,*)
					Set indent=indent_tab
				} ElseIf $EXTRACT(usqlcode,3,6)="ELSE" {			;/*ELSE
					Set indent=$EXTRACT(indent,1,*-1)
					$$$GENERATE(indent_"} else {")
					Set sqlcode=$PIECE(sqlcode,commentend,2,*)
					Set indent=indent_tab
				} ElseIf $EXTRACT(usqlcode,3,7)="ENDIF" {			;/*ENDIF
					Set indent=$EXTRACT(indent,1,*-1)
					$$$GENERATE(indent_"}")
					Set sqlcode=$PIECE(sqlcode,commentend,2,*)
				} Else {
					$$$GENERATE(indent_"s tLines($i(tLines))="_$ZUTIL(144,1,sqlcode)_"")
					Set sqlcode=""
				}
			} ElseIf $EXTRACT(usqlcode,1,2)=commentline {
				; whole line comment
				If $EXTRACT(usqlcode,3,4)="IF" {						;--IF
					Set ifcode=$PIECE(sqlcode,commentline,2,*)
					$$$GENERATE(indent_ifcode_" {")
					Set sqlcode=""
					Set indent=indent_tab
				} ElseIf $EXTRACT(usqlcode,3,8)="ELSEIF" {			;--ELSEIF
					Set ifcode=$PIECE(sqlcode,commentline,2,*)
					Set indent=$EXTRACT(indent,1,*-1)
					$$$GENERATE(indent_"} "_ifcode_" {")
					Set sqlcode=""
					Set indent=indent_tab
				} ElseIf $EXTRACT(usqlcode,3,6)="ELSE" {				;--ELSE
					Set indent=$EXTRACT(indent,1,*-1)
					$$$GENERATE(indent_"} else {")
					Set sqlcode=""
					Set indent=indent_tab
				} ElseIf $EXTRACT(usqlcode,3,7)="ENDIF" {				;--ENDIF
					Set indent=$EXTRACT(indent,1,*-1)
					$$$GENERATE(indent_"}")
					Set sqlcode=""
				} Else {
					;s sqlcode=..ChangeMacros(sqlcode)
					$$$GENERATE(indent_"s tLines($i(tLines))="_$ZUTIL(144,1,sqlcode)_"")
					Set sqlcode=""
				}
			} Else {
				Set beforecomment=$PIECE(sqlcode,commentstart,1)
				;s beforecomment=..ChangeMacros(beforecomment,"sql")
				$$$GENERATE(indent_"s tLines($i(tLines))="_$ZUTIL(144,1,beforecomment)_"")
				Set sqlcode=$PIECE(sqlcode,beforecomment,2,*)
			}
		}
	}
	Quit $$$OK
}

}
