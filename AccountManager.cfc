<cfcomponent>

    <cfscript>
        private boolean function isSignedIn() {
            if (structKeyExists(Session, Username) &&
                structKeyExists(Session, UserID)) {
                    return true;
                }
            
            return false;

        }
    </cfscript>

    <cffunction  name="userExists" access="private">
        <cfargument  name="username" required="yes" type="string">

        <cfquery name="getUser">
            SELECT * FROM USERS
            WHERE USERNAME = <cfqueryparam value=#username# cfsqltype="cf_sql_varchar">;
        </cfquery>

        <cfif getUser.recordCount>
            <cfreturn true>
        </cfif>

        <cfreturn false>

    </cffunction>

    <cffunction  name="registerNewUser" access="remote" returnformat="plain">

        <cfif userExists(Form.Username)>
            <cfreturn "This name is already in use. Try another.">
        </cfif>

        <cfset passHASH = hash(Form.Password, "SHA-512")>
        <cfset passSALT = hash(generateSecretKey("AES"), "SHA-512")>

        <cfset newHASH = hash(passHASH & passSALT, "SHA-512")>

        <cfquery>
            INSERT INTO USERS (USERNAME, HASH, SALT)
            VALUES (
                <cfqueryparam value=#Form.Username# cfsqltype="cf_sql_varchar">,
                <cfqueryparam value=#newHASH# cfsqltype="cf_sql_char">,
                <cfqueryparam value=#passSALT# cfsqltype="cf_sql_char">
            );
        </cfquery>

        <cfreturn "Success! You can now sign in.">

    </cffunction>

    <cffunction  name="signIn" access="remote" returnformat="plain">

        <cfquery name="userData">
            SELECT * FROM USERS 
            WHERE USERNAME = <cfqueryparam value=#Form.Username# cfsqltype="cf_sql_varchar">
        </cfquery>

        <cfif !userData.recordCount>
            <cfreturn "false">
        </cfif>

        <cfset formHASH = hash(Form.Password, "SHA-512")>
        <cfset passHASH = hash(formHASH & userData.SALT, "SHA-512")>

        <cfif passHASH !== userData.HASH>
            <cfreturn "false">
        </cfif>

        <cfset Session.Username = userData.USERNAME>
        <cfset Session.UserID = userData.ID>

        <cfreturn "true">

    </cffunction>

    <!--- return HTML for user's account page --->
    <cffunction  name="getAccount" access="remote" returnformat="plain">

        <cfsavecontent  variable="accountPage">
            <cfinclude  template="partials/account.cfm">
        </cfsavecontent>

        <cfreturn accountPage>

    </cffunction>

    <!--- Change user password, return true/false on success/failure--->
    <cffunction  name="setPassword" access="remote" returnformat="plain">

        <cfquery name="userData">
            SELECT * FROM USERS 
            WHERE ID = #Session.UserID#;
        </cfquery>

        <cfset oldPass = hash(hash(Form.old, "SHA-512") & userData.SALT,"SHA-512")>

        <cfif oldPass == userData.HASH>
            <cfset newSalt = hash(generateSecretKey("AES"), "SHA-512")>
            <cfset newPass = hash(Form.new, "SHA-512")>

            <cfquery>
                UPDATE USERS 
                SET HASH = <cfqueryparam value=#hash(newPass & newSalt, "SHA-512")# cfsqltype="cf_sql_char">, 
                    SALT = <cfqueryparam value=#newSalt# cfsqltype="cf_sql_char">
                WHERE USERID = <cfqueryparam value=#Session.UserID# cfsqltype="cf_sql_integer">;
            </cfquery>

            <cfreturn "true">
        <cfelse>
            <cfreturn "false">
        </cfif>

    </cffunction>

    <!--- Delete all user files and related DB entries --->
    <cffunction  name="deleteAccount" access="remote">

        <cfinvoke component="FileManager" method="deleteAllUserFiles">

        <cfset path = #GetDirectoryFromPath(GetCurrentTemplatePath())# & "uploads\#Session.Username#">
        <cfdirectory  directory="#path#" action="delete">

        <cfquery>
            DELETE FROM USERS 
            WHERE ID = #Session.UserID#;
        </cfquery>

        <cflog  text="User #Session.Username# DELETED!">

        <cfset StructClear(Session)>

    </cffunction>

    <!--- logout --->
    <cffunction  name="signOut" access="remote">
        <cfset structClear(Session)>
    </cffunction>

</cfcomponent>