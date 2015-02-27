(function ($) {

    $.fn.photoResize = function (options) {

        var element = $(this),
            defaults = {
                padding: 10
            };

        $(element).load(function () {
            updatePhotoSize();

            $(window).bind('resize', function () {
                updatePhotoSize();
            });
        });

        options = $.extend(defaults, options);

        function updatePhotoSize() {
            var o = options,
                windowHeight = $(window).height(),
                windowWidth = $(window).width();

            $(element).attr('height', Math.min(windowHeight - 2 * o.padding, element[0].naturalHeight));
            if ($(element).attr('width') > (windowWidth - o.padding)) {
                $(element).attr('width', Math.min(windowWidth - 2 * o.padding, element[0].naturalWidth));
            }
        }
    };

}(jQuery));
