[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

New-Item -Path $pwd\1 -ItemType Directory -Force
