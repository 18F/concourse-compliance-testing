// tweaked from https://github.com/zaproxy/community-scripts/blob/ee1812031bc9c305b671f415bf09984865965161/authentication/MediaWikiAuthentication.js
var HttpRequestHeader = Java.type('org.parosproxy.paros.network.HttpRequestHeader');
var HttpHeader = Java.type('org.parosproxy.paros.network.HttpHeader');
var URI = Java.type('org.apache.commons.httpclient.URI');
var Source = Java.type('net.htmlparser.jericho.Source');

function authenticate(helper, paramsValues, credentials) {
	print("Authenticating via JavaScript script...");

	var authHelper = new MWAuthenticator(helper, paramsValues, credentials),
		loginToken = authHelper.getLoginToken();

	return authHelper.doLogin(loginToken);
}

function getRequiredParamsNames(){
	return ['Login URL'];
}

function getOptionalParamsNames(){
	return [];
}

function getCredentialsParamsNames(){
	return ['Username', 'Password'];
}

function MWAuthenticator(helper, paramsValues, credentials) {
	this.helper = helper;
	this.loginUrl = paramsValues.get('Login URL');
	this.userName = credentials.getParam('Username');
	this.password = credentials.getParam('Password');

	return this;
}

MWAuthenticator.prototype = {
	doLogin: function (loginToken) {
		var requestBody = 'username=' + encodeURIComponent(this.userName) +
				'&password=' + encodeURIComponent(this.password) +
				'&X-Uaa-Csrf=' + encodeURIComponent(loginToken),
			response = this.doRequest(
				'https://login.fr.cloud.gov/login.do',
				HttpRequestHeader.POST,
				requestBody
			);

		return response;
	},

	getLoginToken: function () {
		var response = this.doRequest(this.loginUrl, HttpRequestHeader.GET),
			loginToken = this.getLoginTokenFromForm(response, 'X-Uaa-Csrf');

		return loginToken;
	},

	doRequest: function (url, requestMethod, requestBody) {
		var msg,
			requestInfo,
			requestUri = new URI(url, false);
			requestHeader = new HttpRequestHeader(requestMethod, requestUri, HttpHeader.HTTP10);

		requestInfo = 'Sending ' + requestMethod + ' request to ' + requestUri;
		msg = this.helper.prepareMessage();
		msg.setRequestHeader(requestHeader);

		if (requestBody) {
			requestInfo += ' with body: ' + requestBody;
			msg.setRequestBody(requestBody);
		}

		print(requestInfo);
		this.helper.sendAndReceive(msg);
		print("Received response status code for authentication request: " + msg.getResponseHeader().getStatusCode());

		return msg;
	},

	getLoginTokenFromForm: function (request, loginTokenName) {
		var iterator, element, loginToken,
			pageSource = request.getResponseHeader().toString() + request.getResponseBody().toString(),
			src = new Source(pageSource),
			elements = src.getAllElements('input');

		for (iterator = elements.iterator(); iterator.hasNext();) {
			element = iterator.next();
			if (element.getAttributeValue('name') == loginTokenName) {
				loginToken = element.getAttributeValue('value');
				break;
			}
		}

		return loginToken;
	}
};
