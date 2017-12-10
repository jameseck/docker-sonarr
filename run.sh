#!/bin/bash

CONFIG_FILE=/config/config.xml

if [ ! -f $CONFIG_FILE ]; then
  cat <<EOF > $CONFIG_FILE
<Config>
<LogLevel>Info</LogLevel>
<Port>8989</Port>
<UrlBase></UrlBase>
<BindAddress>*</BindAddress>
<SslPort>9898</SslPort>
<EnableSsl>False</EnableSsl>
<ApiKey>${API_KEY}</ApiKey>
<AuthenticationMethod>Forms</AuthenticationMethod>
<Branch>master</Branch>
<LaunchBrowser>False</LaunchBrowser>
<SslCertHash></SslCertHash>
<UpdateMechanism>BuiltIn</UpdateMechanism>
</Config>
EOF
else
  sed -i -e "s/\(<ApiKey>\).*\(<\/ApiKey>\)/\1${API_KEY}\2/" $CONFIG_FILE
fi

exec /usr/bin/mono /NzbDrone/NzbDrone.exe -nobrowser -data=/config
