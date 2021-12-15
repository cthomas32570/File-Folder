<div class="container">
    <div class="modal fade" id="changePasswordModal" tabindex="-1" aria-labelledby="Change Password" aria-hidden="true">
        <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
            <h5 class="modal-title">Change Password</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <form>
                
                    <div class="form-floating">
                        <input type="text" class="form-control" id="currentPassword" placeholder="Username">
                        <label for="currentPassword">Current Password</label>
                    </div>
                    <div class="form-floating">
                        <input type="password" class="form-control" id="newPassword" placeholder="Password">
                        <label for="newPassword">New Password</label>
                    </div>

                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                <button type="button" class="btn btn-primary submitNewPassword">Submit</button>
            </div>
        </div>
        </div>
    </div>
</div>

<div class="container w-25 d-grid gap-3">
    <button class="btn btn-lg btn-secondary sign-out">Sign Out</button>
    <button type="button" class="btn btn-lg btn-secondary" data-bs-toggle="modal" data-bs-target="#changePasswordModal">Change Password</button>
    <button class="btn btn-lg btn-danger delete-account">DELETE ACCOUNT</button>
</div>