<cfcomponent displayname="FileManager">

<cfscript>

    // Format input bytes into human readable string
    private String function bytesToSize(required Numeric bytes) {
        if (bytes == 1) { return "1 Byte" };
    
        sizes = ["Bytes", "KB", "MB", "GB"];
        i = Floor(Log(bytes) / Log(1024));
        return DecimalFormat(bytes / (1024^i)) & " " & sizes[i+1];
    }

    // Return true if user is the one who uploaded the file
    private Boolean function isFileOwner(required String filePath) {
        if (Find("\uploads\#Session.Username#", filePath) != 0) {
            return true;
        }

        return false;

    }
    
</cfscript>

<!--- Return a string not already in a ShareKey field in the file table --->
<cffunction  name="makeUniqueShareKey" access="private" returnType="string">
    <cfset output = generateSecretKey("AES")>

    <cfquery name="keyExists">
        SELECT SHAREKEY FROM FILES
        WHERE SHAREKEY = <cfqueryparam value=#output# cfsqltype="cf_sql_char">;
    </cfquery>

    <cfif keyExists.recordCount>
        <cfreturn makeUniqueShareKey()> <!--- Try again if the key already exists --->
    </cfif>

    <cfreturn output>
</cffunction>

<!--- Upload files to server, create DB references --->
<cffunction  name="uploadFiles" access="remote">

    <cfset uploadPath = #GetDirectoryFromPath(GetCurrentTemplatePath())# & "uploads\#Session.Username#\">
    <cfif !directoryExists(uploadPath)>
        <cfdirectory action="create" directory=#uploadPath#>
    </cfif>

    <cffile  action="uploadAll" destination=#uploadPath# result="fileList">

    <cfloop array="#fileList#" item="file">
        <cfquery>
            INSERT INTO FILES (USERID, FILENAME, FILESIZE, FILEPATH)
            VALUES (
                <cfqueryparam value=#Session.UserID# cfsqltype="cf_sql_integer">,
                <cfqueryparam value=#file.clientFile# cfsqltype="cf_sql_varchar">,
                <cfqueryparam value=#bytesToSize(file.fileSize)# cfsqltype="cf_sql_varchar">,
                <cfqueryparam value=#uploadPath & file.serverFile# cfsqltype="cf_sql_varchar">
            );
        </cfquery>
    </cfloop>

</cffunction>

<!--- Return HTML code for rendering the list of a user's files --->
<cffunction  name="getFileTable" access="remote" returnformat="plain">

    <cfsavecontent  variable="fileTable">
        <cfinclude  template="partials/filetable.cfm">
    </cfsavecontent>

    <cfreturn fileTable>

</cffunction>

<!--- Return HTML code for rendering list of files shared with user --->
<cffunction  name="getSharedTable" access="remote" returnformat="plain">

    <cfsavecontent  variable="sharedTable">
        <cfinclude  template="partials/sharedTable.cfm">
    </cfsavecontent>

    <cfreturn sharedTable>

</cffunction>

<!--- Send requested file as response --->
<cffunction  name="downloadFile" access="remote">
    <cfargument  name="fileNo" required="yes" type="numeric">

    <cfquery name="fileData">
        SELECT * FROM FILES
        WHERE FILEID = <cfqueryparam value=#fileNo# cfsqltype="cf_sql_integer">;
    </cfquery>

    <cfif fileData.USERID === Session.UserID>
        <cfheader name="Content-Disposition" value="attachment; filename=#fileData.FILENAME#">
        <cfcontent type=#FileGetMimeType(fileData.FILEPATH, false)# file=#fileData.FILEPATH#> 
    </cfif>
    
</cffunction>

<!--- Assign shareKey to file and send back as plaintext response --->
<cffunction  name="shareFile" access="remote" returnformat="plain">
    <cfargument  name="fileNo" required="yes" type="numeric">

    <cfset shareKey = makeUniqueShareKey()>

    <cfquery>
        UPDATE FILES
        SET SHAREKEY = <cfqueryparam value=#shareKey# cfsqltype="cf_sql_char">
        WHERE FILEID = <cfqueryparam value=#fileNo# cfsqltype="cf_sql_integer">;
    </cfquery>

    <cfreturn shareKey>

