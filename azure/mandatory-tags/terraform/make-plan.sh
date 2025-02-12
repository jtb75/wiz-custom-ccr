terraform plan -out=tfplan && terraform show -json tfplan | jq '.' > planfile.json && rm -f tfplan
