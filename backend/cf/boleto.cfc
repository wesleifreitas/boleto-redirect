<cfcomponent rest="true" restPath="/boleto">  
	<cfinclude template="security.cfm">
	<cfinclude template="util.cfm">

	<cffunction name="get" access="remote" returntype="String" httpmethod="GET">

		<cfset checkAuthentication()>
        
		<cfset response = structNew()>
		
		<cfset response["params"] = url>

		<cftry>

			<cfif session.perfilPassageiro EQ 1>
				<cfset url.cpf = session.userCpf>
			</cfif>

			<cfquery datasource="#application.datasource#" name="queryCount">
                SELECT
                    COUNT(*) AS COUNT
                FROM
                    dbo.boleto
                WHERE
                    1 = 1
				AND bol_status > 0

				<cfif IsDefined("url.cpf") AND url.cpf NEQ "">
                    AND	bol_cpf = <cfqueryparam value = "#url.cpf#" CFSQLType = "CF_SQL_VARCHAR">
                </cfif>
                <cfif IsDefined("url.nome") AND url.nome NEQ "">
                    AND	bol_nome COLLATE Latin1_general_CI_AI LIKE <cfqueryparam value = "%#url.nome#%" CFSQLType = "CF_SQL_VARCHAR">
                </cfif>
                <cfif IsDefined("url.ano") AND IsNumeric(url.ano)>
                    AND	YEAR(bol_vencimento) = <cfqueryparam value = "#url.ano#" CFSQLType = "CF_SQL_NUMERIC">
                </cfif>
                <cfif IsDefined("url.mes") AND url.mes GT 0>
                    AND	MONTH(bol_vencimento) = <cfqueryparam value = "#url.mes + 1#" CFSQLType = "CF_SQL_NUMERIC">
                </cfif>
                
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
					,bol_valor
					,bol_status
					,bol_email_enviado
                    ,boleto.usu_id
					,usu_email
                FROM
                    dbo.boleto AS boleto

				LEFT OUTER JOIN dbo.usuario AS usuario
				ON usuario.usu_id = boleto.usu_id

                WHERE
                    1 = 1
				AND bol_status > 0

				<cfif IsDefined("url.cpf") AND url.cpf NEQ "">
                    AND	bol_cpf = <cfqueryparam value = "#url.cpf#" CFSQLType = "CF_SQL_VARCHAR">
                </cfif>
                <cfif IsDefined("url.nome") AND url.nome NEQ "">
                    AND	bol_nome COLLATE Latin1_general_CI_AI LIKE <cfqueryparam value = "%#url.nome#%" CFSQLType = "CF_SQL_VARCHAR">
                </cfif>
                <cfif IsDefined("url.ano") AND IsNumeric(url.ano)>
                    AND	YEAR(bol_vencimento) = <cfqueryparam value = "#url.ano#" CFSQLType = "CF_SQL_NUMERIC">
                </cfif>
                <cfif IsDefined("url.mes") AND url.mes GT 0>
                    AND	MONTH(bol_vencimento) = <cfqueryparam value = "#url.mes + 1#" CFSQLType = "CF_SQL_NUMERIC">
                </cfif>
                
                ORDER BY
                    bol_vencimento DESC
                    ,bol_nome ASC
                
                <!--- Paginação --->
                OFFSET #URL.page * URL.limit - URL.limit# ROWS
                FETCH NEXT #URL.limit# ROWS ONLY;
            </cfquery>
			
			<cfset response["page"] = URL.page>	
			<cfset response["limit"] = URL.limit>	
			<cfset response["recordCount"] = queryCount.COUNT>
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

	<cffunction name="pdf" access="remote" returnType="String" httpMethod="POST" restpath="/pdf">		
		<cfargument name="body" type="String">

		<cfset checkAuthentication(state = ['boleto'])>
		
		<cfset body = DeserializeJSON(arguments.body)>
		
		<cfset response = structNew()>
		<cfset response["arguments"] = arguments>

		<cftry>

			<cfquery datasource="#application.datasource#" name="query">
                SELECT
                    bol_url
                FROM
                    dbo.boleto AS boleto
                WHERE
					bol_id = <cfqueryparam value = "#body.BOL_ID#" CFSQLType = "CF_SQL_INTEGER">
            </cfquery>
						
			<cffile  
					action="readBinary"  
					file="#query.bol_url#" 
					variable="binary">

			<cfset response["pdf"] = toBase64(binary)>		
			
			<cfcatch>				
				<cfset responseError(400, "PDF não disponível")>				
			</cfcatch>	
		</cftry>
		
		<cfreturn SerializeJSON(response)>

	</cffunction>

	<cffunction name="setUserEmail" access="remote" returnType="String" httpMethod="PUT" restpath="/user-email">		
		<cfargument name="body" type="String">

		<cfset checkAuthentication(state = ['boleto'])>
		
		<cfset body = DeserializeJSON(arguments.body)>
		
		<cfset response = structNew()>
		<cfset response["arguments"] = arguments>

		<cftry>
			<cfquery datasource="#application.datasource#">
				UPDATE 
					dbo.usuario  
				SET 
					usu_email = <cfqueryparam value = "#body.email#" CFSQLType = "CF_SQL_VARCHAR">
				WHERE 
					usu_id = <cfqueryparam value = "#body.userId#" CFSQLType = "CF_SQL_NUMERIC">
				;
				UPDATE 
					dbo.boleto  
				SET 
					bol_email = <cfqueryparam value = "#body.email#" CFSQLType = "CF_SQL_VARCHAR">
				WHERE 
					bol_id = <cfqueryparam value = "#body.boletoId#" CFSQLType = "CF_SQL_NUMERIC">
			</cfquery>

			<cfset sendUserEmail(SerializeJSON(body))>
			
			<cfcatch>				
				<cfset responseError(400, cfcatch.message)>				
			</cfcatch>	
		</cftry>
		
		<cfreturn SerializeJSON(response)>

	</cffunction>

	<cffunction name="sendUserEmail" access="remote" returnType="String" httpMethod="POST" restpath="/user-email">		
		<cfargument name="body" type="String">

		<cfset checkAuthentication(state = ['boleto'])>
		
		<cfset body = DeserializeJSON(arguments.body)>
		
		<cfset response = structNew()>
		<cfset response["arguments"] = arguments>

		<cftry>
			<cftransaction>	
				<cfquery name="qSMTP" datasource="#application.datasource#">
					SELECT 
						smtp_server
						,smtp_username
						,smtp_password
						,smtp_port
					FROM 
						dbo.smtp
				</cfquery>	

				<cfquery datasource="#application.datasource#" name="query">
					SELECT
						boleto.bol_email
						,boleto.bol_url
						,usuario.usu_nome
					FROM
						dbo.boleto AS boleto
					
					INNER JOIN dbo.usuario AS usuario
					ON usuario.usu_id = boleto.usu_id

					WHERE 
						bol_id = <cfqueryparam value = "#body.boletoId#" CFSQLType = "CF_SQL_NUMERIC">

				</cfquery>
			</cftransaction>

			<cfquery datasource="#application.datasource#">
				UPDATE 
					dbo.boleto  
				SET 
					bol_email_enviado = 1
				WHERE 
					bol_id = <cfqueryparam value = "#body.boletoId#" CFSQLType = "CF_SQL_NUMERIC">
			</cfquery>

			<cfmail from="#qSMTP.smtp_username#"
				type="html"
				to="#query.bol_email#"		
				subject="[px-project] Boleto"
				server="#qSMTP.smtp_server#"
				username="#qSMTP.smtp_username#" 
				password="#qSMTP.smtp_password#"
				port="#qSMTP.smtp_port#">

				<cfmailparam file="#query.bol_url#">
				
				<cfoutput>								
					<p><b>Este é um e-mail automático, não responda.</b></p>								
					<p>
						Olá <b>#query.usu_nome#.</b>
					</p>
					<p>
						Em anexo seu boleto referente ao serviço de fretamento Expresso Mauá.
					</p>
					<p>
						Confira seu nome e CPF no boleto.
					</p>
					<p><b>Este é um e-mail automático, não responda.</b></p>
				</cfoutput>	
			</cfmail>
			
			<cfcatch>				
				<cfset responseError(400, cfcatch.message)>				
			</cfcatch>	
		</cftry>
		
		<cfreturn SerializeJSON(response)>

	</cffunction>
</cfcomponent>