base_domain=$(aws route53 list-hosted-zones --query "HostedZones[0].Name" --output text | rev | cut -c2- | rev)
helm upgrade --install sample-app --set baseDomain=${base_domain} --set ssl.enabled=true .

#Verifying route53 cname

echo "Get host_id"
host_id=$(aws route53 list-hosted-zones --query "HostedZones[0].Id" |tr -d '"' | tr '/' ' '|awk '{print $2}')
echo $host_id
verify=$(aws route53 list-resource-record-sets --hosted-zone-id $host_id --query "ResourceRecordSets[?AliasTarget != null && Name=='sample-app.${base_domain}.']" |grep sample-app.${base_domain})
if [ -n "$verify" ]; then
	echo "Record sample-app.$base_domain exist."
else
        echo "Creating record_set.json"
        alb_name=$(kubectl get ingress -n default services-ingress -o custom-columns="ALB:.status.loadBalancer.ingress[0].hostname" |grep -v ALB)
        alb_hosted_zone_id=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?DNSName=='${alb_name}'].[CanonicalHostedZoneId]" --output text)

	json=$(printf '{"Changes": [{"Action": "UPSERT", "ResourceRecordSet": { "Name": "sample-app.%s", "Type": "A", "AliasTarget": { "HostedZoneId": "%s", "DNSName": "%s", "EvaluateTargetHealth": false } } } ] }' "$base_domain" "$alb_hosted_zone_id" "$alb_name")
	echo $json |jq > record_set.json
	echo "Add record on route 53"
	add_record=$(aws route53 change-resource-record-sets --hosted-zone-id $host_id --change-batch file://record_set.json) 
fi
