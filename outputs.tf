output "login" {
	value = "ssh centos@${data.terraform_remote_state.ip_pool.outputs.EIP_Pool[1].public_ip} -i ${var.aws_ssh_admin_key_file}"
}