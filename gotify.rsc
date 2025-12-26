:local gotifyToken "XXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX";
:local gotifyEndpointUrl "https://push.dotnot.pl/message";

:global gotifySource
:global gotifyService
:global gotifyState

# :global gotifySource "defaultSource";
# :global gotifyService "defaultService";
# :global gotifyState "defaultState";
# /system script run gotify

:local httpData "{ \"title\": \"$gotifySource\", \"message\": \"$gotifyService is $gotifyState\" }";
/tool fetch url=$gotifyEndpointUrl http-data="$httpData" \
    http-header-field="X-Gotify-Key:$gotifyToken,content-type:application/json" \
    http-method=post mode=https output=none;