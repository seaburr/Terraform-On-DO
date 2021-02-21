DO_TOKEN = ${DIGITALOCEAN_ACCESS_TOKEN}
KEY_PATH = ~/.ssh/id_rsa
VAR_FILE = barista.cloud.tfvars

init:
	terraform init

plan:
	cd infrastructure && \
	terraform plan \
	-var "do_token=${DO_TOKEN}" \
	-var "private_key=${KEY_PATH}" \
	-var-file=${VAR_FILE} \
	-input=false

refresh:
	cd infrastructure && \
	terraform refresh \
	-var "do_token=${DO_TOKEN}" \
	-var "private_key=${KEY_PATH}" \
	-var-file=${VAR_FILE} \
	-input=false

apply:
	cd infrastructure && \
	terraform apply \
	-var "do_token=${DO_TOKEN}" \
	-var "private_key=${KEY_PATH}" \
	-var-file=${VAR_FILE} \
	-input=false \
	-auto-approve

destroy:
	cd infrastructure && \
	terraform destroy \
	-var "do_token=${DO_TOKEN}" \
	-var "private_key=${KEY_PATH}" \
	-var-file=${VAR_FILE} \
	-input=false \

inventory:
	./inventory.py --list

save_inventory:
	./inventory.py --save

run-playbook:
	cd ansible/playbooks && \
	ansible-playbook -i ../../inventory.py setup-wordpress.yml