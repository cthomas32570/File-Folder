<cfcomponent displayname="FileManager">

<!--- Return true if user has access to the file requested --->
<cffunction  name="validateUser" access="private" returnType="boolean">
    <cfargument  name="fileNo" required="yes" type="numeric">
    <cfargument  name="userNo" required="yes" type="numeric">

    <cfif NOT 
        structKeyExists(Session, "user") &&
        structKeyExists(Session, "pass") &&
        Session.UID == userNo
    >
        <cflocation  url="home.cfm" statuscode="502">
    </cfif>

    <cfquery name="validUser">
        SELECT UserID FROM files 
        WHERE FileID = <cfqueryparam value=#fileNo# cfsqltype="cf_sql_integer"> 
        AND UserID = <cfqueryparam value=#userNo# cfsqltype="cf_sql_integer">;
    </cfquery>

    <cfif validUser.recordCount>
        <cfreturn true>
    </cfif>
        <cfreturn false>
</cffunction>

<!--- Return true if user is the one who uploaded the file --->
<cffunction  name="getIsFileOwner" access="private" returnType="boolean">
    <cfargument  name="userName" required="yes" type="string">
    <cfargument  name="filePath" required="yes" type="string">

    <cfif Find("\uploads\#userName#", filePath) NEQ 0>
        <cfreturn true>
    </cfif>

    <cfreturn false>
</cffunction>

<!--- Return a string not already in a ShareKey field in the file table --->
<cffunction  name="makeUniqueShareKey" access="private" returnType="string">
    <cfset output = generateSecretKey("AES")>

    <cfquery name="keyExists">
        SELECT ShareKey FROM files 
        WHERE ShareKey = <cfqueryparam value=#output# cfsqltype="cf_sql_char">;
    </cfquery>

    <cfif keyExists.recordCount>
        <cfreturn makeUniqueShareKey()> <!--- Try again if the key already exists --->
    </cfif>

    <cfreturn output>
</cffunction>

<!--- Format input bytes into human readable string --->
<cfscript>

private String function bytesToSize(required Numeric bytes) {
    if (bytes == 1) { return "1 Byte" };

    sizes = ["Bytes", "KB", "MB", "GB"];
    i = Floor(Log(bytes) / Log(1024));
    return DecimalFormat(bytes / (1024^i)) & " " & sizes[i+1];
}

</cfscript>

<!--- Upload files to server, create DB references --->
<cffunction  name="uploadFiles" access="remote">
    <cfif NOT 
        structKeyExists(Session, "user") &&
        structKeyExists(Session, "pass")
    >
        <cflocation  url="home.cfm" statuscode="302">
    </cfif>

    <cfset uploadPath = #GetDirectoryFromPath(GetCurrentTemplatePath())# & "uploads\#Session.user#\">
    <cfif !directoryExists(uploadPath)>
        <cfdirectory action="create" directory=#uploadPath#>
    </cfif>

    <cffile  action="uploadAll" destination=#uploadPath# result="fileList">

    <cfloop array="#fileList#" item="file">
        <cfquery>
            INSERT INTO files (UserID, FileName, FileSize, FilePath)
            VALUES (
                <cfqueryparam value=#Session.UID# cfsqltype="cf_sql_integer">,
                <cfqueryparam value=#file.clientFile# cfsqltype="cf_sql_varchar">,
                <cfqueryparam value=#bytesToSize(file.fileSize)# cfsqltype="cf_sql_varchar">,
                <cfqueryparam value=#uploadPath & file.serverFile# cfsqltype="cf_sql_varchar">
            );
        </cfquery>
    </cfloop>

</cffunction>

<!--- Return HTML code for rendering the list of a user's files --->
<cffunction  name="getFileTable" access="remote" returnformat="plain">

    <cfif NOT 
        structKeyExists(Session, "user") &&
        structKeyExists(Session, "pass")
    >
        <cflocation  url="home.cfm" statuscode="302">
    </cfif>

    <cfsavecontent  variable="fileTable">
        <cfinclude  template="partials/fileTable.cfm">
    </cfsavecontent>

    <cfreturn fileTable>

</cffunction>

<!--- Return HTML code for rendering list of files shared with user --->
<cffunction  name="getSharedTable" access="remote" returnformat="plain">

    <cfif NOT 
        structKeyExists(Session, "user") &&
        structKeyExists(Session, "pass")
    >
        <cflocation  url="home.cfm" statuscode="302">
    </cfif>

    <cfsavecontent  variable="sharedTable">
        <cfinclude  template="partials/sharedTable.cfm">
    </cfsavecontent>

    <cfreturn sharedTable>

</cffunction>

<!--- Send requested file as response --->
<cffunction  name="downloadFile" access="remote">
    <cfargument  name="fileNo" required="yes" type="numeric">
    <cfargument  name="userNo" required="yes" type="numeric">

    <cfif !validateUser(fileNo, userNo)>
        <cflocation  url="home.cfm" statuscode="302">
    </cfif>

    <cfquery name="fileData">
        SELECT * FROM files 
        WHERE FileID = <cfqueryparam value=#fileNo# cfsqltype="cf_sql_integer">;
    </cfquery>
    
    <cfheader name="Content-Disposition" value="attachment; filename=#fileData.FileName#">
    <cfcontent type=#FileGetMimeType(fileData.FilePath, false)# file=#fileData.FilePath#> 
