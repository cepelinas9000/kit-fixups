# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils user

DESCRIPTION="A high-throughput distributed messaging system"
HOMEPAGE="http://kafka.apache.org/"

# pick recommended scala version
SCALA_VERSION=2.13
MY_PN="kafka"
MY_P="${MY_PN}_${SCALA_VERSION}-${PV}"
SRC_URI="https://archive.apache.org/dist/kafka/${PV}/${MY_P}.tgz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="+internal-zookeeper"

RDEPEND="virtual/jre:17"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${MY_P}"
INSTALL_DIR="/opt/${MY_PN}"

pkg_setup() {
	enewgroup kafka
	enewuser kafka -1 /bin/sh /var/lib/kafka kafka
}

src_prepare() {
	sed -i -e 's:/tmp/zookeeper:/var/lib/kafka/zookeeper:' "config/zookeeper.properties" || die
	sed -i -e 's:/tmp/kafka-logs:/var/lib/kafka/logs:' "config/server.properties" || die
	eapply_user
}

src_install() {
	insinto /etc/kafka
	doins config/zookeeper.properties config/server.properties
	if use "internal-zookeeper"; then
		keepdir /var/lib/kafka/zookeeper
		newinitd "${FILESDIR}/${MY_PN}-zookeeper.init.d" "${MY_PN}-zookeeper"
	fi

	keepdir /var/lib/kafka
	fowners -R kafka:kafka /var/lib/kafka

	keepdir /var/log/kafka
	fowners -R kafka:kafka /var/log/kafka

	newinitd "${FILESDIR}/${MY_PN}.init.d.4" "${MY_PN}"

	dodir "${INSTALL_DIR}"
	cp -pRP bin config libs "${ED}/${INSTALL_DIR}" || die
	keepdir "${INSTALL_DIR}/logs"
	fowners -R kafka:kafka "${INSTALL_DIR}"
}
