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
                    <cfset shareButton = '<button class="btn btn-sm btn-outline-secondary shareButton" data-fileno="#fileTable.FILEID#"><svg width="15" height="15" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" d="M12.53 1.22a.75.75 0 00-1.06 0L8.22 4.47a.75.75 0 001.06 1.06l1.97-1.97v10.69a.75.75 0 001.5 0V3.56l1.97 1.97a.75.75 0 101.06-1.06l-3.25-3.25zM5.5 9.75a.25.25 0 01.25-.25h2.5a.75.75 0 000-1.5h-2.5A1.75 1.75 0 004 9.75v10.5c0 .966.784 1.75 1.75 1.75h12.5A1.75 1.75 0 0020 20.25V9.75A1.75 1.75 0 0018.25 8h-2.5a.75.75 0 000 1.5h2.5a.25.25 0 01.25.25v10.5a.25.25 0 01-.25.25H5.75a.25.25 0 01-.25-.25V9.75z"/></svg></button>'>
                <cfelse>
                    <cfset shareButton = #fileTable.SHAREKEY#>
                </cfif>
    
                <cfoutput>
                    <tr>
                        <th scope="row">#fileTable.FILEID#</th>
                        <td>#fileTable.FILENAME#</td>
                        <td>#fileTable.FILESIZE#</td>
                        <td>#shareButton#</td>
                        <td><button class="btn btn-sm btn-outline-secondary downloadButton" data-fileno="#fileTable.FILEID#">
                            <svg width="15" height="15" viewBox="0 0 256 256" fill="black" id="Flat" xmlns="http://www.w3.org/2000/svg">
                                <path d="M236,136v64a12.01343,12.01343,0,0,1-12,12H32a12.01343,12.01343,0,0,1-12-12V136a12.01343,12.01343,0,0,1,12-12H80a4,4,0,0,1,0,8H32a4.00427,4.00427,0,0,0-4,4v64a4.00427,4.00427,0,0,0,4,4H224a4.00427,4.00427,0,0,0,4-4V136a4.00427,4.00427,0,0,0-4-4H176a4,4,0,0,1,0-8h48A12.01343,12.01343,0,0,1,236,136Zm-110.8291-5.17285a4.00484,4.00484,0,0,0,.61084.49951c.09765.06543.20361.10986.30517.16553a3.87372,3.87372,0,0,0,.3833.20166,3.95744,3.95744,0,0,0,.40674.12646c.11328.03321.22217.07715.33985.10059a3.91693,3.91693,0,0,0,1.5664,0c.11768-.02344.22657-.06738.33985-.10059a3.95744,3.95744,0,0,0,.40674-.12646,3.87372,3.87372,0,0,0,.3833-.20166c.10156-.05567.20752-.1001.30517-.16553a4.00484,4.00484,0,0,0,.61084-.49951l47.99951-47.999a3.99992,3.99992,0,0,0-5.65722-5.65625L132,118.34277V24a4,4,0,0,0-8,0v94.34277L82.82861,77.17188a3.99992,3.99992,0,0,0-5.65722,5.65625ZM196,168a8,8,0,1,0-8,8A8.00917,8.00917,0,0,0,196,168Z"/>
                            </svg>
                        </button></td>
                        <td><button class="btn btn-sm btn-outline-secondary deleteButton" data-fileno="#fileTable.FILEID#">
                            <svg width="15" height="15" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                                <path fill="currentColor" d="M20 2h-4v-.85C16 .52 15.48 0 14.85 0h-5.7C8.52 0 8 .52 8 1.15V2H4c-1.1 0-2 .9-2 2 0 .74.4 1.38 1 1.73v14.02C3 22.09 4.91 24 7.25 24h9.5c2.34 0 4.25-1.91 4.25-4.25V5.73c.6-.35 1-.99 1-1.73 0-1.1-.9-2-2-2zm-1 17.75c0 1.24-1.01 2.25-2.25 2.25h-9.5C6.01 22 5 20.99 5 19.75V6h14v13.75z"/>
                                <path fill="currentColor" d="M8 20.022c-.553 0-1-.447-1-1v-10c0-.553.447-1 1-1s1 .447 1 1v10c0 .553-.447 1-1 1zm8 0c-.553 0-1-.447-1-1v-10c0-.553.447-1 1-1s1 .447 1 1v10c0 .553-.447 1-1 1zm-4 0c-.553 0-1-.447-1-1v-10c0-.553.447-1 1-1s1 .447 1 1v10c0 .553-.447 1-1 1z"/>
                            </svg>
                        </button></td>
                    </tr>
                </cfoutput>    
    
            </cfloop>
        </tbody>
    </table>    
    </div>