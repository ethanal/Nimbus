(function ($) {

    $.fn.photoResize = function (options) {

        var element = $(this),
            defaults = {
                bottomSpacing: 10
            };
        if (!element.actualHeight) {
            element.actualHeight = element.height();
        }

        $(element).load(function () {
            updatePhotoHeight();

            $(window).bind('resize', function () {
                updatePhotoHeight();
            });
        });

        options = $.extend(defaults, options);

        function updatePhotoHeight() {
            var o = options,
                photoHeight = $(window).height();

            $(element).attr('height', Math.min(photoHeight - o.bottomSpacing, element.actualHeight));
        }
    };

}(jQuery));
