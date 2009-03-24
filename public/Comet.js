var Comet = Class.create();
Comet.prototype = {
    timestamp: 0,
    latest: 0,
    post_url: '/post',
    grab_url: '/grab',
    noerror: true,
    
    initialize: function() { },
    
    bootstrap: function(timestamp, latest) {
        this.timestamp = timestamp;
        this.latest = latest;
    },
    
    connect: function() {
        this.latest 
        this.ajax = new Ajax.Request(this.grab_url, {
            method: 'get',
            parameters: { 'timestamp': this.timestamp, 'latest': this.latest },
            requestHeaders: {
              'User-Agent': null,
              'Accept': null,
              'Accept-Language': null,
              'Content-Type': null,
              'Connection': 'keep-alive',
              'Keep-Alive': null  
            },
            onSuccess: function(transport) {
                var response = transport.responseText.evalJSON();
                this.comet.timestamp = response['timestamp'];
                this.comet.latest = response['latest'];
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
                
                scrollTo(0, chatbox.scrollHeight);
            }
        }
    },
    
    doRequest: function( text )
    {
        new Ajax.Request(this.post_url, {
            method: 'post',
            parameters: { 'msg': text },
            requestHeaders: {
              'User-Agent': null,
              'Accept': null,
              'Accept-Language': null,
              'Content-Type': null,
              'Connection': 'keep-alive',
              'Keep-Alive': null  
            }
        });
    },
    
    submit: function() {
        inputbox = $('input');
        
        chat_input = inputbox.value;
        
        this.doRequest( chat_input );
        
        inputbox.value = "";
        inputbox.focus();
        
        scrollTo(0, $('chatbox').scrollHeight);
    }
}