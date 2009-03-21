function addToChat()
{
	inputbox = document.getElementById('input');
	chatbox = document.getElementById('chatbox');
	
	input = inputbox.value;
	
	new_element = document.createElement('p');
	new_element.appendChild(document.createTextNode(input));
	
	chatbox.appendChild(new_element);
	
	inputbox.value = "";
	
	scrollTo(0, chatbox.scrollHeight);
}
