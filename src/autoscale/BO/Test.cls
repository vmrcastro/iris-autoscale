Class autoscale.BO.Test Extends Ens.BusinessOperation
{

Method OnMessage(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
    Hang $Get(^Hang(..%ConfigName), $Random(31))
    Return $$$OK
}

}