</cffunction>

<!--- Give user access to file matching the sharekey --->
<cffunction  name="accessFile" access="remote">

    <cfset req = getHTTPRequestData()>

    <cfquery name="alreadyAccessed">
        SELECT FILEID FROM FILES
        WHERE  USERID = #Session.UserID# AND SHAREKEY = <cfqueryparam value=#req.content# cfsqltype="cf_sql_char">
        LIMIT 1;
    </cfquery>

    <cfif !alreadyAccessed.recordcount>
        <cfquery name="fileData">
            SELECT * FROM FILES
            WHERE SHAREKEY = <cfqueryparam value=#req.content# cfsqltype="cf_sql_char">
            LIMIT 1;
        </cfquery>

        <cfquery>
            INSERT INTO FILES (USERID, FILENAME, FILESIZE, FILEPATH, SHAREKEY)
            VALUES (
                <cfqueryparam value=#Session.UserID# cfsqltype="cf_sql_integer">,
                <cfqueryparam value=#fileData.FILENAME# cfsqltype="cf_sql_varchar">,
                <cfqueryparam value=#fileData.FILESIZE# cfsqltype="cf_sql_varchar">,
                <cfqueryparam value=#fileData.FILEPATH# cfsqltype="cf_sql_varchar">,
                <cfqueryparam value=#fileData.SHAREKEY# cfsqltype="cf_sql_varchar">
            );
        </cfquery>

    </cfif>
</cffunction>

<!--- Remove file DB reference, and if user uploaded it, the file itself --->
<cffunction  name="deleteFile" access="remote">
    <cfargument  name="fileNo" required="yes" type="numeric">

    <cfquery name="fileData">
        SELECT * FROM FILES
        WHERE FILEID = <cfqueryparam value=#fileNo# cfsqltype="cf_sql_integer">
    </cfquery>

    <cfif isFileOwner(fileData.FILEPATH)>

        <cffile  action="delete" file=#fileData.FILEPATH#>

        <cfif len(fileData.ShareKey)>
            <cfquery>
                DELETE FROM FILES
                WHERE SHAREKEY = <cfqueryparam value=#fileData.SHAREKEY# cfsqltype="cf_sql_char">;
            </cfquery>
        <cfelse>
            <cfquery>
                DELETE FROM FILES 
                WHERE FILEID = <cfqueryparam value=#fileNo# cfsqltype="cf_sql_integer">;
            </cfquery>
        </cfif>

    <cfelse>

        <cfquery>
            DELETE FROM FILES
            WHERE FILEID = <cfqueryparam value=#fileNo# cfsqltype="cf_sql_integer">;
        </cfquery>
    
    </cfif>

</cffunction>

<!--- Remove all files from a user's uploads directory and their DB references --->
<cffunction  name="deleteAllUserFiles" >

    <cfquery name = "shared">
        SELECT * FROM FILES 
        WHERE USERID = #Session.UserID# AND SHAREKEY IS NOT NULL;
    </cfquery>
    
    <cfif isFileOwner(shared.FILEPATH)>
        <cffile  action="delete" file=#shared.FILEPATH#>
    </cfif>

    <cfloop query="shared">
            <cfquery>
                DELETE FROM FILES 
                WHERE SHAREKEY = <cfqueryparam value=#shared.SHAREKEY# cfsqltype="cf_sql_char">;
            </cfquery>
    </cfloop>

    <cfquery name="userFiles">
        SELECT FILEPATH FROM FILES
        WHERE USERID = #Session.UserID#
    </cfquery>

    <cfloop query="userFiles">
        <cffile  action="delete" file=#userFiles.FILEPATH#>
    </cfloop>

    <cfquery>
        DELETE FROM FILES 
        WHERE USERID = #Session.UserID#
    </cfquery>

    <cflog  text="Delete all user files(#Session.Username#): Success!">

</cffunction>
    
</cfcomponent>