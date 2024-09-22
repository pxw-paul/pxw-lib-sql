Class PXW.sample.Person Extends (%Persistent, %Populate)
{

Property Name As %Name;

Property Age As %Integer(MAXVAL = 99, MINVAL = 0);

Property SSN As %String;

Property Q1 As %String;

Property Q2 As %String;

Index iName On Name;

/// I realise this is silly but its just an example.
Index iAge On Age;

/// I realise this is silly but its just an example.
Index iAgeName On (Age, Name);

Storage Default
{
<Data name="PersonDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Name</Value>
</Value>
<Value name="3">
<Value>Age</Value>
</Value>
<Value name="4">
<Value>SSN</Value>
</Value>
<Value name="5">
<Value>Q1</Value>
</Value>
<Value name="6">
<Value>Q2</Value>
</Value>
</Data>
<DataLocation>^PXW.sample.PersonD</DataLocation>
<DefaultData>PersonDefaultData</DefaultData>
<IdLocation>^PXW.sample.PersonD</IdLocation>
<IndexLocation>^PXW.sample.PersonI</IndexLocation>
<StreamLocation>^PXW.sample.PersonS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
