$(function() {
    $(".upload-dropzone").dropzone({
        url: "/dropzone-upload",
        clickable: ".upload-dropzone, .upload-dropzone *",
        complete: function(file) {
            this.removeFile(file);
        }
    });
});
