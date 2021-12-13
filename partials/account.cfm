<div class="container">
    <h1 class="h3 mb-3 fw-normal">Change Password</h1>
      
    <div class="form-floating">
        <input name="password" type="password" class="form-control" id="oldPass" pattern=".{8,}" title="8 characters minimum" placeholder="Current Password">
        <label for="oldPass">Current Password</label>
    </div>
    <div class="form-floating">
        <input name="newpassword" type="password" class="form-control" id="newPass" pattern=".{8,}" title="8 characters minimum" placeholder="New Password">
        <label for="newPass">New Password</label>
    </div>
      
    <button class="w-100 btn btn-lg btn-primary set-password">Submit</button>
</div>

<div class="container">
    <button class="btn btn-lg btn-danger delete-account">DELETE ACCOUNT</button>
</div>