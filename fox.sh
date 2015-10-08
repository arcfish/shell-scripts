#!/bin/bash

ais_request_out=$(curl -s -c verizon_session http://idp.securetve.com/rest/1.0/urn:foxnews:com:sp:site:2/init/urn:verizon:com:idp:prod
cat verizon_session | grep "ais_request_out" | awk -s '{print $7}')

curl -c verizon_cookies --verbose --data "cookiedomain=.verizon.com&amLoginUrl=https://auth.verizon.com/amserver/UI/Login?realm=dotcom&module=AIAW&goto=https://signin.verizon.com/sso/choice/tvpHandler.jsp?loginType%3DVzRedirect%26partner%3Dfoxnews%26partnerlogo%3D%26cancelURL%3Dhttp%253A%252F%252Fidp.securetve.com%252Fsaml2%252FassertionConsumer%252F%26TARGET%3Dhttps%253A%252F%252Fidp.securetve.com%252Fsaml2%252FassertionConsumer%252F&clientId=TvLogin&partner=foxnews&errorURL=https://signin.verizon.com/sso/VOLPortalLogin?src%3DSAM%26loginType%3DVzRedirect%26partner%3Dfoxnews%26partnerlogo%3D%26cancelURL%3Dhttp%253A%252F%252Fidp.securetve.com%252Fsaml2%252FassertionConsumer%252F%26TARGET%3Dhttps%253A%252F%252Fidp.securetve.com%252Fsaml2%252FassertionConsumer%252F&stid=off&forceprofile=off&seclock=off&vzw=off&IDToken1=USERNAME&IDToken2=PASSWORD" https://auth.verizon.com/amserver/UI/Login\?realm\=dotcom\&module\=AIAW\&goto\=https://signin.verizon.com/sso/choice/tvpHandler.jsp\?loginType%3DVzRedirect%26partner%3Dfoxnews%26partnerlogo%3D%26cancelURL%3Dhttp%253A%252F%252Fidp.securetve.com%252Fsaml2%252FassertionConsumer%252F%26TARGET%3Dhttps%253A%252F%252Fidp.securetve.com%252Fsaml2%252FassertionConsumer%252F\&clientId\=TvLogin\&partner\=foxnews\&errorURL\=https://signin.verizon.com/sso/VOLPortalLogin\?src%3DSAM%26loginType%3DVzRedirect%26partner%3Dfoxnews%26partnerlogo%3D%26cancelURL%3Dhttp%253A%252F%252Fidp.securetve.com%252Fsaml2%252FassertionConsumer%252F%26TARGET%3Dhttps%253A%252F%252Fidp.securetve.com%252Fsaml2%252FassertionConsumer%252F

saml=$(curl -s -b verizon_cookies https://signin.verizon.com/sso/TVPHandlerServlet\?loginType\=VzRedirect\&partner\=foxnews\&partnerlogo\=\&cancelURL\=http%3A%2F%2Fidp.securetve.com%2Fsaml2%2FassertionConsumer%2F\&TARGET\=https%3A%2F%2Fidp.securetve.com%2Fsaml2%2FassertionConsumer%2F | jq '.SAMLResponse' | php -R 'echo urlencode($argn);')

curl --verbose -c securetve 'https://idp.securetve.com/saml2/assertionConsumer/' -H 'Pragma: no-cache' -H 'Origin: https://signin.verizon.com' -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: en-US,en;q=0.8' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Cache-Control: no-cache' -H 'Referer: https://signin.verizon.com/sso/choice/tvpHandler.jsp?loginType=VzRedirect&partner=foxnews&partnerlogo=&cancelURL=http%3A%2F%2Fidp.securetve.com%2Fsaml2%2FassertionConsumer%2F&TARGET=https%3A%2F%2Fidp.securetve.com%2Fsaml2%2FassertionConsumer%2F' -H "Cookie: AIS_ADDTL_NONCE=null; ais_footprints=""; aissession=""; ais_request_out="$ais_request_out"" -H 'Connection: keep-alive' --data "SAMLResponse=$saml&RelayState=&targetValue=https%3A%2F%2Fidp.securetve.com%2Fsaml2%2FassertionConsumer%2F&logout=&CPHSTarget=" --compressed

token=$(curl -s -b securetve http://idp.securetve.com/rest/1.0/urn:foxnews:com:sp:site:2/identity/channelAccess/FoxNews|jq -r '.security_token')

command='http://fnctvehd1-f.akamaihd.net/FNC_1_3500@37340?v=3.6.0&p=aasp-3.6.0.50.41&fp=MAC18,0,0,232&r=OIIQG&g=DPIKCEMFCFJV&primaryToken='
command="$command$token"

echo $command