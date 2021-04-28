Class autoscale.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="autoscale.Production" TestingEnabled="true" LogGeneralTraceEvents="false">
  <Description></Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="AutoScale" Category="" ClassName="autoscale.BS.PoolSizeScaler" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="ScaleDownWaitTime">300</Setting>
  </Item>
  <Item Name="Teste 1" Category="" ClassName="autoscale.BO.Teste" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="Teste 2" Category="" ClassName="autoscale.BO.Teste" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="Teste 3" Category="" ClassName="autoscale.BO.Teste" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="Teste" Category="" ClassName="autoscale.BP.Teste" PoolSize="4" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
  </Item>
  <Item Name="start-test" Category="" ClassName="autoscale.BS.StartTest" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="stop-test" Category="" ClassName="autoscale.BS.StopTest" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="request" Category="" ClassName="autoscale.BS.Request" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
</Production>
}

}
