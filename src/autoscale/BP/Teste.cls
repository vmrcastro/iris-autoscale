/// 
Class autoscale.BP.Teste Extends Ens.BusinessProcessBPL
{

/// BPL Definition
XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript' request='Ens.Request' response='Ens.Response' height='2000' width='2000' >
<sequence xend='200' yend='350' >
<while name='Até ^Stop' condition='&apos;$Data(^Stop)&amp;&amp;&apos;##class(Ens.Job).ShouldBeQuiescent()&amp;&amp;&apos;##class(Ens.Job).ShouldTerminate()' xpos='200' ypos='250' xend='200' yend='650' >
<call name='Teste1' target='Teste 1' async='1' xpos='200' ypos='250' >
<request type='Ens.Request' />
</call>
<call name='Teste2' target='Teste 2' async='1' xpos='200' ypos='350' >
<request type='Ens.Request' />
</call>
<call name='Teste3' target='Teste 3' async='1' xpos='200' ypos='450' >
<request type='Ens.Request' />
</call>
<code name='Hang 1' xpos='200' ypos='550' >
<![CDATA[ Hang 1]]>
</code>
</while>
</sequence>
</process>
}

Storage Default
{
<Type>%Storage.Persistent</Type>
}

}
