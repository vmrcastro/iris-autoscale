Class autoscale.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="autoscale.Production" TestingEnabled="true" LogGeneralTraceEvents="false">
  <Description></Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="Test 1" Category="" ClassName="autoscale.BO.Test" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="Test 2" Category="" ClassName="autoscale.BO.Test" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="Test 3" Category="" ClassName="autoscale.BO.Test" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="request" Category="" ClassName="autoscale.BS.Request" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
</Production>
}

}
