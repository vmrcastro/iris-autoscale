Class autoscale.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="autoscale.Production" TestingEnabled="true" LogGeneralTraceEvents="false">
  <Description></Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="AutoScale" Category="" ClassName="autoscale.BS.PoolSizeScaler" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
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
</Production>
}

}