</cffunction>

<!--- Assign shareKey to file and send back as plaintext response --->
<cffunction  name="shareFile" access="remote" returnformat="plain">
    <cfargument  name="fileNo" required="yes" type="numeric">
    <cfargument  name="userNo" required="yes" type="numeric">

    <cfif !validateUser(fileNo, userNo)>
        <cflocation  url="home.cfm" statuscode="302">
    </cfif>

    <cfset shareKey = makeUniqueShareKey()>

    <cfquery>
        UPDATE files 
        SET ShareKey = <cfqueryparam value=#shareKey# cfsqltype="cf_sql_char">
        WHERE FileID = <cfqueryparam value=#fileNo# cfsqltype="cf_sql_integer">;
    </cfquery>

    <cfreturn shareKey>

</cffunction>

<!--- Give user access to file matching the sharekey --->
<cffunction  name="accessFile" access="remote">

    <cfif NOT 
        structKeyExists(Session, "user")&&
        structKeyExists(Session, "pass")
    >
        <cflocation  url="home.cfm" statuscode="302">
    </cfif>

    <cfset req = getHTTPRequestData()>

    <cfquery name="alreadyAccessed">
        SELECT FileID FROM files 
        WHERE  UserID = #Session.UID# AND ShareKey = <cfqueryparam value=#req.content# cfsqltype="cf_sql_char">
        LIMIT 1;
    </cfquery>

    <cfif !alreadyAccessed.recordcount>
        <cfquery name="fileData">
            SELECT * FROM files 
            WHERE ShareKey = <cfqueryparam value=#req.content# cfsqltype="cf_sql_char">
            LIMIT 1;
        </cfquery>

        <cfquery>
            INSERT INTO files (UserID, FileName, FileSize, FilePath, ShareKey)
            VALUES (
                <cfqueryparam value=#Session.UID# cfsqltype="cf_sql_integer">,
                <cfqueryparam value=#fileData.FileName# cfsqltype="cf_sql_varchar">,
                <cfqueryparam value=#fileData.FileSize# cfsqltype="cf_sql_varchar">,
                <cfqueryparam value=#fileData.FilePath# cfsqltype="cf_sql_varchar">,
                <cfqueryparam value=#fileData.ShareKey# cfsqltype="cf_sql_varchar">
            );
        </cfquery>

    </cfif>
</cffunction>

<!--- Remove file DB reference, and if user uploaded it, the file also --->
<cffunction  name="deleteFile" access="remote">
    <cfargument  name="fileNo" required="yes" type="numeric">
    <cfargument  name="userNo" required="yes" type="numeric">

    <cfif !validateUser(fileNo, userNo)>
        <cflocation  url="home.cfm" statuscode="302">
    </cfif>

    <cfquery name="getUserName">
        SELECT Username FROM users 
        WHERE ID = <cfqueryparam value=#userNo# cfsqltype="cf_sql_integer">;
    </cfquery>

    <cfquery name="fileData">
        SELECT * FROM files 
        WHERE FileID = <cfqueryparam value=#fileNo# cfsqltype="cf_sql_integer">
    </cfquery>

    <cfif getIsFileOwner(getUserName.Username, fileData.FilePath)>

        <cffile  action="delete" file=#fileData.FilePath#>

        <cfif len(fileData.ShareKey)>
            <cfquery>
                DELETE FROM files 
                WHERE ShareKey = <cfqueryparam value=#fileData.ShareKey# cfsqltype="cf_sql_char">;
            </cfquery>
        <cfelse>
            <cfquery>
                DELETE FROM files 
                WHERE FileID = <cfqueryparam value=#fileNo# cfsqltype="cf_sql_integer">;
            </cfquery>
        </cfif>

    <cfelse>

        <cfquery>
            DELETE FROM files 
            WHERE FileID = <cfqueryparam value=#fileNo# cfsqltype="cf_sql_integer">;
        </cfquery>
    
    </cfif>

</cffunction>

<!--- Remove all files from a user's uploads directory and their DB references --->
<cffunction  name="deleteAllUserFiles" >

    <cfif NOT 
        structKeyExists(Session, "user") &&
        structKeyExists(Session, "pass")
    >
        <cflocation  url="home.cfm" statuscode="302">
    </cfif>

    <cfquery name = "shared">
        SELECT * FROM files 
        WHERE UserID = #Session.UID# AND ShareKey IS NOT NULL;
    </cfquery>

    <cfloop query="shared">
        <cfif getIsFileOwner(Session.user, shared.FilePath)>
            <cffile  action="delete" file=#shared.FilePath#>
            <cfquery>
                DELETE FROM files 
                WHERE ShareKey = <cfqueryparam value=#shared.ShareKey# cfsqltype="cf_sql_char">;
            </cfquery>
        </cfif>
    </cfloop>

    <cfquery name="userFiles">
        SELECT FilePath FROM files 
        WHERE UserID = #Session.UID#
    </cfquery>

    <cfloop query="userFiles">
        <cffile  action="delete" file=#userFiles.FilePath#>
    </cfloop>

    <cfquery>
        DELETE FROM files 
        WHERE UserID = #Session.UID#
    </cfquery>

    <cflog  text="Delete all user files(#Session.user#): Success!">

</cffunction>
    
</cfcomponent>