<cfcomponent rest="true" restPath="/boleto">  
	<cfinclude template="security.cfm">
	<cfinclude template="util.cfm">

	<cffunction name="get" access="remote" returntype="String" httpmethod="GET">

		<cfset checkAuthentication()>
        
		<cfset response = structNew()>
		
		<cfset response["params"] = url>

		<cftry>

			<cfquery datasource="#application.datasource#" name="queryCount">
                SELECT
                    COUNT(*) AS COUNT
                FROM
                    dbo.boleto
                WHERE
                    1 = 1
                
            </cfquery>

            <cfquery datasource="#application.datasource#" name="query">
                SELECT
                    bol_id
                    ,bol_cpf
                    ,bol_nome
                    ,bol_email
                    ,bol_codigo_barra
                    ,bol_data
                    ,bol_vencimento
                    ,usu_id
                FROM
                    dbo.boleto
                WHERE
                    1 = 1
                

                ORDER BY
                    bol_vencimento DESC
                    ,bol_nome ASC
                
                <!--- Paginação --->
                OFFSET #URL.page * URL.limit - URL.limit# ROWS
                FETCH NEXT #URL.limit# ROWS ONLY;
            </cfquery>
			
			<cfset response["page"] = URL.page>	
			<cfset response["limit"] = URL.limit>	
			<cfset response["recordCount"] = query.recordCount>
			<cfset response["query"] = queryToArray(query)>

			<cfcatch>
				<cfset responseError(400, cfcatch.message)>
			</cfcatch>
		</cftry>
		
		<cfreturn SerializeJSON(response)>
    </cffunction>

	<cffunction name="getById" access="remote" returntype="String" httpmethod="GET" restpath="/{id}"> 

		<cfargument name="id" restargsource="Path" type="numeric"/>
		
		<cfset checkAuthentication()>

		<cfset response = structNew()>
		<cfset response["arguments"] = arguments>
		<cfset response["params"] = url>

		<cftry>

			<cfset rows = 100>
			<cfset myQuery = QueryNew("_id, nome, cpf, data, bateria, status", "bigint, varchar, varchar, date, integer, integer")> 
			<cfset newRow = QueryAddRow(MyQuery, rows)> 
			
			<cfloop from="1" to="#rows#" index="i">
				
				<cfset temp = QuerySetCell(myQuery, "_id", i, i)> 
				<cfset temp = QuerySetCell(myQuery, "nome", "Weslei Freitas", i)> 
				<cfset temp = QuerySetCell(myQuery, "cpf", '39145592845', i)>
				<cfset temp = QuerySetCell(myQuery, "data", now(), i)>
				<cfset temp = QuerySetCell(myQuery, "bateria", 1, i)>
				<cfset temp = QuerySetCell(myQuery, "status", 1, i)>

			</cfloop>

			<cfquery dbtype="query" name="query">  
				SELECT 
					_id
					,nome
					,cpf
					,data
					,bateria
					,status 
				FROM 
					myQuery
				WHERE
					_id = <cfqueryPARAM value="#arguments.id#" CFSQLType='CF_SQL_INTEGER'>  
			</cfquery>
			
			<cfset response["query"] = queryToArray(query)>

			<cfreturn SerializeJSON(response)>

			<cfcatch>
				<cfset responseError(400, cfcatch.message)>
			</cfcatch>
		</cftry>

    </cffunction>

	<cffunction name="create" access="remote" returnType="String" httpMethod="POST">
		<cfargument name="body" type="String">

		<cfset checkAuthentication()>

		<cfset body = DeserializeJSON(arguments.body)>
		
		<cfset response = structNew()>
		<cfset response["arguments"] = arguments>

		<cftry>
			<!--- create --->
			<cfset response["success"] = true>
			<cfset response["message"] = 'Ação realizada com sucesso!'>

			<cfcatch>
				<cfset responseError(400, cfcatch.message)>
			</cfcatch>	
		</cftry>
		
		<cfreturn SerializeJSON(response)>
	</cffunction>

	<cffunction name="update" access="remote" returnType="String" httpMethod="PUT" restPath="/{id}">
		<cfargument name="id" restargsource="Path" type="numeric"/>
		<cfargument name="body" type="String">

		<cfset checkAuthentication()>

		<cfset body = DeserializeJSON(arguments.body)>
		
		<cfset response = structNew()>
		<cfset response["arguments"] = arguments>
	
		<cftry>
			<!--- update --->
			<cfset response["success"] = true>
			<cfset response["message"] = 'Ação realizada com sucesso!'>

			<cfcatch>
				<cfset responseError(400, cfcatch.message)>	
			</cfcatch>	
		</cftry>
		
		<cfreturn SerializeJSON(response)>
	</cffunction>

	<cffunction name="remove" access="remote" returnType="String" httpMethod="DELETE">
		<cfargument name="body" type="String">

		<cfset checkAuthentication()>

		<cfset body = DeserializeJSON(arguments.body)>
		
		<cfset response = structNew()>
		<cfset response["arguments"] = arguments>
	
		<cftry>
			<!--- remove --->
			<cfset response["success"] = true>			

			<cfcatch>
				<cfset responseError(400, cfcatch.message)>
			</cfcatch>	
		</cftry>
		
		<cfreturn SerializeJSON(response)>
	</cffunction>

	<cffunction name="removeById" access="remote" returnType="String" httpMethod="DELETE" restPath="/{id}">
		<cfargument name="id" restargsource="Path" type="numeric"/>

		<cfset checkAuthentication()>

		<cfset response = structNew()>
		<cfset response["arguments"] = arguments>
		
		<cftry>
			<!--- remove by id --->
			<cfset response["success"] = true>
			<cfset response["message"] = 'Ação realizada com sucesso!'>

			<cfcatch>
				<cfset responseError(400, cfcatch.message)>
			</cfcatch>	
		</cftry>
		
		<cfreturn SerializeJSON(response)>
	</cffunction>

</cfcomponent>