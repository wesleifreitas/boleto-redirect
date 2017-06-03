<cfcomponent rest="true" restPath="redirect">  
	<cfinclude template="security.cfm">
	<cfinclude template="util.cfm">

	<cffunction name="redirectUpload" access="remote" returntype="String" httpmethod="POST" restPath="/upload"> 

		<!--- <cfset checkAuthentication()> --->
 
		<cfset destination = getDirectoryFromPath(getCurrentTemplatePath()) & "/../../_server/redirect/upload">
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
					
				<cfset vencimento 		= replace(mid(array[2],17,15)," ","","all")>	
				
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
					CODIGOBARRA: codigoBarra
				})> 
               
			</cfloop>

			<cfdirectory action="delete" directory="#destination#" recurse="true"/>		

			<!--- <cfdump var="#info#"> --->
			<cfset response["query"] = info>
			
			<cfcatch>
				<cfset responseError(400, cfcatch.message)>
			</cfcatch>
		</cftry>
		
		<cfreturn SerializeJSON(response)>
    </cffunction>

</cfcomponent>