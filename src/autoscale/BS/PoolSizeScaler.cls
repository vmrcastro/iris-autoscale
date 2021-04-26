/// Auto Scale PoolSize
Class autoscale.BS.PoolSizeScaler Extends Ens.BusinessService
{

/// Hosts to be Monitored. If not informed, will monitor all BPs & BOs
Property Hosts As Ens.DataType.ConfigName;

/// When should I scale UP
/// Will not increase poolsize if already at MaxPoolSize
Property ScaleUpWhen As %Integer(DISPLAYLIST = ",Queue is >= MaxQueueSize,Queue is >= PoolSize,Queue is >= 1/2 PoolSize", VALUELIST = ",1,2,3") [ InitialExpression = 3 ];

/// How much should the PoolSize be increased
Property ScaleUpFactor As %Integer(DISPLAYLIST = ",MaxQueueSize,Queue Size,Half Queue Size,One", VALUELIST = ",1,2,3,4") [ InitialExpression = 2 ];

/// When should I scale Down
/// Will not decrease poolsize if already at startup poolsize
Property ScaleDownWhen As %Integer(DISPLAYLIST = ",Never,Idle Jobs is >= MaxQueueSize,Idle Jobs is >= 1/2 Actual PoolSize,Idle Jobs >= 1/4 Initial PoolSize", VALUELIST = ",1,2,3,4") [ InitialExpression = 3 ];

/// How much should the PoolSize be decreased
Property ScaleDownFactor As %Integer(DISPLAYLIST = ",MaxQueueSize,Minimum Idle Jobs,Idle Jobs,Half Idle Jobs,One", VALUELIST = ",1,2,3,4,5") [ InitialExpression = 2 ];

/// Used for a fixed queue size evaluation
Property MaxQueueSize As %Integer [ InitialExpression = 5 ];

/// Maximum PollSize
Property MaxPoolSize As %Integer [ InitialExpression = 100 ];

/// Time to wait before Scale Down in seconds
Property ScaleDownWaitTime As %Integer [ InitialExpression = 300 ];

/// Revert Hosts PoolSizes to Initial Value On End of Scaler Job (onTearDown)
Property RevertToInitialAtEnd As %Boolean [ InitialExpression = 1 ];

/// Keeps Hosts Data
/// $List : 1-Item Name, 2-Item ID, 3-Initial PoolSize, 4-Actual PoolSize, 5-Last Scale Time, 6-Minimum Idle Jobs in the Period
Property HostsData As %List [ MultiDimensional ];

/// Could Not Scale UP flag
Property CantScaleUp As %Boolean [ InitialExpression = 0 ];

/// Sum of Queue Sizes that could not be scaled
Property TotalQueueSizeNotScaled As %Integer;

/// PoolSize changed?
Property PoolSizeChanged As %Boolean;

Parameter ADAPTER = "Ens.InboundAdapter";

Parameter SETTINGS = "Hosts:Scaler:selector?multiSelect=1&context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId},ScaleUpWhen:Scaler,ScaleUpFactor:Scaler,MaxQueueSize:Scaler,MaxPoolSize:Scaler,ScaleDownWhen:Scaler,ScaleDownFactor:Scaler,ScaleDownWaitTime:Scaler,RevertToInitialAtEnd:Scaler";

/// Change Item PoolSize value
/// Method ChangePoolSize(pItemName As %String, pNewPoolSize As %Integer, pNow As %DateTime = {$Now()}) As %Status
Method ChangePoolSize(pSeq As %Integer, pNewPoolSize As %Integer, pNow As %DateTime = {$Now()}) As %Status
{
    Set tData = ..HostsData(pSeq)
    // $List : 1-Item Name, 2-Item ID, 3-Initial PoolSize, 4-Actual PoolSize, 5-Last Scale Time, 6-Minimum Idle Jobs in the Period
    $$$TRACE("Change Pool Size of " _ $List(tData) _" from " _ $List(tData, 4) _" to " _ pNewPoolSize)
    Set tItem = ##class(Ens.Config.Item).%OpenId($List(tData, 2), ,.tSC)
    If $$$ISERR(tSC) Return tSC
    Set tItem.PoolSize = pNewPoolSize
    Set tSC = tItem.%Save()
    If $$$ISERR(tSC) Return tSC
    Set $List(..HostsData(pSeq), 4, 6) = $ListBuild(pNewPoolSize, $Now(), pNewPoolSize)
    Set ..PoolSizeChanged = 1
    Return tSC
}

/// Change the PoolSize
/// Scale Up PoolSize of Item
/// Method ScaleUp(pItemName As %String, pQueueSize As %Integer) As %Status
Method ScaleUp(pSeq As %Integer, pQueueSize As %Integer) As %Status
{
    Set tData = ..HostsData(pSeq)
    // $List : 1-Item Name, 2-Item ID, 3-Initial PoolSize, 4-Actual PoolSize, 5-Last Scale Time, 6-Minimum Idle Jobs in the Period
    Set tPoolSize = $List(tData, 4)
    // Already scaled up to the maximum?
    If tPoolSize = ..MaxPoolSize {
        // This is bad... Can't Scale Up anymore
        Set ..CantScaleUp = 1
        Set ..TotalQueueSizeNotScaled = ..TotalQueueSizeNotScaled + pQueueSize
        Return $$$OK
    }
    // Calculate new PoolSize
    Set tNewPoolSize = tPoolSize + $Case(..ScaleUpFactor,
                                            1   :   ..MaxQueueSize,
                                            2   :   pQueueSize,
                                            3   :   pQueueSize \ 2,
                                                :   1 )
    // Can't go over MaxPoolSize
    If tNewPoolSize > ..MaxPoolSize {
        Set tNewPoolSize = ..MaxPoolSize
    }
    // Changed?
    If tNewPoolSize '= tPoolSize {
        // Increase PoolSize
        Return ..ChangePoolSize(pSeq, tNewPoolSize)
    }
    Return $$$OK
}

