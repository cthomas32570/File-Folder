<div class="form-floating">
    <input name="shareKeyInput" type="text" class="form-control shareKeyInput" id="shareKeyInput" pattern="" title="Code is 24 characters" placeholder="Share Code">
    <label for="sharekeyInput">Share Code</label>
    <button type="button" class="btn btn-outline-dark" id="checkcode">Check Code</button>
</div>

<div class="row">
    <table class="table table-dark table-striped">
        <thead>
            <tr>
                <th scope="col">#</th>
                <th scope="col">Filename</th>
                <th scope="col">Size</th>
                <th scope="col">Shared by</th>
            </tr>
        </thead>
        <tbody>
            <cfquery name="sharedTable">
                SELECT * FROM FILES 
                WHERE UserID = #Session.UserID#
            </cfquery>

            <cfloop query="sharedTable">
                <cfset fileOwner = Replace(sharedTable.FILEPATH, #GetDirectoryFromPath(GetBaseTemplatePath())# & "uploads\", "")>

                <cfif spanExcluding(fileOwner, "\") != Session.Username>
                    <cfoutput>
                        <tr>
                            <th scope="row">#sharedTable.FILEID#</th>
                            <td>#sharedTable.FILENAME#</td>
                            <td>#sharedTable.FILESIZE#</td>
                            <td>#spanExcluding(fileOwner, "\")#</td>
                        </tr>
                    </cfoutput>        
                </cfif>
            </cfloop>
        </tbody>
    </table>    
</div>