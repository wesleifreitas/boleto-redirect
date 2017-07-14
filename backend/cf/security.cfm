<cffunction 
    name       ="checkAuthentication" 
    access     ="public" 
    returntype ="void" 
    output     ="false">

    <cfargument name="state" type="array" required="false" hint="acesso">

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

<!--- http://www.bennadel.com/blog/488-generating-random-passwords-in-coldfusion-based-on-sets-of-valid-characters.htm --->
<cffunction name="randPassword" access="private" returntype="String">
    
    <!---
    We have to start out be defining what the sets of valid
    character data are. While this might not look elegant,
    notice that it gives a LOT of power over what the sets
    are without writing a whole lot of code or "condition"
    statements.
    --->

    <!--- Set up available lower case values. --->
    <cfset strLowerCaseAlpha = "abcdefghijklmnopqrstuvwxyz" />

    <!---
        Set up available upper case values. In this instance, we
        want the upper case to correspond to the lower case, so
        we are leveraging that character set.
    --->
    <cfset strUpperCaseAlpha = UCase( strLowerCaseAlpha ) />

    <!--- Set up available numbers. --->
    <cfset strNumbers = "0123456789" />

    <!--- Set up additional valid password chars. --->
    <cfset strOtherChars = "~!@##$%^&*" />

    <!---
        When selecting random value, we want to be able to easily
        choose from the entire set. To this effect, we are going
        to concatenate all the previous valid character sets.
    --->
    <cfset strAllValidChars = (
        strLowerCaseAlpha &
        strUpperCaseAlpha &
        strNumbers &
        strOtherChars
        ) />


    <!---
        Create an array to contain the password ( think of a
        string as an array of character).
    --->
    <cfset arrPassword = ArrayNew( 1 ) />


    <!---
        When creating a password, there are certain rules that we
        need to follow (as deemed by the business logic). That is,
        the password must:
        - must be exactly 8 characters in length
        - must have at least 1 number
        - must have at least 1 uppercase letter
        - must have at least 1 lower case letter
    --->


    <!--- Select the random number from our number set. --->
    <cfset arrPassword[ 1 ] = Mid(
        strNumbers,
        RandRange( 1, Len( strNumbers ) ),
        1
        ) />

    <!--- Select the random letter from our lower case set. --->
    <cfset arrPassword[ 2 ] = Mid(
        strLowerCaseAlpha,
        RandRange( 1, Len( strLowerCaseAlpha ) ),
        1
        ) />

    <!--- Select the random letter from our upper case set. --->
    <cfset arrPassword[ 3 ] = Mid(
        strUpperCaseAlpha,
        RandRange( 1, Len( strUpperCaseAlpha ) ),
        1
        ) />


    <!---
        ASSERT: At this time, we have satisfied the character
        requirements of the password, but NOT the length
        requirement. In order to do that, we must add more
        random characters to make up a proper length.
    --->


    <!--- Create rest of the password. --->
    <cfloop
        index="intChar"
        from="#(ArrayLen( arrPassword ) + 1)#"
        to="8"
        step="1">

        <!---
            Pick random value. For this character, we can choose
            from the entire set of valid characters.
        --->
        <cfset arrPassword[ intChar ] = Mid(
            strAllValidChars,
            RandRange( 1, Len( strAllValidChars ) ),
            1
            ) />

    </cfloop>


    <!---
        Now, we have an array that has the proper number of
        characters and fits the business rules. But, we don't
        always want the first three characters to be of the
        same order (by type). Therefore, let's use the Java
        Collections utility class to shuffle this array into
        a "random" order.
        If you are not comfortable using the Java class, you
        can create your own shuffle algorithm.
    --->
    <cfset CreateObject( "java", "java.util.Collections" ).Shuffle(
        arrPassword
        ) />


    <!---
        We now have a randomly shuffled array. Now, we just need
        to join all the characters into a single string. We can
        do this by converting the array to a list and then just
        providing no delimiters (empty string delimiter).
    --->
    <cfset strPassword = ArrayToList(
        arrPassword,
        ""
        ) />

    <cfreturn replaceList(strPassword, "^,~", "@,$")>

</cffunction>
