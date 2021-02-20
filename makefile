DO_TOKEN = ${DIGITALOCEAN_ACCESS_TOKEN}
KEY_PATH = ${HOMEDRIVE}${HOMEPATH}\.ssh\id_rsa
VAR_FILE = barista.cloud.tfvars

init:
	terraform init

plan:
	terraform plan \
	-var "do_token=${DO_TOKEN}" \
	-var "private_key=${KEY_PATH}" \
	-var-file=${VAR_FILE} \
	-input=false

refresh:
	terraform destroy \
	-var "do_token=${DO_TOKEN}" \
	-var "private_key=${KEY_PATH}" \
	-var-file=${VAR_FILE} \
	-input=false

apply:
	terraform apply \
	-var "do_token=${DO_TOKEN}" \
	-var "private_key=${KEY_PATH}" \
	-var-file=${VAR_FILE} \
	-input=false \
	-auto-approve

destroy:
	terraform destroy \
	-var "do_token=${DO_TOKEN}" \
	-var "private_key=${KEY_PATH}" \
	-var-file=${VAR_FILE} \
	-input=false \

inventory:
	python inventory.py --list

save_inventory:
	python inventory.py --save
