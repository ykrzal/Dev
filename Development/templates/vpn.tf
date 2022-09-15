resource "aws_vpn_gateway" "vpn_gw" {
    vpc_id = "${aws_vpc.main_vpc.id}"
}

resource "aws_customer_gateway" "customer_gw" {
    bgp_asn = 65000
    ip_address = "172.0.0.1"
    type = "ipsec.1"
}

resource "aws_vpn_connection" "default" {
    vpn_gateway_id = "${aws_vpn_gateway.vpn_gw.id}"
    customer_gateway_id = "${aws_customer_gateway.customer_gw.id}"
    type = "ipsec.1"
    static_routes_only = true
}

resource "aws_vpn_connection_route" "office" {
    destination_cidr_block = "192.168.10.0/24"
    vpn_connection_id = "${aws_vpn_connection.default.id}"
}