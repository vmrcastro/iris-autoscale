Class autoscale.BS.StopTest Extends Ens.BusinessService
{

Parameter ADAPTER;

Method OnProcessInput(Output pOutput As %Library.RegisteredObject) As %Status
{
    Try {
        Set tSC = $$$OK
        Set ^Stop = 1
        Hang 3
        Kill ^Stop
        Set pOutput = {"responseText":"Load test has successfully stopped!"}
    } Catch tException {
        Set tSC = tException.AsStatus()
        Set pOutput = {"responseText": ($System.Status.GetOneErrorText(tSC))}
    }
    
    Return tSC
}

}
