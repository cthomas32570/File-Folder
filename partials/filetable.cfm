<div class="row">
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
                    <cfset shareButton = "<button class=""sharebutton"" data-toShare='{ ""fileNo"": #fileTable.FILEID# , ""userNo"": #fileTable.USERID# }'><i class=""fas fa-share""></i></button>">
                <cfelse>
                    <cfset shareButton = #fileTable.SHAREKEY#>
                </cfif>
    
                <cfoutput>
                    <tr>
                        <th scope="row">#fileTable.FILEID#</th>
                        <td>#fileTable.FILENAME#</td>
                        <td>#fileTable.FILESIZE#</td>
                        <td>#shareButton#</td>
                        <td><button class="downloadbutton" data-toDownload='{ "fileNo": #fileTable.FILEID# , "userNo": #fileTable.USERID# }'><i class="fas fa-file-download"></i></button></td>
                        <td><button class="deletebutton" data-toDelete='{ "fileNo": #fileTable.FILEID# , "userNo": #fileTable.USERID# }'><i class="fas fa-trash-alt"></i></button></td>
                    </tr>
                </cfoutput>    
    
            </cfloop>
        </tbody>
    </table>    
    </div>