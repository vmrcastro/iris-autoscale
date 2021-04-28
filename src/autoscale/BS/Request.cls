Class autoscale.BS.Request Extends Ens.BusinessService
{

Parameter ADAPTER;

Method OnProcessInput(Output pOutput As %Library.RegisteredObject) As %Status
{
    Try {
        Set tSC = $$$OK
        Set tTarget = "Teste " _ ($RANDOM(3)+1)
        Set tRequest = ##class(Ens.Request).%New()
        Set tSC = ..SendRequestAsync(tTarget, tRequest)
        If $$$ISOK(tSC) {
            Set pOutput = {"responseText":"The request has been sended!"}
        } Else {
            Set pOutput = {"responseText": ($System.Status.GetOneErrorText(tSC))}
        }
    } Catch tException {
        Set tSC = tException.AsStatus()
        Set pOutput = {"responseText": ($System.Status.GetOneErrorText(tSC))}
    }
    
    Return tSC
}

}
