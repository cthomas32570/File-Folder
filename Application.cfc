component {

    this.name = "fileFolder";
    this.datasource = "fileCabinet";
    this.sessionManagement = true;
    this.sessionTimeout = CreateTimeSpan(0, 0, 30, 0); //30 minutes
}