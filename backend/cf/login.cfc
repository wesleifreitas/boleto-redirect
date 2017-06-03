<cfcomponent rest="true" restPath="/">  

    <cfprocessingDirective pageencoding="utf-8">
    <cfset setEncoding("form","utf-8")> 
    
	<cfinclude template="util.cfm">

	<cffunction name="login" access="remote" returnType="String" httpMethod="POST" restPath="/login">
		<cfargument name="body" type="String">
        
		<cfset body = DeserializeJSON(arguments.body)>

        <cfif not IsDefined("body.setSession")>
            <cfset body.setSession = true>
        </cfif>

        <cfset response = structNew()>
		<cfset response["body"] = body>
        <cfset response["params"] = url>

        <cftry>
        
            <cfset myQuery = QueryNew("grupo_id, user_id, user_name, user_password", "Integer, VarChar, VarChar, VarChar")> 
            <cfset newRow = QueryAddRow(myQuery, 2)> 

            <cfset temp = QuerySetCell(myQuery, "grupo_id", "1", 1)> 
            <cfset temp = QuerySetCell(myQuery, "user_id", "1", 1)> 
            <cfset temp = QuerySetCell(myQuery, "user_name", "admin", 1)> 
            <cfset temp = QuerySetCell(myQuery, "user_password", hash("admin", "SHA-512"), 1)>

            <cfset temp = QuerySetCell(myQuery, "grupo_id", "1", 2)> 
            <cfset temp = QuerySetCell(myQuery, "user_id", "2", 2)> 
            <cfset temp = QuerySetCell(myQuery, "user_name", "user", 2)> 
            <cfset temp = QuerySetCell(myQuery, "user_password", hash("123", "SHA-512"), 2)>

            <cfquery dbtype="query" name="qLogin">  
                SELECT 
                    user_id
                    ,user_name
                    ,user_password 
                    ,grupo_id
                    ,1 AS per_id
                    ,'' AS perfil_grupo
                    ,'' AS perfil_grupo_query
                FROM 
                    myQuery 
                WHERE 
                    user_name = <cfqueryparam value="#body.username#" cfsqltype="cf_sql_varchar">
                AND user_password = <cfqueryparam value="#hash(body.password, 'SHA-512')#" cfsqltype="cf_sql_varchar">
            </cfquery>

            <cfif qLogin.recordCount GT 0>

                <!--- perfil_grupo - Start --->            
                <cfset qPerfilGrupo = QueryNew("grupo_id, grupo_nome", "Integer, VarChar")> 
                <cfset newRow = QueryAddRow(qPerfilGrupo, 1)> 

                <cfset temp = QuerySetCell(qPerfilGrupo, "grupo_id", "1", 1)> 
                <cfset temp = QuerySetCell(qPerfilGrupo, "grupo_nome", "px-project", 1)> 

                <cfset perfil_grupo = arrayNew(1)>
                <cfloop query="qPerfilGrupo">
                    <cfset arrayAppend(perfil_grupo, qPerfilGrupo.grupo_id)>
                </cfloop>		
                <cfset qLogin.perfil_grupo = arrayToList(perfil_grupo)>
                <cfset qLogin.perfil_grupo_query = QueryToArray(qPerfilGrupo)>	
                <!--- perfil_grupo - End --->

                <!--- acesso - Start --->
                <cfquery datasource="#application.datasource#" name="qAcesso">
                    SELECT
                        vw_menu.com_view as men_state
                    FROM
                        acesso AS acesso

                    INNER JOIN vw_menu AS vw_menu
                    ON vw_menu.men_id = acesso.men_id

                    WHERE
                        per_id = <cfqueryparam cfsqltype="cf_sql_bigint" value="#qLogin.per_id#">
                </cfquery>

                <cfset acesso = arrayNew(1)>
                <cfloop query="qAcesso">
                    <cfset arrayAppend(acesso, qAcesso.men_state)>
                </cfloop>	
                <!--- acesso - End ---> 

                <cfset response["success"] = true>
                <cfset response["message"] = "">
                
                <cfif body.setSession>
                    <cflock timeout="20" throwontimeout="No" type="EXCLUSIVE" scope="session">
                        <cfset session.authenticated = true>					
                        <cfset session.userId = qLogin.user_id>
                        <cfset session.userName = qLogin.user_name>   
                        <cfset session.perfilDeveloper = 1>    
                        <cfset session.grupoId = qLogin.grupo_id> 
                        <cfset session.grupoList = qLogin.perfil_grupo>
                        <cfset session.perfilId = qLogin.per_id>
                        <cfset session.acesso = arrayToList(acesso)>                           
                    </cflock>
                    <cfset response["session"] = session>
                </cfif>
            <cfelse>
                <cfset response["success"] = false>
                <cfset response["message"] = "Usuário e/ou senha incorreto(s)">
            </cfif>

            <cfset response["query"] = queryToArray(qLogin)>
            
        
            <cfreturn SerializeJSON(response)>

            <cfcatch>
				<cfset responseError(400, cfcatch.message)>
			</cfcatch>
		</cftry>
	</cffunction>
    
    <cffunction name = "authenticated" access ="remote" returntype ="String" httpMethod="GET" restPath="/login">

        <cfset response = structNew()>

        <cfif StructKeyExists(session, "authenticated") AND session.authenticated>	
            <cfset response["authenticated"] = true>
        <cfelse>    
            <cfset response["authenticated"] = false>
        </cfif>

        <cfreturn SerializeJSON(response)>
    </cffunction>


    <cffunction name = "logout" access ="remote" returntype ="String" httpMethod="POST" restPath="/logout">
        
        <cfset StructClear(session)>
        <cfset response = structNew()>
        <cfset response["sessionClear"] = true>

        <cfreturn SerializeJSON(response)>
    </cffunction>
</cfcomponent>