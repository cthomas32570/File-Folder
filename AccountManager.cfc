<cfcomponent>

    <!--- return HTML for user's account page --->
    <cffunction  name="getAccount" access="remote" returnformat="plain">
        <cfif NOT 
            structKeyExists(Session, "user") &&
            structKeyExists(Session, "pass")
        >
            <cflocation  url="home.cfm" statuscode="302">
        </cfif>

        <cfsavecontent  variable="accountPage">
            <cfinclude  template="partials/account.cfm">
        </cfsavecontent>

        <cfreturn accountPage>

    </cffunction>

    <!--- Change user password, return true/false on success/failure--->
    <cffunction  name="setPassword" access="remote" returnformat="plain">
        
        <cfif NOT 
            structKeyExists(Session, "user") &&
            structKeyExists(Session, "pass")
        >
            <cfreturn "false">
        </cfif>

        <cfquery name="userData">
            SELECT * FROM users 
            WHERE ID = #Session.UID#;
        </cfquery>

        <cfset oldPass = hash(hash(Form.old, "SHA-512") & userData.Salt,"SHA-512")>

        <cfif oldPass == userData.PasswordHash>
            <cfset newSalt = hash(generateSecretKey("AES"), "SHA-512")>
            <cfset newPass = hash(Form.new, "SHA-512")>

            <cfquery>
                UPDATE users 
                SET PasswordHash = <cfqueryparam value=#hash(newPass & newSalt, "SHA-512")# cfsqltype="cf_sql_char">, 
                    Salt = <cfqueryparam value=#newSalt# cfsqltype="cf_sql_char">
                WHERE PasswordHash = <cfqueryparam value=#oldPass# cfsqltype="cf_sql_char">;
            </cfquery>

            <cfreturn "true">
        <cfelse>
            <cfreturn "false">
        </cfif>

    </cffunction>

    <!--- Delete all user files and related DB entries --->
    <cffunction  name="deleteAccount" access="remote">
        <cfif NOT 
            structKeyExists(Session, "user") &&
            structKeyExists(Session, "pass")
        >
            <cfabort>
        </cfif>

        <cfinvoke component="FileManager" method="deleteAllUserFiles">

        <cfset path = #GetDirectoryFromPath(GetCurrentTemplatePath())# & "uploads\#Session.user#">
        <cfdirectory  directory="#path#" action="delete">

        <cfquery>
            DELETE FROM users 
            WHERE ID = #Session.UID#;
        </cfquery>

        <cflog  text="User #Session.user# DELETED!">

        <cfset StructClear(Session)>

    </cffunction>

    <!--- logout --->
    <cffunction  name="logOut" access="remote">
        <cfset structClear(Session)>
    </cffunction>

</cfcomponent>