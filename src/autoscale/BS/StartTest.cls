Class autoscale.BS.StartTest Extends Ens.BusinessService
{

Parameter ADAPTER;

Method OnProcessInput(Output pOutput As %Library.RegisteredObject) As %Status
{
        Set pRequest = ##class(Ens.Request).%New()
        Set tSC = ..SendRequestAsync("Teste",pRequest)
        If $$$ISOK(tSC) {
            set pOutput = {"responseText":"Load test has successfully started!"}
        } Else {
            Set pOutput = {"responseText":($System.Status.GetOneErrorText(tSC))}
        }
        
        Quit tSC
}

}
