<cfsetting enablecfoutputonly="true" />

<cfparam name="ATTRIBUTES.collection" type="array" />
<cfparam name="ATTRIBUTES.key" type="variablename" default="k">
<cfparam name="ATTRIBUTES.value" type="variablename" default="v" />
<cfparam name="ATTRIBUTES.cleanup" type="boolean" default="true" />

<cfif THISTAG.ExecutionMode is "start">
		<cfset cycles = StructNew() />
		<!--- find the attributes in the cycle namespace and placing them in a struct where the cycle variable is the key --->
		<cfloop collection="#ATTRIBUTES#" item="attr">
			<cfif Left(attr, Len("cycle:")) IS "cycle:">
				<cfset cycles[ReplaceNoCase(attr,"cycle:", "","one")] = ListToArray(ATTRIBUTES[attr]) />
			</cfif>
		</cfloop>
		<cfset index = 0 />
		<cfset setCallerScope() />
	<cfelse>
		<cfset index = IncrementValue(index) />
		<cfif index GTE ArrayLen(ATTRIBUTES.collection)>
			<cfif ATTRIBUTES.cleanup>
				<cfset cleanup() />
			</cfif>
			<cfexit method="exittag" />
		</cfif>
		<cfset setCallerScope() />
		<cfif index LT ArrayLen(ATTRIBUTES.collection)>
			<cfexit method="loop" />
		</cfif>
</cfif>

<cfsetting enablecfoutputonly="false" />

<cffunction name="setCallerScope" output="false">
	<cfif IsArray(ATTRIBUTES.collection)>
			<cfset CALLER[ATTRIBUTES.key] = index+1 />
			<cfset CALLER[ATTRIBUTES.value] = ATTRIBUTES.collection[index + 1] />
		<cfelseif IsStruct(ATTRIBUTES.collection)>
			<cfset CALLER[ATTRIBUTES.key] = ListGetAt(StructKeyList(ATTRIBUTES.collection), index+1)>
			<cfset CALLER[ATTRIBUTES.value] = ATTRIBUTES.collection[CALLER[ATTRIBUTES.key]] />		
	</cfif>


	<cfloop collection="#cycles#" item="cycle">
		<cfset CALLER[cycle] = cycles[cycle][index MOD ArrayLen(cycles[cycle]) + 1] />
	</cfloop>		
</cffunction>

<cffunction name="cleanup" output="false">
	<cfscript>
		StructDelete(CALLER, ATTRIBUTES.key);
		StructDelete(CALLER, ATTRIBUTES.value);
		for (cycle in cycles) 
			StructDelete(CALLER, cycle);
	</cfscript>
</cffunction>