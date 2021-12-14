<div class="row">
    <div class="row upload-drop-zone text-center mx-auto" id="drop-zone">
        <p>Just drag and drop new files here</p>
    </div>

    <table class="table table-striped">
        <thead>
            <tr>
                <th scope="col">#</th>
                <th scope="col">Filename</th>
                <th scope="col">Size</th>
                <th scope="col">Share</th>
                <th scope="col">Download</th>
                <th scope="col">Delete</th>
            </tr>
        </thead>
        <tbody>
    
            <cfquery name="fileTable">
                SELECT * FROM FILES 
                WHERE USERID = #Session.UserID#;
            </cfquery>
    
            <cfloop query="fileTable">
    
                <cfif len(fileTable.SHAREKEY) == 0>
                    <cfset shareButton = '<button class="btn btn-sm btn-outline-secondary shareButton" data-fileno="#fileTable.FILEID#"></button>'>
                <cfelse>
                    <cfset shareButton = #fileTable.SHAREKEY#>
                </cfif>
    
                <cfoutput>
                    <tr>
                        <th scope="row">#fileTable.FILEID#</th>
                        <td>#fileTable.FILENAME#</td>
                        <td>#fileTable.FILESIZE#</td>
                        <td>#shareButton#</td>
                        <td><button class="btn btn-sm btn-outline-secondary downloadButton" data-fileno="#fileTable.FILEID#"></button></td>
                        <td><button class="btn btn-sm btn-outline-secondary deleteButton" data-fileno="#fileTable.FILEID#"></button></td>
                    </tr>
                </cfoutput>    
    
            </cfloop>
        </tbody>
    </table>    
    </div>