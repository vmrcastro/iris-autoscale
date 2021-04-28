Class autoscale.REST.Dispatcher Extends %CSP.REST
{

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<Route Url="/:service" Method="GET" Call="InvokeEnsembleService"/>
</Routes>
}

ClassMethod InvokeEnsembleService(service) As %Status
{
        set status = ##class(Ens.Director).CreateBusinessService(service, .instance)
        if $$$ISOK(status) {
               #dim %response as %CSP.Response
               Do %response.SetHeader("Connection","close")
               #dim response as %DynamicObject
               set status = instance.OnProcessInput(.response)
               if $isObject(response) {
                       write response.%ToJSON()
               }
        }
        quit status
}

}