/// Scale Down PoolSize of Item
/// Method ScaleDown(pItemName As %String, pIdleJobs As %Integer) As %Status
Method ScaleDown(pSeq As %Integer, pIdleJobs As %Integer) As %Status
{
    Set tData = ..HostsData(pSeq)
    // $List : 1-Item Name, 2-Item ID, 3-Initial PoolSize, 4-Actual PoolSize, 5-Last Scale Time, 6-Minimum Idle Jobs in the Period
    Set tInitialPoolSize = $List(tData, 3)
    Set tPoolSize = $List(tData, 4)
    Set tLastTimeScaledUp = $List(tData, 5)
    // Already scaled down to minimum?
    If (tPoolSize = tInitialPoolSize) {
        Return $$$OK
    }
    // Not enough idle time ?
    If $System.SQL.DATEDIFF("SS", tLastTimeScaledUp, $Now()) < ..ScaleDownWaitTime {
        // Check Minimum Idle Jobs in the Period
        If $List(tData, 6) > pIdleJobs {
            Set $List(..HostsData(pSeq), 6) = pIdleJobs
        }
        Return $$$OK
    }
    // Calculate new PoolSize
    Set tNewPoolSize = tPoolSize - $Case(..ScaleDownFactor,
                                            1   :   ..MaxQueueSize,
                                            2   :   $List(tData, 6),
                                            3   :   pIdleJobs,
                                            4   :   pIdleJobs \ 2,
                                                :   1 )
    // Can't be less than Initial PoolSize
    If tNewPoolSize < tInitialPoolSize {
        Set tNewPoolSize = tInitialPoolSize
    }
    // Changed?
    If tNewPoolSize '= tPoolSize {
        // Decrease PoolSize
        Return ..ChangePoolSize(pSeq, tNewPoolSize)
    }
    Return $$$OK
}

/// Count Idle jobs
Method GetIdleJobsCount(pItemName As %String, Output pCounter As %Integer) As %Status
{
    Set pCounter = 0
    Set tStmt = ##class(%SQL.Statement).%New()
    Set tSC = tStmt.%PrepareClassQuery("Ens.Util.Statistics","EnumerateJobStatus")
    If $$$ISERR(tSC) Return tSC
    Set tRS = tStmt.%Execute(pItemName)
    While tRS.%Next() {
        If tRS.%Get("ActiveMessage") = "" {
            Set pCounter = pCounter + 1
        }
    }
    Return $$$OK
}

