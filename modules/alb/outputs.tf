output "alb_id" {
    value = "${aws_alb.alb.id}"
}
output "alb_sg_id" {
    value = "${aws_security_group.alb-sg.id}"
}
output "alb_tg_id" {
    value = "${aws_alb_target_group.alb-tg.*.id}"
}
output "alb_dns_name" {
    value = "${aws_alb.alb.dns_name}"
}
output "alb_zone_id" {
    value = "${aws_alb.alb.zone_id}"
}
/*
output "alb_http_listener_arn" {
value = "${aws_alb_listener.alb-http-listener.arn}"
}
*/
output "alb_https_listener_arn" {
value = "${aws_alb_listener.alb-https-listener.arn}"
}
