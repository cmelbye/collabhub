var Comet = Class.create();
Comet.prototype = {
    post_url: '/post',
    grab_url: '/grab',
    noerror: true,
    
    initialize: function() { },
    
    connect: function() {
        this.ajax = new Ajax.Request(this.grab_url, {
            method: 'get',
            requestHeaders: {},
            onSuccess: function(transport) {
                var response = transport.responseText.evalJSON();
                this.comet.handleResponse(response);
                this.comet.noerror = true;
            },
            onComplete: function(transport) {
                if( !this.comet.noerror ) {
                    setTimeout( function(){comet.connect() }, 5000);
                } else {
                    this.comet.connect();
                }
                this.comet.noerror = false;
            }
        });
        this.ajax.comet = this;
    },
    
    disconnect: function()
    {
        
    },
    
    handleResponse: function(response)
    {
        chatbox = $('chatbox');
        
        if( response['messages'].length > 0 ) {
            for(i = 0; i < response['messages'].length; i++) {
                input = response['messages'][i].body;
                
                new_element = document.createElement('p');
                new_element.appendChild(document.createTextNode(input));
                
                chatbox.appendChild(new_element);
                
                this.scrollDown();
            }
        }
    },
    
    doRequest: function( text )
    {
        new Ajax.Request(this.post_url, {
            method: 'post',
            parameters: { 'msg': text },
            requestHeaders: {}
        });
    },
    
    submit: function() {
        inputbox = $('msg');
        
        chat_input = inputbox.value;
        
        this.doRequest( chat_input );
        
        inputbox.value = "";
        inputbox.focus();
        
        this.scrollDown();
    },

	scrollDown: function() {
		scrollTo(0, $('chatbox').scrollHeight);
	}
}
