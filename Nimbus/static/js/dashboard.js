$(function() {
    var resetDropzone = function(el) {
        var $e = $(el);
        var $m = $e.children(".dz-message");
        $e.removeClass("loading");
        $e.removeClass("error");
        $m.text($e.data("initial-message"));
        $m.css("line-height", $m.data("initial-line-height"));
    }

    Dropzone.options.uploadDropzone = {
        clickable: "#upload-dropzone, .upload-icon",
        complete: function(file) {
            this.removeFile(file);
        },
        success: function(file, response) {
            resetDropzone(this.element);
        },
        error: function(file, error) {
            $e = $(this.element);
            $e.removeClass("loading");
            $e.addClass("error");
            $e.children(".dz-message").text("Error Uploading File");
            setTimeout(function(){
                resetDropzone($e);
            }, 2000);
        },
        addedfile: function(file) {
            var $e = $(this.element);
            var $m = $e.children(".dz-message");
            if (!$e.data("initial-message")) {
                $e.data("initial-message", $m.text());
            }
            $e.addClass("loading");
            var messageHeight = $m.height();
            var lineHeight = parseInt($m.css("line-height").replace("px",""));
            var lines = Math.round(messageHeight / lineHeight);
            if (!$m.data("initial-line-height")) {
                $m.data("initial-line-height", $m.css("line-height"));
            }
            $m.css("line-height", (lines * lineHeight) + "px");
            $m.text("Uploading...");
        }
    };


    $(".delete-checkbox").click(function() {
        if ($(".delete-checkbox").filter(":checked").length === 0)
            $(".delete-files").hide()
        else
            $(".delete-files").show()
    });

    $(".delete-files").click(function() {
        var ids = $.map($(".delete-checkbox").filter(":checked"), function(e){
            var $p = $(e).parent().parent();
            var id = $p.data("id");
            $p.remove()
            return id;
        });
        console.log(ids);
        $(this).hide();
    });
});
