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
        
            <cfquery datasource="#application.datasource#" name="qLogin">  
                SELECT 
                    usu_id
                    ,usu_nome
                    ,usu_senha 
                    ,per_developer
                    ,grupo_id
                    ,per_id
                    ,'' as perfil_grupo
                    ,'' as perfil_grupo_query
                FROM 
                    dbo.vw_usuario
                WHERE 
                    usu_login = <cfqueryparam value="#body.username#" cfsqltype="cf_sql_varchar">
                AND usu_senha = <cfqueryparam value="#hash(body.password, 'SHA-512')#" cfsqltype="cf_sql_varchar">
            </cfquery> 

            <cfif qLogin.recordCount GT 0>

                <!--- perfil_grupo - Start --->            
                <cfquery datasource="#application.datasource#" name="qPerfilGrupo">
                    SELECT
                        grupo_id                  
                    FROM
                        dbo.perfil_grupo
                    WHERE
                        grupo_id = <cfqueryparam cfsqltype="cf_sql_bigint" value="#qLogin.grupo_id#">
                    AND	per_id = <cfqueryparam cfsqltype="cf_sql_bigint" value="#qLogin.per_id#">
                    ORDER BY
                        grupo_id
                </cfquery>		
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
                        <cfset session.userId = qLogin.usu_id>
                        <cfset session.userName = qLogin.usu_nome>   
                        <cfset session.perfilDeveloper = qLogin.per_developer>    
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