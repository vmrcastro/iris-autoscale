Class CustomMetric.QueueMetric Extends %SYS.Monitor.SAM.Abstract
{

Parameter PRODUCT = "queue";

/// Collect metrics from the specified sensors
Method GetSensors() As %Status
{
    &sql(SELECT SUM("Count") INTO :queuesize FROM EnsPortal.Queues_EnumerateQueues())
    If (SQLCODE<0 || SQLCODE=100) {
        Return $$$ERROR($$$SQLError, $System.SQL.SQLCODE(SQLCODE))
    }
    do ..SetSensor("size",queuesize)
    Return $$$OK
}

}
