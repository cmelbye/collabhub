var comet = new Comet();

Event.observe(window, 'load', function() {
	comet.scrollDown();
    comet.connect();
});
