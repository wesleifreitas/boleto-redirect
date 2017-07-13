<cfcomponent rest="true" restPath="redirect">  
	<cfinclude template="security.cfm">
	<cfinclude template="util.cfm">

	<cffunction name="redirectUpload" access="remote" returntype="String" httpmethod="POST" restPath="/upload"> 
	
		<cfset checkAuthentication()>

		<cftry>

			<cfset destination = getDirectoryFromPath(getCurrentTemplatePath()) & "/../../_server/redirect/upload/#CreateUUID()#">
			<cfset log = destination & '/log'>
			<cfset now = LSDateFormat(now(), 'YYYYMM') & '_' & LSTimeFormat(now(), 'HHmmss')>
			<cfif not directoryExists(destination)>
				<cfdirectory action="create" directory="#destination#" />		
			</cfif>
			<cfif not directoryExists(log)>
				<cfdirectory action="create" directory="#log#" />		
			</cfif>

			<cffile action="upload" 
				filefield="file" 
				destination="#destination#" 
				nameconflict="overwrite"
				accept="*" />
			
			<cfset info = ArrayNew(1)>

			<cfdirectory 	action="list"
							directory="#destination#"
							name="diretorio"
							type="file">

			 <cfquery name="qSMTP" datasource="#application.datasource#">
				SELECT 
					smtp_server
					,smtp_username
					,smtp_password
					,smtp_port
				FROM 
					dbo.smtp
			</cfquery>	

			<cfloop query="diretorio">
				<cfpdf 	action="extracttext"
					type="string"
					source="#diretorio.Directory#/#diretorio.Name#"
					name="texto"				
					>

				<cfset array 			= listToArray(texto,"CNPJ / CPF :",false,true)>
					
				<cfset vencimento 		= listToArray(array[2], "Pagador", false, true)>
				<cfset vencimento 		= parseDateTime(replace(right(vencimento[1], 15), " ", "", "all"))>		
				
				<cfset valor 			= listToArray(array[2],"R $ ",false,true)>	
				<cfset valor 			= listToArray(valor[2]," ",false,true)>	
				<cfset valor 			= replace(replace(valor[1],".","","all"),",",".")>	
								
				<cfset cpfCnpjCliente	= listToArray(array[4]," - Código",false,true)[1]>
				<cfset cpfCnpjCliente 	= replace(cpfCnpjCliente,"-","","all")>	
				<cfset cpfCnpjCliente 	= replace(cpfCnpjCliente,".","","all")>	
				<cfset cpfCnpjCliente 	= replace(cpfCnpjCliente,"/","","all")>	
				<cfset cpfCnpjCliente 	= replace(cpfCnpjCliente," ","","all")>
				<cfset cpfCnpjCliente 	= listToArray(cpfCnpjCliente,"Código:",false,true)[1]>

				<cfset codigoBarra		= listToArray(array[2]," CNPJ :",false,true)>
				<cfset codigoBarra		= mid(codigoBarra[2],1,55)>

				<cfset array 			= listToArray(texto,"Pagador :",false,true)>
				<cfset nome 			= listToArray(array[2]," - CNPJ / CPF :",false,true)>	
				<cfset nome 			= nome[1]>	

				<cfset email = listToArray(nome, " ", false, true)>	
				<cfset email = email[1] & "." & email[ArrayLen(email)] & "@gmail.com">	

				<cfset ArrayAppend(info, {
					CPF: cpfCnpjCliente,
					NOME: nome,
					EMAIL: "",
					CODIGOBARRA: codigoBarra
				})> 

				<cfquery datasource="#application.datasource#" name="qUsuario">
					SELECT
						usu_id
						,usu_email
					FROM
						dbo.usuario
					WHERE
						usu_cpf = <cfqueryparam value = "#cpfCnpjCliente#" CFSQLType = "CF_SQL_VARCHAR">
				</cfquery>
				
				<cfif qUsuario.recordCount GT 0>
					
					 <cfmail from="#qSMTP.smtp_username#"
                        type="html"
                        to="#qUsuario.usu_email#"					
                        subject="[px-project] Boleto"
                        server="#qSMTP.smtp_server#"
                        username="#qSMTP.smtp_username#" 
                        password="#qSMTP.smtp_password#"
                        port="#qSMTP.smtp_port#">

							<cfmailparam file="#diretorio.Directory#/#diretorio.Name#">
						
						<cfoutput>								
							<p><b>Este é um e-mail automático, por favor não responda.</b></p>
							<br />
							[FUNCIONALIDADE EM DESENVOLVIMENTO]
						</cfoutput>	
					</cfmail>

					<cfquery datasource="#application.datasource#">
						INSERT INTO 
							dbo.boleto
						(							
							bol_cpf
							,bol_nome
							,bol_email
							,bol_codigo_barra
							,bol_data
							,bol_vencimento
							,bol_url
							,usu_id
						) 
						VALUES (							
							<cfqueryparam value = "#cpfCnpjCliente#" CFSQLType = "CF_SQL_VARCHAR">
							,<cfqueryparam value = "#nome#" CFSQLType = "CF_SQL_VARCHAR">
							,<cfqueryparam value = "#qUsuario.usu_email#" CFSQLType = "CF_SQL_VARCHAR">
							,<cfqueryparam value = "#codigoBarra#" CFSQLType = "CF_SQL_VARCHAR">
							,GETDATE()
							,<cfqueryparam value = "#vencimento#" CFSQLType = "CF_SQL_DATE">
							,<cfqueryparam value = "#diretorio.Directory#/#diretorio.Name#" CFSQLType = "CF_SQL_VARCHAR">
							,<cfqueryparam value = "#qUsuario.usu_id#" CFSQLType = "CF_SQL_INTEGER">
						)
					</cfquery>
				<cfelse>
					<cfquery datasource="#application.datasource#">
						INSERT INTO 
							dbo.boleto
						(							
							bol_cpf
							,bol_nome
							,bol_email
							,bol_codigo_barra
							,bol_data
							,bol_vencimento
							,bol_url
							,usu_id
						) 
						VALUES (							
							<cfqueryparam value = "#cpfCnpjCliente#" CFSQLType = "CF_SQL_VARCHAR">
							,<cfqueryparam value = "#nome#" CFSQLType = "CF_SQL_VARCHAR">
							,<cfqueryparam value = "[e-mail não encontrado!]" CFSQLType = "CF_SQL_VARCHAR">
							,<cfqueryparam value = "#codigoBarra#" CFSQLType = "CF_SQL_VARCHAR">
							,GETDATE()
							,<cfqueryparam value = "#vencimento#" CFSQLType = "CF_SQL_DATE">
							,<cfqueryparam value = "#diretorio.Directory#/#diretorio.Name#" CFSQLType = "CF_SQL_VARCHAR">
							,<cfqueryparam value = "0" CFSQLType = "CF_SQL_INTEGER">
						)
					</cfquery>
				</cfif>
			</cfloop>

			<!--- <cfdirectory action="delete" directory="#destination#" recurse="true"/> --->
			<cfcatch>
				<cfdocument format="PDF"
					filename="#destination#/error.pdf"
					overwrite="true">

					<cfdump var="#cfcatch#">

				</cfdocument>
				
				<cfabort>
			</cfcatch>
		
		</cftry>

		<cfreturn >
    </cffunction>

	<cffunction name="get" access="remote" returntype="String" httpmethod="GET">

		<!--- <cfset checkAuthentication()> --->
        
		<cfset response = structNew()>		
		<cfset response["params"] = url>

		<cftry>
			<cfset vencimento		= -1>
			<cfset valor			= -1>
			<cfset cpfCnpjCliente	= -1>
			<cfset codigoBarra		= -1>	

			<cfset destination = getDirectoryFromPath(getCurrentTemplatePath()) & "/../../_server/redirect/upload">
			<cfdirectory 	action="list"
							directory="#destination#"
							name="diretorio"
							type="file">

			<!--- <cfdump var="#diretorio#"> --->

			<cfset info = ArrayNew(1)>

			<cfloop query="diretorio">
				<cfpdf 	action="extracttext"
					type="string"
					source="#diretorio.Directory#/#diretorio.Name#"
					name="texto"				
					>

				<cfset array 			= listToArray(texto,"CNPJ / CPF :",false,true)>
					
				<cfset vencimento 		= listToArray(array[2], "Pagador", false, true)>
				<cfset vencimento 		= parseDateTime(replace(right(vencimento[1], 15), " ", "", "all"))>		
				
				<cfset valor 			= listToArray(array[2],"R $ ",false,true)>	
				<cfset valor 			= listToArray(valor[2]," ",false,true)>	
				<cfset valor 			= replace(replace(valor[1],".","","all"),",",".")>	
								
				<cfset cpfCnpjCliente	= listToArray(array[4]," - Código",false,true)[1]>
				<cfset cpfCnpjCliente 	= replace(cpfCnpjCliente,"-","","all")>	
				<cfset cpfCnpjCliente 	= replace(cpfCnpjCliente,".","","all")>	
				<cfset cpfCnpjCliente 	= replace(cpfCnpjCliente,"/","","all")>	
				<cfset cpfCnpjCliente 	= replace(cpfCnpjCliente," ","","all")>
				<cfset cpfCnpjCliente 	= listToArray(cpfCnpjCliente,"Código:",false,true)[1]>

				<cfset codigoBarra		= listToArray(array[2]," CNPJ :",false,true)>
				<cfset codigoBarra		= mid(codigoBarra[2],1,55)>

				<cfset array 			= listToArray(texto,"Pagador :",false,true)>
				<cfset nome 			= listToArray(array[2]," - CNPJ / CPF :",false,true)>	
				<cfset nome 			= nome[1]>	

				<cfset email = listToArray(nome, " ", false, true)>	
				<cfset email = email[1] & "." & email[ArrayLen(email)] & "@gmail.com">	

				<cfset ArrayAppend(info, {
					CPF: cpfCnpjCliente,
					NOME: nome,
					EMAIL: lcase(email),
					CODIGOBARRA: codigoBarra,
					VENCIMENTO: vencimento
				})> 
               
			</cfloop>

			<!--- <cfdirectory action="delete" directory="#destination#" recurse="true"/> --->

			<!--- <cfdump var="#info#"> --->
			<cfset response["query"] = info>
			
			<cfcatch>
				<cfset responseError(400, cfcatch.message)>
			</cfcatch>
		</cftry>
		
		<cfreturn SerializeJSON(response)>
    </cffunction>

</cfcomponent>