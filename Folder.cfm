<!doctype html>
<html lang="en">

<cfif NOT 
    structKeyExists(Session, "Username") &&
    structKeyExists(Session, "UserID")
    >
        <cflocation url="Login.html" statuscode="302">
</cfif>

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>Folder</title>

    <link rel="canonical" href="https://getbootstrap.com/docs/5.1/examples/album/">

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-1BmE4kWBq78iYhFldvKuhfTAU6auU8tT94WrHftjDbrCEXSU1oBoqyl2QvZ6jIW3" crossorigin="anonymous">
    <link href="style.css" rel="stylesheet">

</head>

<body>
    
    <header>
        <div class="collapse bg-dark" id="navbarHeader">
            <div class="container">
            <div class="row">
                <div class="col-sm-8 col-md-7 py-4">
                    <h4 class="text-white">About</h4>
                    <p class="text-muted">I made this website to show off some of the things I've learned in the past year. Thanks for stopping by!</p>
                </div>
                <div class="col-sm-4 offset-md-1 py-4">
                    <h4 class="text-white">Links</h4>
                    <ul class="list-unstyled">
                        <li><a href="http://shenanigans.digital/home.html" class="text-white">Home</a></li>
                        <li><a href="https://github.com/cthomas32570" class="text-white">GitHub</a></li>
                        <li><a href="#" class="text-white">Email me</a></li>
                    </ul>
                </div>
            </div>
            </div>
        </div>
        <div class="navbar navbar-dark bg-dark shadow-sm">
            <div class="container">
            <a href="#" class="navbar-brand d-flex align-items-center">
                <svg width="40" height="25" viewBox="0 1 35 35" version="1.1"  preserveAspectRatio="xMidYMid meet" fill="currentColor" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
                    <title>file-share-solid</title>
                    <path d="M30,9H16.42L14.11,5.82A2,2,0,0,0,12.49,5H6A2,2,0,0,0,4,7V29a2,2,0,0,0,2,2H30a2,2,0,0,0,2-2V11A2,2,0,0,0,30,9ZM6,7h6.49l2.72,4H6ZM21.94,26.64a2.09,2.09,0,0,1-2.11-2.06l0-.3-5.67-2.66-.08.08a2.08,2.08,0,1,1,.08-2.95l5.64-2.66v-.23a2.08,2.08,0,1,1,.58,1.46L14.75,20v.47l5.72,2.66a2.07,2.07,0,1,1,1.47,3.54Z" class="clr-i-solid clr-i-solid-path-1"></path>
                    <rect x="0" y="0" width="36" height="36" fill-opacity="0"/>
                </svg>
                <strong>File Folder</strong>
            </a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarHeader" aria-controls="navbarHeader" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>
            </div>
        </div>
    </header>

    <main>

        <section class="py-5 text-center container">
            <div class="row py-lg-5">
                <ul class="nav nav-tabs" id="myTab" role="tablist">
                    <li class="nav-item" role="presentation">
                        <button class="nav-link active" id="folder-tab" data-bs-toggle="tab" data-bs-target="#folderTab" type="button" role="tab" aria-controls="folderTab" aria-selected="true">My Files</button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" id="shared-tab" data-bs-toggle="tab" data-bs-target="#sharedTab" type="button" role="tab" aria-controls="sharedTab" aria-selected="false">Shared Files</button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" id="account-tab" data-bs-toggle="tab" data-bs-target="#accountTab" type="button" role="tab" aria-controls="accountTab" aria-selected="false">Account</button>
                    </li>
                </ul>
                <div class="tab-content" id="myTabContent">
                    <div class="tab-pane fade show active" id="folderTab" role="tabpanel" aria-labelledby="folder-tab">...</div>
                    <div class="tab-pane fade" id="sharedTab" role="tabpanel" aria-labelledby="shared-tab">...</div>
                    <div class="tab-pane fade" id="accountTab" role="tabpanel" aria-labelledby="account-tab">...</div>
                </div>
            </div>
        </section>          

    </main>

    <footer class="text-muted">
        <div class="container">
            <p class="mb-1 text-center">&copy; Christopher Thomas</p>
        </div>
    </footer>


    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-ka7Sk0Gln4gmtz2MlQnikT1wXgYsOg+OMhuP+IlRH9sENBO0LRn5q+8nbTov4+1p" crossorigin="anonymous"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js" integrity="sha256-/xUj+3OJU5yExlq6GSYGSHk7tPXikynS7ogEvDej/m4=" crossorigin="anonymous"></script>

    <script type="text/javascript">

        const fmPath = "FileManager.cfc?";
        const amPath = "AccountManager.cfc?";

        function getFileTable() {
            $.get(`${fmPath}method=getFileTable`, function(res) {
                const html = $.parseHTML(res);
                $("#folderTab").html(html);
            });
        }

        function getSharedTable() {
            $.get(`${fmPath}method=getSharedTable`, function(res) {
                const html = $.parseHTML(res);
                $("#sharedTab").html(html);
            });
        }

        function getAccount() {
            $.get(`${amPath}method=getAccount`, function(res) {
                const html = $.parseHTML(res);
                $("#accountTab").html(html);
            });
        }

        $(document).ready(function() {
            getFileTable();
            getSharedTable();
            getAccount();

            $(document).on("dragover", ".upload-drop-zone", function(event) {
                event.preventDefault();
                event.stopPropagation();
                $(this).addClass("drop");
            });

            $(document).on("dragleave", ".upload-drop-zone", function(event) {
                event.preventDefault();
                event.stopPropagation();
                $(this).removeClass("drop");
            });

            $(document).on("drop", ".upload-drop-zone", function(event) {
                event.preventDefault();
                event.stopPropagation();
                $(this).removeClass("drop");

                const formdata = new FormData();
                const formfiles = event.originalEvent.dataTransfer.files;
                
                let i = 0;
                for (const file of formfiles) {
                    formdata.append("file" + i, file);
                    i++;
                }

                $.ajax({
                    url: fmPath + "method=uploadFiles",
                    data: formdata,
                    type: 'POST',
                    contentType: false,
                    processData: false,
                    success: () => getFileTable()
                });        
            });

        });


        $("#folderTab").on("click", ".downloadButton", function() {
            const fileNo = $(this).data("fileno");
            window.open(fmPath + "method=downloadFile&fileNo=" + fileNo);
        });

        $("#folderTab").on("click", ".deleteButton", function() {
            const tag = $(this);
            const fileNo = tag.data("fileno");

            $.get(fmPath + "method=deleteFile&fileNo=" + fileNo, function() {
                tag.closest("tr").remove(); 
            });
        });

        $("#folderTab").on("click", ".shareButton", function() {
            const tag = $(this);
            const fileNo = tag.data("fileno");

            $.get(fmPath + "method=shareFile&fileNo=" + fileNo, function(shareKey) {
                tag.closest("td").empty().text(shareKey);
            });
        });

        $(document).on("click", "#checkcode", function() {

            $.post(
                fmPath + "method=accessFile", 
                $("#shareKeyInput").val(), 
                () => getSharedTable()
            );

        });


        $("#accountTab").on("click", ".delete-account", function() {

        if (confirm("Are you sure? You cannot undo this action.")) {

            $.post(amPath + "method=deleteAccount", function() {
                window.location.replace("home.cfm");
            });

        }

    });

    $("#accountTab").on("click", ".submitNewPassword", function() {
        const formData = {
            old: $("#currentPassword").val(),
            new: $("#newPassword").val()
        };

        $.post(amPath + "method=setPassword", formData, function(res) {
            if (res === "true") {
                alert("Success!");
            }
            else {
                alert("Failure!");
            }
        });
    });

    $("#accountTab").on("click", ".sign-out", function() {

        $.post(amPath + "method=signOut", function() {
            window.location.href = "./Login.html";
        });

    });
        
    </script>
      
</body>
</html>