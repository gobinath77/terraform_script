output "ec2_Public_ip" {
  value = ["${aws_instance.httpd_pub.*.public_ip}"]
}
output "ec2_running_state" {
  value = ["${aws_instance.httpd_pub.*.instance_state}"]
}
output "ec2_Key_Name" {
  value = ["${aws_instance.httpd_pub.*.key_name}"]
}