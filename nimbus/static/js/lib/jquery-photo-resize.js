(function ($) {

    $.fn.photoResize = function (options) {

        var element = $(this),
            defaults = {
                padding: 10
            };

        $(element).load(function () {
            updatePhotoSize();

            $(window).bind("resize", function () {
                updatePhotoSize();
            });
        });

        options = $.extend(defaults, options);

        function updatePhotoSize() {
            var verticalShrink = $(window).height() - 2 * options.padding,
                horizontalShrink = ($(window).width() - 2 * options.padding) * $(element).height() / $(element).width(),
                noShrink = element[0].naturalHeight;
            $(element).attr("height", Math.min(verticalShrink, horizontalShrink, noShrink));
        }
    };

}(jQuery));
