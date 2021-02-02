from django.http import HttpResponse
from sniffer_app.settings import LOG_URL_FILE, CL_LOG_FILE
from django.views.decorators.csrf import csrf_exempt

def envname(request):
    return HttpResponse("kizos-2020.6.4-16")

def sixconf(request):
    r = HttpResponse()
    r['Content-Type'] = 'text/xml;charset=UTF-8'
    r.write("""<?xml version="1.0" encoding="utf-8"?>
<connection name="HA101" protocol="tcp+eap" version="" retry-delay="30s" buffering-delay="500ms">
<tls client="/etc/security/client.crt" authority="/etc/security/ca.crt" key="/etc/security/client.key"/>
<http host="ha101-3.overkiz.com" port="443" path="connection-listener/cl" timeout="30s" connection-timeout="15s"/>
<bypass algorithm="HMAC-SHA1" host="ha101-3.overkiz.com" port="18888" interval="20s" timeout="5s" retry="5" anti-replay="true" serial="/etc/security/ca.crt"/>
<eap host="ha101-3.overkiz.com" port="802" handshake-timeout="15s" keep-alive="20s" server-timeout="30s" time-to-live="4h" max-queued="100"/>
<log host="ha101-3.overkiz.com" port="443" path="connection-listener/log" backlog="0"/>
</connection>""")
    return r

@csrf_exempt
def r_log(request):
    f = open(LOG_URL_FILE, "at")
    f.write(request.body.decode("UTF-8") + "\n")
    f.close()
    return HttpResponse("")

@csrf_exempt
def cl_log(request):
    f = open(CL_LOG_FILE, "at")
    f.write(request.body.decode("UTF-8") + "\n")
    f.close()
    return HttpResponse("")

"""<?xml version="1.0" encoding="utf-8"?>
<connection name="HA101" protocol="tcp+eap" version="" retry-delay="30s" buffering-delay="500ms">
<tls client="/etc/security/client.crt" authority="/etc/security/ca.crt" key="/etc/security/client.key"/>
<http host="ha101-3.overkiz.com" port="443" path="connection-listener/cl" timeout="30s" connection-timeout="15s"/>
<bypass algorithm="HMAC-SHA1" host="ha101-3.overkiz.com" port="18888" interval="20s" timeout="5s" retry="5" anti-replay="true" serial="/etc/security/ca.crt"/>
<eap host="ha101-3.overkiz.com" port="802" handshake-timeout="15s" keep-alive="20s" server-timeout="30s" time-to-live="4h" max-queued="100"/>
<log host="ha101-3.overkiz.com" port="443" path="connection-listener/log" backlog="0"/>
</connection>"""
