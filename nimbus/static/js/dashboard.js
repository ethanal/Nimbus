$(function() {
    var deleteCheckboxClicked = function() {
        if ($(".delete-checkbox").filter(":checked").length === 0)
            $(".delete-selected").hide()
        else
            $(".delete-selected").show()
    };

    $(".delete-checkbox").click(deleteCheckboxClicked);

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
        uploadMultiple: false,
        maxFiles: 1,
        complete: function(file) {
            this.removeFile(file);
        },
        success: function(file, response) {
            resetDropzone(this.element);
            displayedMediaType = $("#media-list").data("media-type-code");
            
            var mediaItem = response;
            if (displayedMediaType == "ALL" || displayedMediaType == mediaItem.media_type) {
                var $table = $("#media-list>table"),
                    $tbody = $("#media-list>table>tbody");

                if ($table.hasClass("empty-state")) {
                    $tbody.html(mediaItem.html);
                } else {
                    $tbody.prepend(mediaItem.html);
                }

                $table.addClass("table-hover");
                $table.removeClass("empty-state");
            }

            $(".delete-checkbox").click(deleteCheckboxClicked);
        },
        error: function(file, error) {
            console.error(error);
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
        },
        sending: function(file, xhr, formData) {
            xhr.withCredentials = true; // send cookies even though this is a cross-site request
        }
    };

    $(".delete-selected").click(function() {
        $(this).css("width", $(this).outerWidth());
        $(this).text("Deleting...");

        var $rows = [];
        var ids = $.map($(".delete-checkbox").filter(":checked"), function(e){
            var $p = $(e).parent().parent();
            var id = $p.data("id");
            $rows.push($p);
            return id;
        });

        var getVars = ids.map(function(id){return "id=" + id}).join("&");
        var button = this;
        $.ajax({
            url: $(this).data("delete-api-endpoint") + "?" + getVars,
            type: "DELETE",
            xhrFields: {
                withCredentials: true
            },
            beforeSend: function(xhr, settings) {
                xhr.setRequestHeader("X-CSRFToken", $.cookie("csrftoken"));
            },
            success: function() {
                $(button).text("Delete Selected");

                $.map($rows, function($r) {
                    $r.remove();
                });

                $(button).hide();

                var $table = $("#media-list>table"),
                    $tbody = $("#media-list>table>tbody");
                if ($("#media-list tr").length == 0) {
                    location.reload();
                    // $tbody.append("<tr><td>Nothing here yet</td></tr>");
                    // $table.removeClass("table-hover");
                    // $table.addClass("empty-state");
                }
            },
            error: function(xhr, status, error) {
                console.log(xhr);
                $(button).text("Error!");
                setTimeout(function() {
                    $(button).text("Delete Selected");
                }, 1000);
            }
        });



    });
});
