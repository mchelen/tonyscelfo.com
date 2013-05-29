import webapp2

redirects = {
    '/smint': 'http://stats.pingdom.com/uoumvhl0hdy0/495263',
    '/berncliff': 'http://stats.pingdom.com/51e7tbr59r0z/495258',
}

wsgi = webapp2.WSGIApplication(
    [webapp2.Route(
        key,
        webapp2.RedirectHandler,
        defaults={'_uri': redirects[key]})
        for key in redirects.keys()],
    debug=False)
