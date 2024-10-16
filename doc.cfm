<cfparam name="url.name" default="cfquery">
<cfset request.unsafe_name = url.name>
<cfset url.name = ReReplace(url.name, "[^a-zA-Z0-9_-]", "", "ALL")>
<cfif url.name IS "index">
	<cfset data = {name="CFDocs", description="Ultra Fast CFML / ColdFusion Documentation", type="index"}>
<cfelseif FileExists(ExpandPath("./guides/en/#url.name#.md")) OR url.name is "how-to-contribute">
	<cfset request.ogname = url.name>
	<cfset request.hasExamples = true>
	<cfset request.canonical_url = "https://cfdocs.org/#lcase(url.name)#">
	<cftry>
		<!--- convert md to HTML --->
		<cfset flexmark = new lib.Processor() >
		<cfset path = (url.name is "how-to-contribute" ? 'CONTRIBUTING' : './guides/en/#url.name#')>
		<cfset data = flexmark.toHTML(FileRead(ExpandPath("#path#.md")))>
		<cfset request.gitFilePath = "/tree/master/guides/en/"&(url.name is "how-to-contribute" ? 'CONTRIBUTING' : url.name)&".md">
		<cfcatch>
			<cfset data = "Error processing markdown: #encodeForHTML(cfcatch.message)# #encodeForHTML(cfcatch.detail)#">
			<cfset data &= "Make sure you have installed the flexmark jar file in the lib directory used to process the markup files.">
			<cfset applicationStop()>
		</cfcatch>
	</cftry>
<cfelseif FileExists(ExpandPath("./data/en/#url.name#.json"))>
	<cfset data = DeserializeJSON( FileRead(ExpandPath("./data/en/#url.name#.json")))>
	<cfset request.ogname = url.name>
	<cfset request.gitFilePath = "/edit/master/data/en/" & url.name & ".json">
	<cfset request.canonical_url = "https://cfdocs.org/#lcase(url.name)#">
<cfelse>
	<cfset url.name = ReReplace(url.name, "[^a-zA-Z0-9_-]", "", "ALL")>
	<cfif reFind("[A-Z]", url.name)>
		<cfif FileExists(ExpandPath("./data/en/#lCase(url.name)#.json")) OR FileExists(ExpandPath("./guides/en/#lCase(url.name)#.md"))>
			<cflocation url="https://cfdocs.org/#lcase(url.name)#" addtoken="false" statuscode="301">
		</cfif>
	</cfif>
	<cfset possible = []>
	<cfloop array="#application.index.functions#" index="i">
		<cfif Len(url.name) LTE 3>
			<cfif FindNoCase(url.name, i)>
				<cfset ArrayAppend(possible, i)>
			</cfif>
		<cfelseif FindNoCase(url.name, i) OR FindNoCase(i, url.name)>
			<cfset ArrayAppend(possible, i)>
		<cfelseif LCase(Left(url.name, 3)) IS LCase(Left(i, 3)) OR LCase(Right(url.name, 3)) IS LCase(Right(i, 3))>
			<cfset ArrayAppend(possible, i)>
		</cfif>
	</cfloop>
	<cfset data = {
		name = url.name,
		description = "Sorry we don't have any docs matching that name. If we should have a doc for this, please log an <a href=""https://github.com/foundeo/cfdocs/issues/new"">Issue</a> so we can look into it. You can easily access functions and tags using an url like <a href=""https://cfdocs.org/hash"">cfdocs.org/hash</a>. Just hit <code>/tag-name</code> or <code>/function-name</code> or use the search box above.",
		type = "404",
		related = possible
	}>
	<cfheader statuscode="404" statustext="Not Found">
</cfif>
<cfif request.keyExists("canonical_url") AND request.unsafe_name IS NOT url.name>
	<!--- there was a stripped char in url, redirect --->
	<cflocation url="#request.canonical_url#" addtoken="false" statuscode="301">
</cfif>
<cfif isStruct(data)>
	<cfset request.title = data.name>
	<cfif structKeyExists(data, "examples") AND arrayLen(data.examples) GT 0>
		<cfset request.title = request.title & " Code Examples and">
	</cfif>
	<cfif data.keyExists("description")>
		<cfset request.description = data.description>
	</cfif>
	<cfinclude template="views/doc.cfm">
<cfelse>
	<cfinclude template="views/markdown.cfm">
</cfif>
