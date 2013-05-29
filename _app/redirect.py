import webapp2

redirects = {
    '/berncliff': 'http://stats.pingdom.com/51e7tbr59r0z/495258',
    '/<:\+|plus>': 'https://plus.google.com/110371866564374610674',
    '/smint': 'http://stats.pingdom.com/uoumvhl0hdy0/495263',
    '/wordpress/2008/03/01/hacking-appletv-take-2<:/?>': '/2008/09/15/hacking-appletv.html',
}

wsgi = webapp2.WSGIApplication(
    [webapp2.Route(
        key,
        webapp2.RedirectHandler,
        defaults={'_uri': redirects[key]})
        for key in redirects.keys()],
    debug=False)
