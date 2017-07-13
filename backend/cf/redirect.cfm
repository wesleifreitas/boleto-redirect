<cfset vencimento		= -1>
<cfset valor			= -1>
<cfset cpfCnpjCliente	= -1>
<cfset codigoBarra		= -1>	

<cfset destination = getDirectoryFromPath(getCurrentTemplatePath()) & "\..\..\_server\redirect\upload">
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
    
    <cfset array 			= listToArray(texto, "CNPJ / CPF :", false, true)>
    <cfset vencimento 		= listToArray(array[2], "Pagador", false, true)>	
    <cfset vencimento 		= parseDateTime(replace(right(vencimento[1], 15), " ", "", "all"))>	

    <cfdump var="#vencimento#">
    
    <cfset valor 			= listToArray(array[2], "R $ ", false, true)>	
    <cfset valor 			= listToArray(valor[2], " ", false, true)>	
    <cfset valor 			= replace(replace(valor[1], ".", "", "all"), ", ", ".")>	
                    
    <cfset cpfCnpjCliente	= listToArray(array[4], " - Código", false, true)[1]>
    <cfset cpfCnpjCliente 	= replace(cpfCnpjCliente, "-", "", "all")>	
    <cfset cpfCnpjCliente 	= replace(cpfCnpjCliente, ".", "", "all")>	
    <cfset cpfCnpjCliente 	= replace(cpfCnpjCliente, "/", "", "all")>	
    <cfset cpfCnpjCliente 	= replace(cpfCnpjCliente, " ", "", "all")>

    <cfset codigoBarra		= listToArray(array[2], " CNPJ :", false, true)>
	<cfset codigoBarra		= mid(codigoBarra[2], 1,55)>

    <cfset array 			= listToArray(texto, "Pagador :", false, true)>
    <cfset nome 			= listToArray(array[2], " - CNPJ / CPF :", false, true)>	
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

<cfdump var="#info#">
