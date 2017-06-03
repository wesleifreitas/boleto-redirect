<cffunction 
    name       ="checkAuthentication" 
    access     ="public" 
    returntype ="void" 
    output     ="false">

    <cfset var authHeader = GetPageContext().getRequest().getHeader("Authorization") />
    <cfset var authString = "" />
    <cfsetting showDebugOutput="false" />

    <cfif IsDefined("authHeader") and authHeader NEQ "">
        <cfset authString = ToString(BinaryDecode(ListLast(authHeader, " "),"Base64")) />

        <cfset body = SerializeJSON({username: GetToken(authString, 1, ":"),
             password: GetToken(authString, 2, ":"),
             setSession: false})>

            <cfinvoke component="login" 
                method="login" 
                body="#body#"
                returnVariable="response">

            <cfset response = DeserializeJSON(response)>

            <cfif not response.success>
                <cfthrow errorcode="401" message="Usuário ou senha inválidos">
            </cfif>  

    <cfelseif not IsDefined("session.authenticated") OR not session.authenticated>
        <cfthrow errorcode="401" message="Usuário não autenticado ou sessão encerrada">
    </cfif>

</cffunction>
