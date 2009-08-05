<cfsetting enablecfoutputonly="true" />

<cfparam name="ATTRIBUTES.array" type="array" />
<cfparam name="ATTRIBUTES.element" type="variablename" default="element" />
<cfparam name="ATTRIBUTES.cleanup" type="boolean" default="true" />



<cfif THISTAG.ExecutionMode is "start">
		<cfif ArrayIsEmpty(ATTRIBUTES.array)>
			<cfexit method="exittag" />
		<cfif>
		<cfset cycles = StructNew() />
		<!--- find the attributes in the cycle namespace --->
		<cfloop collection="#ATTRIBUTES#" item="attr">
			<cfif Left(attr, Len("cycle:")) IS "cycle:">
				<cfset cycles[ReplaceNoCase(attr,"cycle:", "","one")] = ListToArray(ATTRIBUTES[attr]) />
			</cfif>
		</cfloop>
		<cfset index = 0 />
		<cfset setCallerScope() />
	<cfelse>
		<cfset index = IncrementValue(index) />
		<cfif index GTE ArrayLen(ATTRIBUTES.array)>
			<cfif ATTRIBUTES.cleanup>
				<cfset cleanup() />
			</cfif>
			<cfexit method="exittag" />
		</cfif>
		<cfset setCallerScope() />
		<cfif index LT ArrayLen(ATTRIBUTES.array)>
			<cfexit method="loop" />
		</cfif>
</cfif>

<cfsetting enablecfoutputonly="false" />

<cffunction name="setCallerScope" output="false">
		<cfset CALLER[ATTRIBUTES.element] = ATTRIBUTES.array[index + 1] />	
		<cfloop collection="#cycles#" item="cycle">
			<cfset CALLER[cycle] = cycles[cycle][index MOD ArrayLen(cycles[cycle]) + 1] />
		</cfloop>		
		<cfif StructKeyExists(ATTRIBUTES, "index")>
			<cfset CALLER[ATTRIBUTES.index] = index+1 />
		</cfif>				
</cffunction>

<cffunction name="cleanup" output="false">
	<cfscript>
		StructDelete(CALLER, ATTRIBUTES.element);
		if (StructKeyExists(ATTRIBUTES, "index"))
			StructDelete(CALLER, ATTRIBUTES.index);
		for (cycle in cycles) 
			StructDelete(CALLER, cycle);
	</cfscript>
</cffunction>