/// Override this method to process incoming data. Do not call SendRequestSync/Async() from outside this method (e.g. in a SOAP Service or a CSP page).
Method OnProcessInput(pInput As %RegisteredObject, Output pOutput As %RegisteredObject, ByRef pHint As %String) As %Status
{
    Set tSC = $$$OK
    Set ..PoolSizeChanged = 0
    Set tLastCantScaleUp = ..CantScaleUp
    Set ..TotalQueueSizeNotScaled = 0
    // Check Hosts
    For tSeq = 1 : 1 : ..HostsData {
        Set tData = ..HostsData(tSeq)
        // $List : 1-Item Name, 2-Item ID, 3-Initial PoolSize, 4-Actual PoolSize, 5-Last Scale Time, 6-Minimum Idle Jobs in the Period
        Set tItemName = $List(tData, 1)
        Set tPoolSize = $List(tData, 4)
        // $$$TRACE($List(tData,1)_"-"_$List(tData,2)_"-"_$List(tData,3)_"-"_$List(tData,4)_"-"_$List(tData,5)_"-"_$List(tData,6))
        // Get item queue size
        Set tQueueSize = ##class(Ens.Queue).GetCount(tItemName)
        // Check QueueSize - Scale UP
        If tQueueSize {
            If $Case(..ScaleUpWhen,
                     1   :   tQueueSize >= ..MaxQueueSize,
                     2   :   tQueueSize >= tPoolSize,
                         :   tQueueSize >= (tPoolSize\2)
                    ) {
                Set tSC = ..ScaleUp(tSeq, tQueueSize)
            }
        }
        // Check Idle Jobs - Scale DOWN
        ElseIf ..ScaleDownWhen > 1 {
            Set tSC = ..GetIdleJobsCount(tItemName, .tIdleJobs)
            If $$$ISERR(tSC) Return tSC
            If 'tIdleJobs {  // Start Wait Time Again
                Set $List(..HostsData(tSeq), 5, 6) = $ListBuild($Now(), tPoolSize)
            }
            ElseIf $Case(..ScaleDownWhen,
                         2   :   tIdleJobs >= ..MaxQueueSize,
                         3   :   tIdleJobs >= (tPoolSize\2),
                             :   tIdleJobs >= (tPoolSize\4)
                        ) {
                Set tSC = ..ScaleDown(tSeq, tIdleJobs)
            }
            ElseIf $List(tData, 6) > tIdleJobs {
                // Update minimum idle jobs
                Set $List(..HostsData(tSeq), 6) = tIdleJobs
            }
        }
        If $$$ISERR(tSC) Return tSC
    }
    // Need to update production?
    If ..PoolSizeChanged {
        Set tSC = ##class(Ens.Director).UpdateProduction()
        If $$$ISERR(tSC) Return tSC
    }
    // Call Methods to take action when can't scale up PoolSizes and
    // when it can
    If ..CantScaleUp = 1 {
        Return ..OnFailedToScaleUp(tLastCantScaleUp)
    }
	Return ..OnSucessToScaleUp(tLastCantScaleUp)
}

/// Failed to Scale UP 
Method OnFailedToScaleUp(pLastRun As %Boolean) As %Status
{
    $$$TRACE("Can't scale up PoolSize anymore")
    Set ^Scaler = ..TotalQueueSizeNotScaled
    Return $$$OK
}

/// Sucess to Scaled UP
Method OnSucessToScaleUp(pLastRun As %Boolean) As %Status
{
    Set ^Scaler = 0
    Return $$$OK
}

/// This user callback method is called via initConfig() from %OnNew() or in the case of SOAP Services from OnPreSOAP()
Method OnInit() As %Status
{
    Set tTime = $Now()
    Set tHosts = "," _ ..Hosts _ ","
    Set tProductionName = ##class(Ens.Director).GetActiveProductionName()
    Set tProduction = ##class(Ens.Config.Production).%OpenId(tProductionName, 0, .tSC)
    If $$$ISERR(tSC) Return tSC
    Set ..HostsData = 0
    For tI = 1 : 1 : tProduction.Items.Count() {
        Set tItem = tProduction.Items.GetAt(tI)
        Set tItemName = tItem.Name
        If ((..Hosts = "") && (tItem.BusinessType() = 1)) ||
           ((..Hosts '="") && (tHosts '[ ("," _ tItemName _ ","))) {
            Continue
        }
        Set tPoolSize = tItem.PoolSize
        Set ..HostsData = ..HostsData + 1
        // $List : 1-Item Name, 2-Item ID, 3-Initial PoolSize, 4-Actual PoolSize, 5-Last Scale Time, 6-Minimum Idle Jobs in the Period
        Set ..HostsData(..HostsData) = $ListBuild(tItemName, tItem.%Id(), tPoolSize, tPoolSize, tTime, tPoolSize)
    }
	Return $$$OK
}

/// This user callback method is called from %OnClose()
Method OnTearDown() As %Status
{
    // Revert to Initial values?
    If '..RevertToInitialAtEnd {
        Return $$$OK
    }
    // Revert hosts to the Initial PoolSize
    Set tChanged = 0
    For tI = 1 : 1 : ..HostsData {
        Set tData = ..HostsData(tI)
        // $List : 1-Item Name, 2-Item ID, 3-Initial PoolSize, 4-Actual PoolSize, 5-Last Scale Time, 6-Minimum Idle Jobs in the Period
        If $List(tData, 3) '= $List(tData, 4) {
            Set tSC = ..ChangePoolSize(tI, $List(tData, 3))
            If $$$ISERR(tSC) Return tSC
            Set tChanged = 1
        }
    }
	Return $$$OK
}

}
