<cfcomponent rest="true" restPath="redirect">  
	<cfinclude template="security.cfm">
	<cfinclude template="util.cfm">

	<cffunction name="redirectUpload" access="remote" returntype="String" httpmethod="POST" restPath="/upload"> 
	
		<cfset checkAuthentication()>
	
		<cftry>
			<cfset SEND_EMAIL = true>
			<cfset email_enviado = 0>

			<cfset destination = getDirectoryFromPath(getCurrentTemplatePath()) & 
				"/../../_server/redirect/upload/#LSDateFormat(now() , "YYYYMM")#/#CreateUUID()#">
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
				<cfset vencimento 		= replace(right(vencimento[1], 15), " ", "", "all")>
    			<cfset vencimento 		= CreateDate(mid(vencimento,7 ,4), mid(vencimento,4 ,2), mid(vencimento,1 ,2))>
				
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
				
				<cfset ArrayAppend(info, {
					CPF: cpfCnpjCliente,
					NOME: nome,
					EMAIL: "",
					CODIGOBARRA: codigoBarra,
					VALOR: valor
				})> 

				<cfquery datasource="#application.datasource#" name="qUsuario">
					SELECT
						usu_id
						,usu_email
						,usu_nome
					FROM
						dbo.usuario
					WHERE
						usu_cpf = <cfqueryparam value = "#cpfCnpjCliente#" CFSQLType = "CF_SQL_VARCHAR">
				</cfquery>
				
				<cfif qUsuario.recordCount GT 0>
					
					<cfif SEND_EMAIL AND qUsuario.usu_email NEQ "">
						<cfmail from="#qSMTP.smtp_username#"
							type="html"
							to="#qUsuario.usu_email#"		
							cc="#form.cc#"			
							subject="[px-project] Boleto"
							server="#qSMTP.smtp_server#"
							username="#qSMTP.smtp_username#" 
							password="#qSMTP.smtp_password#"
							port="#qSMTP.smtp_port#">

							<cfmailparam file="#diretorio.Directory#/#diretorio.Name#">
							
							<cfoutput>								
								<p><b>Este é um e-mail automático, não responda.</b></p>								
								<p>
									<b>Olá #qUsuario.usu_nome#.</b>
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
						<cfset email_enviado = 1>
					</cfif>

					<cftransaction>
						<cfquery datasource="#application.datasource#">
							UPDATE
								dbo.boleto
							SET
								bol_status = 0
							WHERE
								bol_cpf = <cfqueryparam value = "#cpfCnpjCliente#" CFSQLType = "CF_SQL_VARCHAR">
							AND bol_vencimento = <cfqueryparam value = "#vencimento#" CFSQLType = "CF_SQL_DATE">
						</cfquery>

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
								,bol_valor
								,bol_url
								,bol_status
								,bol_email_enviado
								,usu_id							
							) 
							VALUES (							
								<cfqueryparam value = "#cpfCnpjCliente#" CFSQLType = "CF_SQL_VARCHAR">
								,<cfqueryparam value = "#nome#" CFSQLType = "CF_SQL_VARCHAR">
								,<cfqueryparam value = "#qUsuario.usu_email#" CFSQLType = "CF_SQL_VARCHAR">
								,<cfqueryparam value = "#codigoBarra#" CFSQLType = "CF_SQL_VARCHAR">
								,GETDATE()
								,<cfqueryparam value = "#vencimento#" CFSQLType = "CF_SQL_DATE">
								,<cfqueryparam value = "#valor#" CFSQLType = "CF_SQL_FLOAT">
								,<cfqueryparam value = "#diretorio.Directory#/#diretorio.Name#" CFSQLType = "CF_SQL_VARCHAR">
								,1
								,#email_enviado#
								,<cfqueryparam value = "#qUsuario.usu_id#" CFSQLType = "CF_SQL_INTEGER">							
							)
						</cfquery>
					</cftransaction>
				<cfelse>

					<cfset login = listToArray(nome, " ", false, true)>	
					<cfset login = login[1] & "." & login[ArrayLen(login)]>	
					<cfset login = lcase(login)>	

					<cftransaction>
						<cfquery datasource="#application.datasource#" result="rUsuario">
							INSERT INTO 
							dbo.usuario
							(
								usu_ativo
								,per_id
								,usu_login
								,usu_senha
								,usu_nome
								,usu_email
								,usu_cpf
								,usu_mudarSenha
							) 
							VALUES (
								1
								,4 <!--- HARD CODE --->
								,<cfqueryparam value = "#login#" CFSQLType = "CF_SQL_VARCHAR">
								,<cfqueryparam value="#hash(mid(cpfCnpjCliente, 1, 3), 'SHA-512')#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value = "#nome#" CFSQLType = "CF_SQL_VARCHAR">
								,''
								,<cfqueryparam value = "#cpfCnpjCliente#" CFSQLType = "CF_SQL_VARCHAR">
								,1
							);
						</cfquery>

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
								,bol_valor
								,bol_url
								,bol_status
								,bol_email_enviado
								,usu_id
							) 
							VALUES (							
								<cfqueryparam value = "#cpfCnpjCliente#" CFSQLType = "CF_SQL_VARCHAR">
								,<cfqueryparam value = "#nome#" CFSQLType = "CF_SQL_VARCHAR">
								,<cfqueryparam value = "[E-MAIL NÃO REGISTRADO!]" CFSQLType = "CF_SQL_VARCHAR">
								,<cfqueryparam value = "#codigoBarra#" CFSQLType = "CF_SQL_VARCHAR">
								,GETDATE()
								,<cfqueryparam value = "#vencimento#" CFSQLType = "CF_SQL_DATE">
								,<cfqueryparam value = "#valor#" CFSQLType = "CF_SQL_FLOAT">
								,<cfqueryparam value = "#diretorio.Directory#/#diretorio.Name#" CFSQLType = "CF_SQL_VARCHAR">
								,1
								,#email_enviado#						
								,<cfqueryparam value = "#rUsuario.IDENTITYCOL#" CFSQLType = "CF_SQL_INTEGER">
							)
						</cfquery>
					</cftransaction>
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
				<cfset vencimento 		= replace(right(vencimento[1], 15), " ", "", "all")>
    			<cfset vencimento 		= CreateDate(mid(vencimento,7 ,4), mid(vencimento,4 ,2), mid(vencimento,1 ,2))>
				
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